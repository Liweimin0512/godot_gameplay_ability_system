extends BaseDamageEffect
class_name HealEffect

@export var healing_value : float = 0.0 ## 治疗值

func _init() -> void:
	defense_attribute = &""  # 治疗不需要考虑防御


## 计算治疗量
func _calculate_damage(_source: Node, _target: Node, context: AbilityEffectContext) -> void:
	context.damage_data.healing = healing_value


## 应用治疗
func _apply_damage(defender: Node, context: AbilityEffectContext) -> void:
	var ability_resource_component: AbilityResourceComponent = defender.ability_resource_component
	var health_resource : AbilityResource = ability_resource_component.get_resource("health")
	if not health_resource: 
		GASLogger.error("can not found health resource")
		return
	health_resource.restore(context.damage_data.healing)
	AbilitySystem.push_ability_event("healing_completed", context)
