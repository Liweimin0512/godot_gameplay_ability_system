@tool
extends BaseDamageEffect
class_name MultiTargetDamageEffect

## 多目标伤害效果，不同目标可以有不同的伤害系数

## 每个目标的伤害系数，如果目标索引超出数组范围，则使用基础系数
@export var damage_multipliers: Array[float] = []

func _get_damage_multiplier(context: AbilityEffectContext) -> float:
	var base_multiplier = super(context)
	if context.target_index < damage_multipliers.size():
		return base_multiplier * damage_multipliers[context.target_index]
	return base_multiplier
