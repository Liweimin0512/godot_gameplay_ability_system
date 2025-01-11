extends Resource
class_name AbilityAttribute

## 技能属性类，代表技能依赖的一切属性，包括但不限于： 生命值、攻击力、防御力等

## 属性ID
@export var attribute_id : StringName
## 属性名称
@export var attribute_name : StringName
## 属性基础值
@export var _base_value: float
## 属性成长值
@export var _growth_value: float = 0
## 属性等级
@export var attribute_level: int = 1:
	set(value):
		attribute_level = value
		_update_value()
## 属性修改器列表
var _modifiers: Array[AbilityAttributeModifier] = []
## 属性值
var attribute_value: float:
	get:
		return _value
	set(value):
		GASLogger.error("只读属性，无法赋值")
## 属性值
var _value: float:
	set(value):
		_value = value
		attribute_value_changed.emit(value)

signal attribute_value_changed(value: float)

func _init(atr_name : StringName = "", base: float = 0) -> void:
	attribute_name = atr_name
	_base_value = base

## 修改属性
func _update_value() -> void:
	var _value_modify : float = 0
	var _percentage_modify: float = 0
	var _absolute_modify : float = 0
	for modifier in _modifiers:
		match modifier.modify_type:
			"value":
				_value_modify += modifier.value
			"percentage":
				_percentage_modify += modifier.value
			"absolute":
				_absolute_modify = modifier.value
	_value = (_base_value + _growth_value * attribute_level + _value_modify) * (1 + _percentage_modify) + _absolute_modify

## 添加修改器
func add_modifier(modifier: AbilityAttributeModifier) -> void:
	_modifiers.append(modifier)
	_update_value()

## 移除修改器
func remove_modifier(modifier: AbilityAttributeModifier) -> void:
	_modifiers.erase(modifier)
	_update_value()

## 获取所有修改器
func get_modifiers() -> Array[AbilityAttributeModifier]:
	return _modifiers

func _to_string() -> String:
	return "{attribute_name} : {attribute_value}".format({
		"attribute_name": attribute_name,
		"attribute_value": attribute_value
	})
