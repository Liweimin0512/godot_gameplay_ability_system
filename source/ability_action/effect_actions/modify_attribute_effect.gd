extends EffectAction
class_name ModifyAttributeEffect

## 属性修改器的技能效果包装

## 属性ID
@export var attribute_id: String
## 属性修改类型
@export_enum("value", "percentage", "absolute") var modify_type: String
## 属性修改值
@export var modify_value: float
## 技能上下文
var _original_context: Dictionary
## 属性修改器
var _modifier: AbilityAttributeModifier

func _perform_action(context: Dictionary = {}) -> STATUS:
	_original_context = context.duplicate()
	var target = context.get("target")
	if not target:
		GASLogger.error("ModifyAttributeNode target is null")
		return STATUS.FAILURE
	var attribute_component: AbilityAttributeComponent = target.get("ability_attribute_component")
	_modifier = AbilityAttributeModifier.new(attribute_id, modify_type, modify_value)
	attribute_component.apply_attribute_modifier(_modifier)
	GASLogger.info("对目标应用属性修改器：{0}".format([_modifier]))
	return STATUS.SUCCESS

## 移除效果
func _revoke_action(context: Dictionary) -> bool:
	_original_context = context.duplicate(true)
	var target = _original_context.get("target")
	if not target:
		GASLogger.error("ModifyAttributeNode target is null")
		return false
	var attribute_component: AbilityAttributeComponent = target.get("ability_attribute_component")
	attribute_component.remove_attribute_modifier(_modifier)
	GASLogger.info("移除效果：对目标应用属性修改器：{0}".format([_modifier]))
	return true

func _description_getter() -> String:
	return _modifier.to_string()
