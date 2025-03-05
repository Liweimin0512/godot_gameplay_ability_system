extends EffectAction
class_name ApplyTagEffect

## 对目标应用某种标签

@export_enum("stun") var tag_type: String = "stun"
var _targets : Array[Node]


func _perform_action(context: AbilityEffectContext) -> STATUS:
	_targets = context.get_all_targets()
	for target in _targets:
		var ability_component = target.ability_component
		if not ability_component:
			GASLogger.error("ApplyTagEffectNode target {0} has no AbilityComponent".format([target]))
			continue
		ability_component.add_ability_tag(tag_type)
	return STATUS.SUCCESS


## 移除效果
func _revoke() -> bool:
	for target in _targets:
		var ability_component = target.ability_component
		if not ability_component:
			GASLogger.error("ApplyTagEffectNode target {0} has no AbilityComponent".format([target]))
			continue
		ability_component.remove_ability_tag(tag_type)
	return true


func _description_getter() -> String:
	var tag_name : String
	match tag_type:
		"stun":
			tag_name = "眩晕"
	return "对目标释放{0}".format([tag_name])
