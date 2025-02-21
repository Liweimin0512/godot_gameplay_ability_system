extends BaseDamageEffect
class_name PureDamageEffect

# 真实伤害忽略防御力
func _calculate_damage(source: Node, _target: Node, context: Dictionary) -> float:
    var attack = source.get_attribute(attack_attribute)
    var multiplier = _get_damage_multiplier(context)
    return attack * multiplier