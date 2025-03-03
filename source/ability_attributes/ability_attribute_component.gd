extends Node
class_name AbilityAttributeComponent

## 技能属性组件

## 技能属性集
@export var _ability_attributes : Dictionary[StringName, AbilityAttribute]

## 属性变化时发出
signal attribute_changed(attribute_id: StringName, value: float)

func setup(attribute_set : Array[AbilityAttribute]) -> void:
	for attribute : AbilityAttribute in attribute_set:
		add_attribute(attribute)

## 是否存在属性
func has_attribute(attribute_id: StringName) -> bool:
	return _ability_attributes.has(attribute_id)

## 获取属性
func get_attribute(attribute_id: StringName) -> AbilityAttribute:
	return _ability_attributes.get(attribute_id, null)

## 获取属性值
func get_attribute_value(attribute_id: StringName) -> float:
	var attribute := get_attribute(attribute_id)
	if attribute:
		return attribute.attribute_value
	GASLogger.error("找不到属性：" + attribute_id)
	return 0

## 添加属性
func add_attribute(attribute: AbilityAttribute) -> void:
	if not attribute:
		GASLogger.error("属性为空")
		return
	if _ability_attributes.has(attribute.attribute_id):
		GASLogger.error("属性已存在：" + attribute.attribute_id)
		return
	_ability_attributes[attribute.attribute_id] = attribute
	if not attribute.attribute_value_changed.is_connected(_on_attribute_value_changed):
		attribute.attribute_value_changed.connect(_on_attribute_value_changed)

## 移除属性
func remove_attribute(attribute_id: StringName) -> void:
	var attribute := get_attribute(attribute_id)
	if not attribute:
		GASLogger.error("属性不存在：" + attribute_id)
		return
	_ability_attributes.erase(attribute_id)
	if attribute and attribute.attribute_value_changed.is_connected(_on_attribute_value_changed):
		attribute.attribute_value_changed.disconnect(_on_attribute_value_changed)

## 增加属性修改器
func apply_attribute_modifier(modifier: AbilityAttributeModifier):
	var attribute: AbilityAttribute = get_attribute(modifier.attribute_id)
	assert(attribute, "无效的属性：" + attribute.to_string())
	attribute.add_modifier(modifier)
	attribute_changed.emit(modifier.attribute_id, get_attribute_value(modifier.attribute_id))
	
## 移除属性修改器
func remove_attribute_modifier(modifier: AbilityAttributeModifier):
	var attribute: AbilityAttribute = get_attribute(modifier.attribute_id)
	assert(attribute, "无效的属性：" + attribute.to_string())
	attribute.remove_modifier(modifier)
	attribute_changed.emit(modifier.attribute_id, get_attribute_value(modifier.attribute_id))

## 获取属性的所有修改器
func get_attribute_modifiers(attribute_id: StringName) -> Array[AbilityAttributeModifier]:
	return get_attribute(attribute_id).get_modifiers()

static func get_attribute_component(owner : Node) -> AbilityAttributeComponent:
	var component = owner.get("ability_attribute_component")
	if not component:
		component = owner.get_node_or_null("AbilityAttributeComponent")
	return component

## 属性值改变时
func _on_attribute_value_changed(attribute_id: StringName, value: float) -> void:
	attribute_changed.emit(attribute_id, value)
