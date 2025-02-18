extends DecoratorAction
class_name DecoratorCost

## 消耗配置
@export var cost_resource_id: StringName
@export var cost_value_param: StringName


func _can_execute(context: Dictionary) -> bool:
    # 检查是否有足够的资源
    if not _check_costs(context):
        return false
    # 再检查子节点
    return child.can_execute(context) if child else true


func _execute(context: Dictionary) -> STATUS:
    # 先扣除消耗
    _apply_costs(context)
    var result = await child.execute(context)
    return result


func _check_costs(context: Dictionary) -> bool:
    var caster = context.get("caster", null)
    if not caster:
        GASLogger.error("caster is null")
        return false
    var cost_value = _resolve_parameter(cost_value_param, context)
    var ability_resource_component : AbilityResourceComponent = caster.ability_resource_component

    if not ability_resource_component.has_enough_resources(cost_resource_id, cost_value):
        return false
    return true


func _apply_costs(context: Dictionary) -> void:
    var caster = context.get("caster", null)
    if not caster:
        GASLogger.error("caster is null")
        return
    var ability_resource_component : AbilityResourceComponent = caster.ability_resource_component
    ability_resource_component.consume_resources(cost_resource_id, cost_value)

