extends Resource
class_name AbilityCost

## 技能消耗

## 判断能否消耗
func can_cost(context: Dictionary) -> bool:
	return true

## 消耗
func cost(context: Dictionary) -> void:
	pass
