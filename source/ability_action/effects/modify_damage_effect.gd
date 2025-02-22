extends EffectAction
class_name ModifyDamageEffect

## 处理伤害，通常只在受到伤害前或造成伤害后有效

## 修改类型
@export_enum("value", "percentage")
var modify_type : String = "value"
## 修改值
@export var modify_value : float = 0.1

func _perform_action(context: Dictionary = {}) -> STATUS:
	if context.has("damage") == false:
		return STATUS.FAILURE

	if modify_type == "value":
		context.damage = clamp(context.damage + modify_value, 0.0, INF)
	else:
		context.damage = clamp(context.damage * (1 + modify_value), 0.0, INF)

	return STATUS.SUCCESS


func _description_getter() -> String:
	var modify_name : String = "%" if modify_type == "percentage" else "点"
	var modify : String = "增加" if modify_value > 0 else "减少"
	return "使伤害{0} {1} {2}".format([modify, modify_value, modify_name])
