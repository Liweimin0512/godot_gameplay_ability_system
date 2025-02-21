extends Resource
class_name AbilityRestriction

## 技能限制器基类，定义能力限制接口

var can_use_reason : String = ""

func _init(_config : Dictionary = {}) -> void:
    pass

func can_use(context: Dictionary) -> bool:
    return true

## 技能使用后调用
func on_ability_used(context: Dictionary) -> void:
    pass