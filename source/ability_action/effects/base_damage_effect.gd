extends EffectAction
class_name BaseDamageEffect

## 基础暴击倍数
const BASE_CRIT_MULTIPLIER : float = 1.5

@export var attribute_component_name : StringName = "ability_attribute_component"
@export var ability_resource_component_name : StringName = "ability_resource_component"
@export var apply_damage_resource : StringName = "health"                   ## 伤害资源

@export var damage_type : StringName = "physical"                           ## 伤害类型
@export var is_indirect : bool = false                                      ## 是否为间接伤害

@export var base_damage_attribute : StringName = "attack"                   ## 基础伤害属性
@export var defense_attribute : StringName = "defense"                      ## 防御力属性
@export var hit_rate_attribute : StringName = "hit_rate"                    ## 命中率属性
@export var dodge_rate_attribute : StringName = "dodge_rate"                ## 闪避率属性
@export var min_hit_rate : float = 0.1                                      ## 最小命中率
@export var crit_rate_attribute : StringName = "crit_rate"                  ## 暴击率属性
@export var crit_multiplier : float = BASE_CRIT_MULTIPLIER                  ## 暴击倍数

var _is_critical : bool = false
var _is_hit : bool = false

func _perform_action(context: Dictionary) -> STATUS:
	var caster : Node = context.get("caster")
	var targets : Array[Node] = context.get("targets", [])

	if not _validate_entities(caster, targets):
		return STATUS.FAILURE

	for target in targets:
		_is_hit = _roll_hit(caster, target, context)
		_calculate_damage(caster, target, context)
		# 发送伤害计算前事件
		AbilitySystem.push_ability_event("damage_calculating", context.duplicate())
		_apply_damage(target, context)
		AbilitySystem.push_ability_event("damage_completed", context.duplicate())
	return STATUS.SUCCESS


## 伤害计算
func _calculate_damage(attacker: Node, defender: Node, context: Dictionary) -> void:
	if _is_hit == false:
		context.damage = 0
		return 

	var base_damage = _get_base_damage(attacker, context)
	var defense = _get_defense(defender)
	var critical_multiplier = _get_crit_multiplier(attacker, context)
	
	# 基础伤害计算
	var final_damage = max(base_damage - defense, base_damage * 0.1 ) * critical_multiplier

	context.merge({
			"damage": final_damage,
			"damage_type": damage_type,
			"caster": context.get("caster"),
			"target": context.get("target"),
			"ability": context.get("ability"),
		}, true)
	return 


## 应用伤害
func _apply_damage(defender: Node, context: Dictionary) -> void:
	var damage = context.get("damage", 0.0)
	var ability_resource_component: AbilityResourceComponent = defender.ability_resource_component
	var health_resource : AbilityResource = ability_resource_component.get_resource("health")
	if not health_resource: 
		GASLogger.error("can not found health resource")
		return
	health_resource.consume(damage)


## 获取基础伤害
func _get_base_damage(attacker: Node, context: Dictionary) -> float:
	# 基类提供基础实现，子类可以重写
	return _get_attribute_value(attacker, base_damage_attribute) * _get_damage_multiplier(context)


## 获取防御力
func _get_defense(defender: Node) -> float:
	return _get_attribute_value(defender, defense_attribute)


## 获取技能伤害倍数
func _get_damage_multiplier(context: Dictionary) -> float:
	var multiplier = context.get("damage_multiplier", 1.0)
	return multiplier


## 获取暴击伤害倍数
func _get_crit_multiplier(attacker: Node, context: Dictionary) -> float:
	var multiplier = 1.0
	
	# 检查暴击
	_is_critical = _roll_critical(attacker, context)
	if _is_critical:
		multiplier *= crit_multiplier
		
	return multiplier


## 判定是否命中
func _roll_hit(attacker: Node, defender: Node, context: Dictionary) -> bool:
	var force_hit = context.get("force_hit", false)
	if force_hit:
		return true
	
	var dodge_rate = _get_attribute_value(defender, dodge_rate_attribute)
	var hit_rate = max(min_hit_rate, _get_attribute_value(attacker, hit_rate_attribute) - dodge_rate)

	return randf() < hit_rate


## 判定是否暴击
func _roll_critical(attacker: Node, context: Dictionary) -> bool:
	var force_critical = context.get("force_critical", false)
	if force_critical:
		# 强制暴击
		return true

	var crit_chance = _get_attribute_value(attacker, crit_rate_attribute)
	return randf() < crit_chance


## 获取属性值
func _get_attribute_value(node: Node, attribute: StringName) -> float:
	var ability_attribute_component : AbilityAttributeComponent = node.get(attribute_component_name)
	if not ability_attribute_component:
		GASLogger.error("找不到属性组件, 无法获取属性值！")
		return 0.0
	return ability_attribute_component.get_attribute_value(attribute)


## 检查实体有效性
func _validate_entities(attacker: Node, targets: Array[Node]) -> bool:
	if not attacker or targets.is_empty():
		GASLogger.error("DealDamageEffectNode attacker or targets is empty!")
		return false
	return true
