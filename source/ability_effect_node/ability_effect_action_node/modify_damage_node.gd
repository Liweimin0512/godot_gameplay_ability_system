extends AbilityEffectActionNode
class_name ModifyDamageEffectNode

## 处理伤害，通常只在受到伤害前或造成伤害后有效

## 修改类型
@export_enum("value", "percentage")
var modify_type : String = "value"
## 修改值
@export var modify_value : float = 0.1
## 必定暴击
@export var is_critical : bool = false
## 必定命中
@export var is_hit : bool = false

func _perform_action(context: Dictionary = {}) -> STATUS:
	var target = context.get("target")
	if not target:
		GASLogger.error("ModifyDamageEffectNode target is null")
		return STATUS.FAILURE
	var damage : AbilityDamage = context.get("damage")
	damage.apply_damage_modifier(modify_type, modify_value)
	damage.is_critical = is_critical
	damage.is_hit = is_hit
	return STATUS.SUCCESS

func _description_getter() -> String:
	var modify_name : String = "%" if modify_type == "percentage" else "点"
	var modify : String = "增加" if modify_value > 0 else "减少"
	return "使伤害{0} {1} {2}".format([modify, modify_value, modify_name])
