extends EffectAction
class_name ApplyAbilityEffect

## 对目标应用技能的效果

@export var ability : Ability

## 应用效果
func _perform_action(context: Dictionary = {}) -> STATUS:
	var target := context.get("target")
	if not target:
		GASLogger.error("apply ability action target is null")
		return STATUS.FAILURE
	var ability_component : AbilityComponent = target.ability_component
	ability_component.apply_ability(ability, context)
	GASLogger.info("对目标应用Ability:{0}".format([ability]))
	return STATUS.SUCCESS
