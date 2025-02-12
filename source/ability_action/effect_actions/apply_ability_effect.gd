extends EffectAction
class_name ApplyAbilityEffect

## 对目标应用技能的效果

@export var ability : Ability
@export var ability_context: Dictionary

## 应用效果
func _perform_action(context: Dictionary = {}) -> STATUS:
	var target := context.get("target")
	if not target:
		GASLogger.error("Apply Ability Action target is null")
		return STATUS.FAILURE
	var ability_component : AbilityComponent = target.ability_component
	ability_context.merge(context, true)
	ability_component.apply_ability(ability, ability_context)
	GASLogger.info("对目标应用Ability:{0}".format([ability]))
	return STATUS.SUCCESS
