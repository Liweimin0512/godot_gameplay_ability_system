extends AbilityResource
class_name HealthResource

## 生命值，适合邪恶、残暴单位
## 最大值对应生命值属性，属性概念时需要更新最大值


func _initialization(attribute_component: AbilityAttributeComponent) -> void:
	ability_resource_id = "health"
	ability_resource_name = "生命值"

## 消耗
func consume(amount: int) -> bool:
	var ok := super(amount)
	if not ok:
		current_value = 0
	return ok

## 应用伤害
func apply_damage(damage: AbilityDamage) -> void:
	consume(damage.damage_value)

func _get_resource_name() -> StringName:
	return "生命值"
