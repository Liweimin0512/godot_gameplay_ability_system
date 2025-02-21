extends Resource
class_name AbilityRestriction


var can_use_reason : String = ""

func _init(_config : Dictionary = {}) -> void:
	pass

func can_execute(context: Dictionary) -> bool:
	return true

## 技能使用前调用
func before_ability_execute(context: Dictionary) -> void:
	pass

## 技能使用后调用
func after_ability_execute(context: Dictionary) -> void:
	pass
