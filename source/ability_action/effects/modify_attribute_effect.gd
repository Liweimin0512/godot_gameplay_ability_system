extends EffectAction
class_name ModifyAttributeEffect

## 属性修改器的技能效果包装

## 属性ID
@export var attribute_id: String
## 属性修改类型
@export_enum("value", "percentage", "absolute") var modify_type: String
## 属性修改值
@export var modify_value: float

var _targets : Array[Node] = []
var _modifier : AbilityAttributeModifier = null


func _perform_action(context: Dictionary = {}) -> STATUS:
	_targets = context.get("targets")
	for target in _targets:
		var attribute_component: AbilityAttributeComponent = target.get("ability_attribute_component")
		if not attribute_component:
			GASLogger.error("ModifyAttributeNode attribute_component is null")
			continue
		_modifier = AbilityAttributeModifier.new(attribute_id, modify_type, modify_value)
		attribute_component.apply_attribute_modifier(_modifier)
	return STATUS.SUCCESS


## 移除效果
func _revoke() -> bool:
	for target in _targets:
		var attribute_component: AbilityAttributeComponent = target.get("ability_attribute_component")
		if not attribute_component:
			GASLogger.error("ModifyAttributeNode attribute_component is null")
			continue
		attribute_component.remove_attribute_modifier(_modifier)
	return true