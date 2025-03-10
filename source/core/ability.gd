extends AbilityEffect
class_name Ability

## 技能基类，提供基础的技能系统功能

@export var restrictions: Array[AbilityRestriction]				## 限制器


## 从数据字典初始化
## [param data] 数据字典
func _init_from_data(data : Dictionary) -> void:
	super(data)
	for restriction_config in data.get("restrictions", []):
		var restriction : AbilityRestriction = AbilitySystem.create_restriction(restriction_config)
		add_restriction(restriction)


## 更新
func _update(delta : float) -> void:
	# 更新限制器
	for restriction in restrictions:
		restriction.update(delta)


## 能否执行
func _can_execute(context: AbilityEffectContext) -> bool:
	for restriction in restrictions:
		var can_use = restriction.can_execute(context)
		if not can_use:
			return false	
	return true


func _before_execute(context: AbilityEffectContext) -> void:
	for restriction in restrictions:
		restriction.before_ability_execute(context)


func _after_execute(context: AbilityEffectContext) -> void:
	for restriction in restrictions:
		restriction.after_ability_execute(context)


## 重置
## [TODO] 暂时只重置限制器, 而且没调用，后续优化
func _reset() -> void:
	for restriction in restrictions:
		restriction.reset()


## 添加限制器
func add_restriction(restriction: AbilityRestriction) -> AbilityRestriction:
	restrictions.append(restriction)
	return restriction
