extends RefCounted
class_name AbilityDamage

## 技能系统产生的伤害

## 伤害计算相关常量
const BASE_DEFENSE_VALUE = 10.0  	# 防御标准值
const CRIT_MULTIPLIER = 2.0      	# 暴击伤害倍数

## 伤害类型枚举
enum DAMAGE_TYPE {
	PHYSICAL,    # 物理伤害
	MAGICAL,     # 魔法伤害
	PURE,        # 真实伤害
	HEAL         # 治疗
}

## 攻击方
var attacker: Node
## 防守方
var defender: Node
## 伤害类型
var damage_type: DAMAGE_TYPE
## 是否为间接伤害
var is_indirect: bool = false
## 伤害附带效果
var effect: AbilityEffectNode
## 必定暴击
var is_critical: bool = false
## 必定命中
var is_hit: bool = false

## 攻击力
var _attack_value: float = 0.0:
	get:
		return attacker.ability_attribute_component.get_attribute_value("攻击力")
## 防御力
var _defense_value: float = 0.0:
	get:
		return defender.ability_attribute_component.get_attribute_value("防御力")
## 免伤比
var _damage_reduction_ratio: float = 0.0:
	get:
		return _defense_value / (_defense_value + BASE_DEFENSE_VALUE)
## 暴击率
var _crit_chance: float = 0.0:
	get:
		return attacker.ability_attribute_component.get_attribute_value("暴击率")
## 命中
var _hit_chance: float = 0.0:
	get:
		return attacker.ability_attribute_component.get_attribute_value("命中率")
## 是否暴击
var _is_critical: bool = false:
	get:
		if is_critical:
			return true
		else:
			return randf() < _crit_chance
## 是否命中
var _is_hit: bool = true:
	get:
		if is_hit:
			return true
		else:
			return randf() < _hit_chance

## 百分比修改值
var _modify_percentage: float = 0.0
## 固定修改值
var _modify_value: float = 0.0

var damage_value: float = 0.0:
	get:
		# 未命中
		if not _is_hit: return 0.0		
		# 计算基础伤害
		var _damage_value = _attack_value * (1 - _damage_reduction_ratio)
		# 应用暴击
		if _is_critical:
			_damage_value *= CRIT_MULTIPLIER
		# 应用百分比修改
		_damage_value *= (1.0 + _modify_percentage)
		# 应用固定修改
		_damage_value += _modify_value
		return _damage_value

## 构造函数
func _init(
		p_attacker: Node = null, 
		p_defender: Node = null, 
		p_damage_type: DAMAGE_TYPE = DAMAGE_TYPE.PHYSICAL, 
		p_is_indirect: bool = false,
		p_effect: AbilityEffectNode = null) -> void:
	attacker = p_attacker
	defender = p_defender
	damage_type = p_damage_type
	is_indirect = p_is_indirect
	effect = p_effect

## 造成伤害
func apply_damage() -> void:
	if is_indirect:
		# 如果为间接伤害，则防守方受到伤害（触发受击事件）
		await defender.hurt(attacker, self)
	elif attacker:
		# 如果为直接伤害，则攻击方攻击（触发攻击事件）
		await attacker.hit(self)

## 应用伤害修饰器（比如增伤、减伤效果）
func apply_damage_modifier(modifier_type: String, value: float) -> void:
	match modifier_type:
		"percentage":  
			_modify_percentage += value
		"value":
			_modify_value += value

func _to_string() -> String:
	return "伤害信息： 攻击者：{0} 攻击力：{1}; 防御者{2} 防御力：{3}， 伤害值: {4}; {5}暴击".format([
		attacker, _attack_value, defender, _defense_value, 
		damage_value, "是" if _is_critical else "不是"
	])
