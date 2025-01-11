extends Resource
class_name AbilityAttributeModifier

## 属性调节器

## 被修改的属性名称
@export var attribute_name: StringName  
## 修改类型，使用枚举值
@export_enum("value", "percentage", "absolute") var modify_type: String = "value"
## 修改数值
@export var value: float
## 来源
@export var source : Resource

func _init(attribute_name: StringName, modify_type: String, value: float) -> void:
	self.attribute_name = attribute_name
	self.modify_type = modify_type
	self.value = value

func _to_string() -> String:
	var s := "属性修改器：修改{0}属性".format([attribute_name])
	match modify_type:
		"value":
			s += "的值{0}".format([value])
		"percentage":
			s += "的百分比{0}%".format([value * 100])
		"absolute":
			s += "的绝对值{0}".format([value])
	return s
