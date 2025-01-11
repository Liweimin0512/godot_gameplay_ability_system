extends AbilityResource
class_name ManaResource

## 魔法值资源
## 魔法值是一个属性，在属性改变时同时设置当前资源的最大值
## 随时间（回合）自然恢复

## 初始化
func initialization(attribute_component: AbilityAttributeComponent) -> void:
	attribute_name = "魔法值"
	super(attribute_component)

## 消耗
func consume(amount: int) -> bool:
	var ok := super(amount)
	if not ok:
		current_value = 0
	return ok

## 每回合自动恢复
func on_turn_start(_context: Dictionary) -> void:
	var amount = max_value * 0.1
	restore(amount)

func _get_resource_name() -> StringName:
	return "魔法值"
