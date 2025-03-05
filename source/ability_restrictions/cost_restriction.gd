extends AbilityRestriction
class_name CostRestriction

## 技能消耗


func can_execute(context: AbilityEffectContext) -> bool:
	return _can_cost(context)

func before_ability_execute(context: AbilityEffectContext) -> void:
	_cost(context)

## 判断能否消耗，子类实现
func _can_cost(_context: AbilityEffectContext) -> bool:
	return true

## 消耗，子类实现
func _cost(_context: AbilityEffectContext) -> void:
	pass
