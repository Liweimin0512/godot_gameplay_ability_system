extends BaseDamageEffect
class_name PureDamageEffect

# 真实伤害忽略防御力
func _calculate_damage(source: Node, _target: Node, context: AbilityEffectContext) -> void:
	var base_damage = source.get_attribute(base_damage_attribute)
	var multiplier = _get_damage_multiplier(context)
	context.damage_data.damage = base_damage * multiplier
