extends EffectAction
class_name ApplyTagEffect

## 对目标应用某种标签

@export_enum("stun") var tag_type: String = "stun"

func _perform_action(context: Dictionary = {}) -> STATUS:
	var target = context.get("target")
	if not target:
		GASLogger.error("ApplyTagEffectNode target is null")
		return STATUS.FAILURE
	target.add_to_group(tag_type)
	return STATUS.SUCCESS

## 移除效果
func _revoke_action(context: Dictionary = {}) -> bool:
	var target = context.get("target")
	if not target:
		GASLogger.error("ApplyTagEffectNode target is null")
		return false
	target.remove_from_group(tag_type)
	return true

func _description_getter() -> String:
	var _tag_name : String
	match tag_type:
		"stun":
			_tag_name = "眩晕"
	return "对目标释放{0}".format([_tag_name])
