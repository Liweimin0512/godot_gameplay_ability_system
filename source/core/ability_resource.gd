extends Resource
class_name AbilityResource

## 技能消耗的资源，比如魔法值、怒气值、能量，设置是生命值

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
## 所对应的属性名称
@export var attribute_name : StringName
## 属性颜色，显示在进度条上
@export var resource_color : Color = Color.RED
## 属性进度条高度
@export var size_y : int = 10

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

func initialization(attribute_component: AbilityAttributeComponent) -> void:
	if not attribute_name.is_empty():
		_attribute = attribute_component.get_attribute(attribute_name)
		max_value = round(_attribute.attribute_value)
		current_value = max_value
		_attribute.attribute_value_changed.connect(
			func(value: int) -> void:
				max_value = value
				current_value = max_value
		)
	if ability_resource_name.is_empty():
		ability_resource_name = _get_resource_name()

## 消耗
func consume(amount: int) -> bool:
	if current_value >= amount:
		current_value -= amount
		GASLogger.debug("技能资源消耗：{0} 消耗 {1} 点，当前值： {2} / {3} ".format([
			ability_resource_name, amount, current_value, max_value
		]))
		return true
	return false
	
## 恢复
func restore(amount: int) -> void:
	current_value += amount
	current_value = min(current_value, max_value)
	GASLogger.debug("技能资源恢复：{0} 恢复 {1} 点，当前值： {2} / {3}".format([
		ability_resource_name, amount, current_value, max_value
	]))

func _get_resource_name() -> StringName:
	return ""
