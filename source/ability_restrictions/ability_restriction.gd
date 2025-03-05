extends Resource
class_name AbilityRestriction


var can_use_reason : String = ""

func can_execute(context: AbilityEffectContext) -> bool:
	return true

## 技能使用前调用
func before_ability_execute(context: AbilityEffectContext) -> void:
	pass

## 技能使用后调用
func after_ability_execute(context: AbilityEffectContext) -> void:
	pass

## 更新
func update(delta : float) -> void:
	pass
