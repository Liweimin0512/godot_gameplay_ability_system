extends EffectAction
class_name ApplyAbilityEffect

## 对目标应用技能的效果

@export var apply_id : StringName

var _ability : Ability
var _targets : Array[Node]

## 应用效果
func _perform_action(context: AbilityEffectContext) -> STATUS:
	var target := context.get("target")
	if not target:
		GASLogger.error("Apply Ability Action target is null")
		return STATUS.FAILURE
	var ability_component : AbilityComponent = target.ability_component
	_ability = AbilitySystem.create_ability(apply_id)
	ability_component.apply_ability(_ability, context)
	return STATUS.SUCCESS


## 撤回效果
func _revoke() -> bool:
	for target in _targets:
		var ability_component : AbilityComponent = target.ability_component
		ability_component.remove_ability(_ability)
	GASLogger.info("撤回目标应用Ability:{0}".format([_ability]))
	return true
