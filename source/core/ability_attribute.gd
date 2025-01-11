extends Resource
class_name AbilityAttribute

## 技能属性类，代表技能依赖的一切属性，包括但不限于： 生命值、攻击力、防御力等

## 属性名称，相当于ID
@export var attribute_name : StringName
## 属性值
var attribute_value: float:
	get:
		return (_base_value + _value_modify) * (1 + _percentage_modify) + _absolute_modify
	set(value):
		assert(false, "只读属性，无法赋值")
## 属性基础值
@export var _base_value: float  # 基础值
## 数值修改值
var _value_modify : float = 0
## 百分比修改值
var _percentage_modify: float = 0
## 绝对值修改值
var _absolute_modify : float = 0
## 属性修改器列表
var _modifiers: Array[AbilityAttributeModifier] = []

signal attribute_value_changed(value: float)

func _init(atr_name : StringName = "", base: float = 0) -> void:
	attribute_name = atr_name
	_base_value = base
	_value_modify = 0
	_percentage_modify = 0
	_absolute_modify = 0

## 修改属性
func _modify(modify_type: String, value: float) -> void:
	match modify_type:
		"value":
			_value_modify += value
		"percentage":
			_percentage_modify += value
		"absolute":
			_absolute_modify = value
	attribute_value_changed.emit(attribute_value)

## 添加修改器
func add_modifier(modifier: AbilityAttributeModifier) -> void:
	_modifiers.append(modifier)
	_modify(modifier.modify_type, modifier.value)

## 移除修改器
func remove_modifier(modifier: AbilityAttributeModifier) -> void:
	_modifiers.erase(modifier)
	_modify(modifier.modify_type, modifier.value * -1)

## 获取所有修改器
func get_modifiers() -> Array[AbilityAttributeModifier]:
	return _modifiers

func _to_string() -> String:
	return "{attribute_name} : {attribute_value}".format({
		"attribute_name": attribute_name,
		"attribute_value": attribute_value
	})
