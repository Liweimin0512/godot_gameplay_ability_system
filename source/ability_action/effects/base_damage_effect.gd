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

	_get_context_config(context)

	for target in targets:
		_is_hit = _roll_hit(caster, target, context)
		var final_damage = _calculate_damage(caster, target, context)
		_apply_damage(target, final_damage, context)
	return STATUS.SUCCESS


## 从技能上下文获取配置并应用数据
func _get_context_config(context: Dictionary) -> void:
	var ability_config : Dictionary = _get_ability_config(context)
	damage_type = ability_config.get("damage_type", damage_type)
	is_indirect = ability_config.get("is_indirect", is_indirect)
	base_damage_attribute = ability_config.get("base_damage_attribute", base_damage_attribute)
	defense_attribute = ability_config.get("defense_attribute", defense_attribute)
	hit_rate_attribute = ability_config.get("hit_rate_attribute", hit_rate_attribute)
	dodge_rate_attribute = ability_config.get("dodge_rate_attribute", dodge_rate_attribute)
	min_hit_rate = ability_config.get("min_hit_rate", min_hit_rate)
	crit_rate_attribute = ability_config.get("crit_rate_attribute", crit_rate_attribute)
	crit_multiplier = ability_config.get("crit_multiplier", crit_multiplier)


## 伤害计算
func _calculate_damage(attacker: Node, defender: Node, context: Dictionary) -> float:
	if _is_hit == false:
		return 0.0

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
	})
	# 发送伤害计算前事件
	AbilitySystem.push_ability_event("damage_calculating", context.duplicate())
	return context.get("damage", final_damage)


## 应用伤害
func _apply_damage(defender: Node, damage: float, context: Dictionary) -> void:
	var ability_resource_component: AbilityResourceComponent = defender.ability_resource_component
	var health_resource : AbilityResource = ability_resource_component.get_resource("health")
	if not health_resource: 
		GASLogger.error("can not found health resource")
		return
	health_resource.consume(damage)
	context.merge({
		"is_hit": _is_hit,
		"is_critical": _is_critical,
		"damage": damage,
		"damage_type": damage_type,
		"is_indirect": is_indirect,
		"force_critical": false,
		"force_hit": false,
	}, true)
	AbilitySystem.push_ability_event("damage_completed", context.duplicate())


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
