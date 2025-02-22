extends BaseDamageEffect
class_name MultiTargetDamageEffect

## 多目标伤害效果

@export var damage_multipliers: Array[float] = []

func _get_context_config(context: Dictionary) -> void:
	super(context)
	var ability_config : Dictionary = _get_ability_config(context)
	damage_multipliers = ability_config.get("damage_multipliers", damage_multipliers)


func _get_damage_multiplier(context: Dictionary) -> float:
	var base_multiplier = super(context)
	var index = context.get("target_index", 0)
	
	if index < damage_multipliers.size():
		return base_multiplier * damage_multipliers[index]
	return base_multiplier
