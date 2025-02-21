@tool
extends Resource
class_name AbilityContext

## 技能上下文，包含技能执行过程中的所有相关数据

# 基础属性
var ability: Ability  # 技能实例
var caster: Node  # 施法者
var target: Node  # 主要目标
var additional_targets: Array[Node] = []  # 额外目标
var instigator: Node  # 触发者（可能与施法者不同）

# 时间相关
var creation_time: float  # 创建时间
var last_update_time: float  # 最后更新时间
var delta_time: float  # 当前帧时间

# 效果相关
var effect_id: StringName  # 当前执行的效果ID
var effect_stack: int = 1  # 效果层数
var effect_duration: float = 0.0  # 效果持续时间

# 战斗数据
var damage: float = 0.0  				# 伤害值
var healing: float = 0.0  				# 治疗值
var damage_type: StringName  			# 伤害类型
var force_critical: bool = false  		# 强制暴击
var force_hit: bool = false  			# 强制命中
var is_critical: bool = false  			# 是否暴击
var is_hit: bool = false  				# 是否命中
var is_indirect: bool = false  			# 是否间接伤害

# 变量存储
var _variables: Dictionary = {}  # 动态变量存储
var _tags: Array[StringName] = []  # 上下文标签

# 缓存
var _cached_values: Dictionary = {}  # 缓存的计算值

func _init() -> void:
	creation_time = Time.get_unix_time_from_system()
	last_update_time = creation_time

## 更新上下文
func update(delta: float) -> void:
	delta_time = delta
	last_update_time = Time.get_unix_time_from_system()
	_cached_values.clear()  # 清除缓存

# 变量操作

func set_variable(name: StringName, value) -> void:
	_variables[name] = value
	_cached_values.clear()  # 清除缓存，因为变量可能影响计算结果

func get_variable(name: StringName, default_value = null):
	return _variables.get(name, default_value)

func has_variable(name: StringName) -> bool:
	return _variables.has(name)

# 标签操作

func add_tag(tag: StringName) -> void:
	if not _tags.has(tag):
		_tags.append(tag)

func remove_tag(tag: StringName) -> void:
	_tags.erase(tag)

func has_tag(tag: StringName) -> bool:
	return _tags.has(tag)

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

# 计算值缓存

func get_cached_value(key: StringName, calculator: Callable):
	if not _cached_values.has(key):
		_cached_values[key] = calculator.call()
	return _cached_values[key]

# 创建副本
func create_copy() -> AbilityContext:
	var copy := AbilityContext.new()
	copy.ability = ability
	copy.caster = caster
	copy.target = target
	copy.additional_targets = additional_targets.duplicate()
	copy.instigator = instigator
	copy.effect_id = effect_id
	copy.effect_stack = effect_stack
	copy.effect_duration = effect_duration
	# 伤害相关
	copy.damage = damage
	copy.healing = healing
	copy.damage_type = damage_type
	copy.force_critical = force_critical
	copy.force_hit = force_hit
	copy.is_critical = is_critical
	copy.is_hit = is_hit
	copy.is_indirect = is_indirect

	copy._variables = _variables.duplicate(true)
	copy._tags = _tags.duplicate()
	return copy

## 从字典创建
static func from_dictionary(dict: Dictionary) -> AbilityContext:
	var context := AbilityContext.new()
	# 基础属性
	context.ability = dict.get("ability")
	context.caster = dict.get("caster")
	context.target = dict.get("target")
	context.additional_targets = dict.get("additional_targets", [])
	context.instigator = dict.get("instigator")
	# 效果相关
	context.effect_id = dict.get("effect_id", &"")
	context.effect_stack = dict.get("effect_stack", 1)
	context.effect_duration = dict.get("effect_duration", 0.0)
	# 战斗数据
	context.damage = dict.get("damage", 0.0)
	context.healing = dict.get("healing", 0.0)
	context.damage_type = dict.get("damage_type", &"")
	context.force_critical = dict.get("force_critical", false)
	context.force_hit = dict.get("force_hit", false)
	context.is_critical = dict.get("is_critical", false)
	context.is_hit = dict.get("is_hit", false)
	context.is_indirect = dict.get("is_indirect", false)
	# 变量和标签
	context._variables = dict.get("variables", {}).duplicate()
	context._tags = dict.get("tags", []).duplicate()
	return context

## 转换为字典
func to_dictionary() -> Dictionary:
	return {
		# 基础属性
		"ability": ability,
		"caster": caster,
		"target": target,
		"additional_targets": additional_targets,
		"instigator": instigator,
		# 效果相关
		"effect_id": effect_id,
		"effect_stack": effect_stack,
		"effect_duration": effect_duration,
		# 战斗数据
		"damage": damage,
		"healing": healing,
		"damage_type": damage_type,
		"critical": critical,
		"force_critical": force_critical,
		"is_indirect": is_indirect,
		"force_hit": force_hit,
		"is_hit": is_hit,
		# 变量和标签
		"variables": _variables.duplicate(),
		"tags": _tags.duplicate()
	}
