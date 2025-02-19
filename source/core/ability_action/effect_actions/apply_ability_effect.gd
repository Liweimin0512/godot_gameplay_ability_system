extends EffectAction
class_name ApplyAbilityEffect

## 对目标应用技能的效果

@export var ability_id : StringName
@export var ability_context: Dictionary
var _ability : Ability

## 应用效果
func _perform_action(context: Dictionary = {}) -> STATUS:
	var target := context.get("target")
	if not target:
		GASLogger.error("Apply Ability Action target is null")
		return STATUS.FAILURE
	var ability_component : AbilityComponent = target.ability_component
	ability_context.merge(context, true)
	_ability = AbilitySystem.create_ability(ability_id)	
	ability_component.apply_ability(_ability, ability_context)
	GASLogger.info("对目标应用Ability:{0}".format([_ability]))
	return STATUS.SUCCESS

## 撤回效果
func _revoke_action(context: Dictionary) -> bool:
	var target := context.get("target")
	if not target:
		GASLogger.error("Apply Ability Action target is null")
		return false
	var ability_component : AbilityComponent = target.ability_component
	ability_component.remove_ability(_ability, ability_context)
	GASLogger.info("撤回目标应用Ability:{0}".format([_ability]))
	return true
