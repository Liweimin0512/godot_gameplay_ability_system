extends Resource
class_name AbilityResource

## 技能消耗的资源，比如魔法值、怒气值、能量，设置是生命值

## 资源ID
@export var ability_resource_id : StringName
## 资源名
@export var ability_resource_name : StringName
## 当前值
@export_storage var current_value: int:
	set(value):
		current_value = value
		current_value_changed.emit(value)
## 最大值
@export var max_value: int:
	set(value):
		max_value = value
		max_value_changed.emit(current_value, max_value)
## 所对应的属性ID
@export var attribute_id : StringName

## 是否为空的
var is_empty : bool:
	get:
		return current_value == 0
## 是否为满的
var is_full : bool:
	get:
		return current_value == max_value
## 对应属性
var _attribute : AbilityAttribute

## 当前值改变时发射
signal current_value_changed(value : int)
## 最大值改变时发射
signal max_value_changed(value: int, max_value: int)

## 初始化
func initialization(attribute_component: AbilityAttributeComponent) -> void:
	_initialization(attribute_component)
	if not attribute_id.is_empty():
		_attribute = attribute_component.get_attribute(attribute_id)
		max_value = round(_attribute.attribute_value)
		current_value = max_value
		_attribute.attribute_value_changed.connect(_on_attribute_value_changed)

## 消耗
func consume(amount: int) -> bool:
	if current_value >= amount:
		current_value -= amount
		GASLogger.debug("技能资源消耗：{0} 消耗 {1} 点，当前值： {2} / {3} ".format([
			ability_resource_id, amount, current_value, max_value
		]))
		return true
	return false
	
## 恢复
func restore(amount: int) -> void:
	current_value += amount
	current_value = min(current_value, max_value)
	GASLogger.debug("技能资源恢复：{0} 恢复 {1} 点，当前值： {2} / {3}".format([
		ability_resource_id, amount, current_value, max_value
	]))

## 初始化，子类实现
func _initialization(attribute_component: AbilityAttributeComponent) -> void:
	pass

## 属性值改变时
func _on_attribute_value_changed(value: float) -> void:
	max_value = value
	current_value = max_value

func _to_string() -> String:
	return "资源：{0} 当前值：{1} / {2}".format([ability_resource_id, current_value, max_value])
