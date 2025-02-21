extends BaseDamageEffect
class_name PercentHealthDamageEffect

@export var health_percentage: float = 0.1

## 从技能上下文获取配置并应用数据
func _get_context_config(context: Dictionary) -> void:
    super(context)
    var ability_config : Dictionary = _get_ability_config(context)
    health_percentage = ability_config.get("health_percentage", health_percentage)

func _calculate_damage(source: Node, target: Node, context: Dictionary) -> float:
    var max_health = _get_attribute_value(target, "health")
    var base_damage = max_health * health_percentage
    return base_damage