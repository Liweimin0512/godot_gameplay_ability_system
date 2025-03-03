extends BaseDamageEffect
class_name PercentHealthDamageEffect

@export var health_percentage: float = 0.1

func _calculate_damage(source: Node, target: Node, context: AbilityContext) -> void:
	var max_health = _get_attribute_value(target, "health")
	var base_damage = max_health * health_percentage
	context.damage_data.damage = base_damage
