@tool
extends DecoratorAction
class_name CheckConditions

## 条件检查装饰器

## 条件配置
@export var conditions: Dictionary

var _condition_tree: EffectCondition

func _ready() -> void:
    super._ready()
    _condition_tree = _build_condition_tree(conditions)

func _perform_action(context: Dictionary) -> STATUS:
    if not _condition_tree:
        return STATUS.FAILURE
        
    if not _condition_tree.evaluate(context):
        return STATUS.FAILURE
        
    if not child:
        return STATUS.SUCCESS
        
    return await child.execute(context)

## 根据配置构建条件树
func _build_condition_tree(config: Dictionary) -> EffectCondition:
    var type = config.get("type", "")
    
    # 创建条件节点
    var condition: EffectCondition
    match type:
        "AND", "OR", "NOT":
            condition = EffectCondition.new()
            condition.condition_type = EffectCondition.TYPE[type]
            
            # 递归构建子条件
            var sub_configs = config.get("sub_conditions", [])
            for sub_config in sub_configs:
                var sub_condition = _build_condition_tree(sub_config)
                if sub_condition:
                    condition.sub_conditions.append(sub_condition)
                    
        "tag":
            condition = TagCondition.new()
            condition.params = config.get("params", {})
            
        "stat":
            condition = StatCondition.new()
            condition.params = config.get("params", {})
            
        "distance":
            condition = DistanceCondition.new()
            condition.params = config.get("params", {})
            
    return condition
