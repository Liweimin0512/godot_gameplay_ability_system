extends BaseDamageEffect
class_name HealEffect

@export var healing_value : float = 0.0 ## 治疗值

func _init() -> void:
    attack_attribute = &"healing_power"
    defense_attribute = &""  # 治疗不需要考虑防御

## 计算治疗量
func _calculate_damage(source: Node, _target: Node, context: Dictionary) -> float:
    return healing_value


## 应用治疗
func _apply_damage(defender: Node, damage: float, context: Dictionary) -> void:
    context.healing = amount
	var ability_resource_component: AbilityResourceComponent = defender.ability_resource_component
	var health_resource : AbilityResource = ability_resource_component.get_resource("health")
	if not health_resource: 
		GASLogger.error("can not found health resource")
		return
	health_resource.restore(damage)
	context.merge({
		"is_hit": _is_hit,
		"is_critical": _is_critical,
		"damage": damage,
		"damage_type": damage_type,
		"is_indirect": is_indirect,
		"force_critical": false,
		"force_hit": false,
	}, true)
	AbilitySystem.push_ability_event("healing_completed", context.duplicate())