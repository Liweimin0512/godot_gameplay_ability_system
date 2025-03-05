@tool
extends Resource
class_name AbilityEffectContext

## 技能效果上下文，包含技能执行过程中的所有相关数据

# 基础属性
var ability: Ability  # 技能实例
var caster: Node  # 施法者
var target: Node  # 主要目标
var additional_targets: Array = []  # 额外目标
## 触发者，可能与施法者不同
## 例如：当一个角色使用道具触发效果时，角色是触发者但道具时施法者
## 在连锁反应中，A角色触发了B角色的被动技能，这时候A是触发者，B是施法者
## 在队友互动技能中，一个角色可能触发另一个角色的技能释放
var instigator: Node  

# 目标相关
var target_index: int = 0  # 当前目标在目标列表中的索引
var total_targets: int = 0  # 目标列表的总数

# 目标组相关
## 可用的目标组，key为组名（如"allies"、"enemies"等），value为目标数组
var target_groups: Dictionary = {}

# 时间相关
var creation_time: float  # 创建时间
var last_update_time: float  # 最后更新时间
var delta_time: float  # 当前帧时间

var damage_data: DamageData

# 重复执行相关
var repeat_index: int = 0  # 当前重复执行的索引，从1开始

func _init() -> void:
	creation_time = Time.get_unix_time_from_system()
	last_update_time = creation_time
	damage_data = DamageData.new()

## 更新上下文
func update(delta: float) -> void:
	delta_time = delta
	last_update_time = Time.get_unix_time_from_system()

# 目标操作

func add_target(target: Node) -> void:
	if not additional_targets.has(target):
		additional_targets.append(target)

func remove_target(target: Node) -> void:
	additional_targets.erase(target)

func get_all_targets() -> Array[Node]:
	var targets: Array[Node] = []
	if target:
		targets.append(target)
	targets.append_array(additional_targets)
	return targets

# 目标组操作

func add_target_group(group_name: StringName, targets: Array[Node]) -> void:
	target_groups[group_name] = targets

func get_target_group(group_name: StringName) -> Array[Node]:
	return target_groups.get(group_name, [])

# 创建副本
func create_copy() -> AbilityEffectContext:
	var copy := AbilityEffectContext.new()
	copy.ability = ability
	copy.caster = caster
	copy.target = target
	copy.additional_targets = additional_targets.duplicate()
	copy.instigator = instigator
	copy.target_groups = target_groups.duplicate()
	copy.damage_data.copy_from(damage_data)
	copy.repeat_index = repeat_index
	copy.target_index = target_index
	copy.total_targets = total_targets
	return copy

func to_dictionary() -> Dictionary:
	return {
		"ability": ability,
		"caster": caster,
		"target": target,
		"additional_targets": additional_targets,
		"instigator": instigator,
		"target_groups": target_groups,
		"damage_data": damage_data.to_dictionary(),
		"repeat_index": repeat_index,
		"target_index": target_index,
		"total_targets": total_targets,
	}

static func from_dictionary(dictionary: Dictionary) -> AbilityEffectContext:
	var context := AbilityEffectContext.new()
	context.caster = dictionary.get("caster", null)
	context.ability = dictionary.get("ability", null)
	context.target = dictionary.get("target", null)
	var a_targets : Array[Node] = []
	context.additional_targets = dictionary.get("additional_targets", a_targets)
	context.instigator = dictionary.get("instigator", null)
	context.target_groups = dictionary.get("target_groups", {})
	context.damage_data = DamageData.from_dictionary(dictionary.get("damage_data", {}))
	context.repeat_index = dictionary.get("repeat_index", 0)
	context.target_index = dictionary.get("target_index", 0)
	context.total_targets = dictionary.get("total_targets", 0)
	return context

## 伤害数据
class DamageData:
	var damage: float = 0.0  				# 伤害值
	var healing: float = 0.0  				# 治疗值
	var damage_type: StringName  			# 伤害类型
	var force_critical: bool = false  		# 强制暴击
	var force_hit: bool = false  			# 强制命中
	var is_critical: bool = false  			# 是否暴击
	var is_hit: bool = false  				# 是否命中
	var is_indirect: bool = false  			# 是否间接伤害
	
	func _init() -> void:
		pass
	
	func reset() -> void:
		damage = 0.0
		healing = 0.0
		damage_type = &""
		force_critical = false
		force_hit = false
		is_critical = false
		is_hit = false
		is_indirect = false
	
	func to_dictionary() -> Dictionary:
		return {
			"damage": damage,
			"healing": healing,
			"damage_type": damage_type,
			"force_critical": force_critical,
			"force_hit": force_hit,
			"is_critical": is_critical,
			"is_hit": is_hit,
			"is_indirect": is_indirect,
		}

	func copy_from(other: DamageData) -> void:
		damage = other.damage
		healing = other.healing
		damage_type = other.damage_type
		force_critical = other.force_critical
		force_hit = other.force_hit
		is_critical = other.is_critical
		is_hit = other.is_hit
		is_indirect = other.is_indirect

	static func from_dictionary(dictionary: Dictionary) -> DamageData:
		var data := DamageData.new()
		data.damage = dictionary.get("damage", 0.0)
		data.healing = dictionary.get("healing", 0.0)
		data.damage_type = dictionary.get("damage_type", &"")
		data.force_critical = dictionary.get("force_critical", false)
		data.force_hit = dictionary.get("force_hit", false)
		data.is_critical = dictionary.get("is_critical", false)
		data.is_hit = dictionary.get("is_hit", false)
		data.is_indirect = dictionary.get("is_indirect", false)
		return data
