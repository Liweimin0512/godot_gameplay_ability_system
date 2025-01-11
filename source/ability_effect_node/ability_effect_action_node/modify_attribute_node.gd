extends AbilityEffectActionNode
class_name ModifyAttributeNode

## 属性修改器的技能效果包装

## 属性修改器
@export var modifiers : Array[AbilityAttributeModifier]
## 属性修改器配置, 用于读取配置数据
@export var modifier_configs: Array
## 修改倍率
@export_storage var modify_multiplier: int = 1
## 技能上下文
var _original_context: Dictionary

func _perform_action(context: Dictionary = {}) -> STATUS:
	_original_context = context.duplicate()
	var target = context.get("target")
	if not target:
		GASLogger.error("ModifyAttributeNode target is null")
		return STATUS.FAILURE
	var attribute_component: AbilityAttributeComponent = target.get("ability_attribute_component")
	if modifiers.is_empty():
		for modifier_config in modifier_configs:
			var modifier : AbilityAttributeModifier = AbilityAttributeModifier.new(
				modifier_config.get("attribute_name"),
				modifier_config.get("modify_type"),
				modifier_config.get("value"),
			)
			modifiers.append(modifier)
	for modifier : AbilityAttributeModifier in modifiers:
		modifier.value *= modify_multiplier
		attribute_component.apply_attribute_modifier(modifier)
		GASLogger.info("对目标应用属性修改器：{0}".format([modifier]))
	return STATUS.SUCCESS

## 移除效果
func _revoke_action() -> STATUS:
	var target = _original_context.get("target")
	if not target:
		GASLogger.error("ModifyAttributeNode target is null")
		return STATUS.FAILURE
	var attribute_component: AbilityAttributeComponent = target.get("ability_attribute_component")
	for modifier : AbilityAttributeModifier in modifiers:
		attribute_component.remove_attribute_modifier(modifier)
		GASLogger.info("移除效果：对目标应用属性修改器：{0}".format([modifier]))
	return STATUS.SUCCESS

func _description_getter() -> String:
	var s : String = ""
	for modifier in modifiers:
		s += modifier.to_string()
	return s
