extends Node
class_name AbilityAttributeComponent

## 技能属性组件

## 技能属性集
@export var _ability_attributes : Dictionary[StringName, AbilityAttribute]

## 属性变化时发出
signal attribute_changed(atr_name: StringName, value: float)

## 组件初始化
func initialization(attribute_set: Array[AbilityAttribute] = []) -> void:
	for attribute : AbilityAttribute in attribute_set:
		if not _ability_attributes.has(attribute.attribute_name):
			_ability_attributes[attribute.attribute_name] = attribute

## 是否存在属性
func has_attribute(atr_name: StringName) -> bool:
	return _ability_attributes.has(atr_name)

## 获取属性
func get_attribute(atr_name: StringName) -> AbilityAttribute:
	var attribute : AbilityAttribute = _ability_attributes.get(atr_name)
	if attribute:
		return attribute
	return null

## 获取属性值
func get_attribute_value(atr_name : StringName) -> float:
	var attribute := get_attribute(atr_name)
	if attribute:
		return attribute.attribute_value
	#assert(false, "找不到需要的属性："+ atr_name)
	push_error("找不到需要的属性：" + atr_name)
	return -1

## 增加属性修改器
func apply_attribute_modifier(modifier: AbilityAttributeModifier):
	var attribute: AbilityAttribute = get_attribute(modifier.attribute_name)
	assert(attribute, "无效的属性：" + attribute.to_string())
	attribute.add_modifier(modifier)
	attribute_changed.emit(modifier.attribute_name, get_attribute_value(modifier.attribute_name))
	
## 移除属性修改器
func remove_attribute_modifier(modifier: AbilityAttributeModifier):
	var attribute: AbilityAttribute = get_attribute(modifier.attribute_name)
	assert(attribute, "无效的属性：" + attribute.to_string())
	attribute.remove_modifier(modifier)
	attribute_changed.emit(modifier.attribute_name, get_attribute_value(modifier.attribute_name))

## 获取属性的所有修改器
func get_attribute_modifiers(attribute_name: StringName) -> Array[AbilityAttributeModifier]:
	var attribute := get_attribute(attribute_name)
	if attribute:
		return attribute.get_modifiers()
	return []
