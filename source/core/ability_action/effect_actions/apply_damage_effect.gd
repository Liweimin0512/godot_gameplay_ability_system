extends EffectAction
class_name ApplyDamageEffect

## 处理伤害


## 伤害倍数修正值
@export var damage_percentage_multiplier: float = 1.0
## 伤害值修正值
@export var damage_value_multiplier: float = 0.0
## 伤害倍数修正值数组
@export var damage_percentage_multiplier_array: Array[float] = []
## 伤害值修正值数组
@export var damage_value_multiplier_array: Array[float] = []
## 伤害类型
@export var damage_type: AbilityDamage.DAMAGE_TYPE = AbilityDamage.DAMAGE_TYPE.PHYSICAL
## 是否为间接伤害
@export var is_indirect: bool = false

func _init() -> void:
	action_name = "apply_damage"

func _perform_action(context: Dictionary) -> STATUS:
	if context.get("ability").ability_name == "漩涡约束":
		pass
	var repeat_index = context.get("repeat_index", null)
	if repeat_index != null:
		damage_percentage_multiplier_array = context.get("damage_percentage_multiplier_array", damage_percentage_multiplier_array)
		damage_value_multiplier_array = context.get("damage_value_multiplier_array", damage_value_multiplier_array)
		damage_percentage_multiplier = damage_percentage_multiplier_array[repeat_index - 1]
		damage_value_multiplier = damage_value_multiplier_array[repeat_index - 1]
	else:
		damage_percentage_multiplier = context.get("damage_multiplier", damage_percentage_multiplier)
		damage_value_multiplier = context.get("damage_value_multiplier", damage_value_multiplier)
	var caster : Node = context.get("caster")
	var targets : Array = context.get("targets", [])	
	if targets.is_empty():
		GASLogger.error("DealDamageEffectNode targets is empty!")
		return STATUS.FAILURE
	damage_type = context.get("damage_type", damage_type)
	is_indirect = context.get("is_indirect", is_indirect)
	for target in targets:
		var damage : AbilityDamage = AbilityDamage.new(caster, target, damage_type, damage_percentage_multiplier - 1, damage_value_multiplier, is_indirect)
		damage.apply_damage()
		AbilitySystem.push_ability_event("damage_completed", {
			"ability": context.get("ability"),
			"caster": caster,
			"target": target,
			"damage_type": damage_type,
			"damage_value": damage.damage_value,
			"is_indirect": is_indirect
		})
	return STATUS.SUCCESS


func _validate_property(property: Dictionary) -> void:
	pass
