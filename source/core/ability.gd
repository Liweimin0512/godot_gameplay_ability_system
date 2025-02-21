extends Resource
class_name Ability

## 技能基类，提供基础的技能系统功能

# 缓存有效期
const CACHE_DURATION : float = 0.1 # 100ms

## 技能ID
@export var ability_id : StringName
## 标签
@export var ability_tags: Array[StringName] = []
## 限制器
@export var restrictions: Array[AbilityRestriction]
## 动作树
@export var action_tree_id: StringName
## 数据配置
@export var config: Dictionary
## 子能力
@export var sub_abilities : Array[Ability] = []
# 触发相关
@export var trigger : Trigger = null

# 运行时状态
var _can_use_reason : String:						## 不能使用的原因
	set(value):
		GASLogger.debug(value)
		_can_use_reason = value
var is_active : bool = false						## 是否激活
# 缓存相关
var _cached_can_execute := false					## 缓存能否执行
var _cache_time : float = 0.0						## 缓存时间
# 状态追踪
var _execution_count : int = 0						## 执行次数
var _last_execution_time : float = 0.0				## 最后执行时间
var _is_executing : bool = false					## 是否正在执行

## 从数据字典初始化
## [param data] 数据字典
func _init_from_data(data : Dictionary) -> void:
	ability_id = data.get("ID", "")
	if data.has("trigger"):
		trigger = Trigger.new(data.get("trigger", {}))
	for restriction_config in data.get("restrictions", []):
		var restriction : AbilityRestriction = AbilitySystem.create_restriction(restriction_config)
		add_restriction(restriction)


## 添加限制器
func add_restriction(restriction: AbilityRestriction) -> AbilityRestriction:
	restrictions.append(restriction)
	return restriction


## 应用技能
func apply(context: Dictionary) -> void:
	context.ability = self

	# 如果是触发能力，记得注册到触发器管理器中
	_setup_trigger()		

	# 应用动作树
	await AbilitySystem.action_manager.apply_action_tree(action_tree_id, context)
	AbilitySystem.push_ability_event("ability_applied", context)

	# 应用子能力
	for sub_ability in sub_abilities:
		sub_ability.apply(context)
	
	is_active = true


## 移除技能
func remove(context: Dictionary) -> void:
	# 移除动作树
	AbilitySystem.action_manager.remove_action_tree(action_tree_id, context)
	AbilitySystem.push_ability_event("ability_removed", context)

	_cleanup_trigger()
	
	for sub_ability in sub_abilities:
		sub_ability.remove(context)
	
	is_active = false


## 能否执行
func can_execute(context: Dictionary) -> bool:
	# 缓存检查
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - _cache_time < CACHE_DURATION:
		return _cached_can_execute
	
	_cached_can_execute = _check_can_execute(context)
	_cache_time = current_time
	return _cached_can_execute


## 执行技能
func execute(context: Dictionary) -> void:
	if _is_executing: 
		GASLogger.error("Ability %s is already executing" % ability_id)
		return

	if not can_execute(context): 
		return

	_is_executing = true
	_execution_count += 1
	_last_execution_time = Time.get_ticks_msec() / 1000.0
	
	_before_execute(context)

	# 执行自身行为树
	if not action_tree_id.is_empty():
		await AbilitySystem.action_manager.execute_action_tree(action_tree_id, context)
	# 执行子能力行为树
	for sub_ability in sub_abilities:
		sub_ability.execute(context)

	_after_execute(context)
	_is_executing = false


## 重置
## [TODO] 暂时只重置限制器, 而且没调用，后续优化
func reset() -> void:
	trigger.reset()
	for restriction in restrictions:
		restriction.reset()

#region 标签相关

## 添加标签
func add_tag(tag: StringName) -> void:
	ability_tags.append(tag)


## 移除标签
func remove_tag(tag: StringName) -> void:
	ability_tags.erase(tag)


## 是否包含标签
func has_tag(tag: StringName) -> bool:
	return ability_tags.has(tag)


## 是否包含标签
func has_tags(tags: Array[StringName]) -> bool:
	return tags.all(func(tag: StringName) -> bool: return ability_tags.has(tag))

#endregion

func _before_execute(context: Dictionary) -> void:
	AbilitySystem.push_ability_event("ability_executing", context)
	for restriction in restrictions:
		restriction.before_ability_execute(context)


func _after_execute(context: Dictionary) -> void:
	AbilitySystem.push_ability_event("ability_executed", context)
	for restriction in restrictions:
		restriction.after_ability_execute(context)


func _on_trigger_success(context: Dictionary) -> void:
	if is_active: 
		execute(context)


func _check_can_execute(context: Dictionary) -> bool:
	# 检查限制器
	for restriction in restrictions:
		var can_use = restriction.can_use(context)
		if not can_use:
			_can_use_reason = restriction.can_use_reason
			return false

	# 如果是触发类型能力，检查触发次数
	if trigger:
		return trigger.should_trigger(context)
	
	return true


func _setup_trigger() -> void:
	if trigger:
		trigger.trigger_success.connect(_on_trigger_success)
		AbilitySystem.trigger_manager.register_ability_trigger(trigger, self)


func _cleanup_trigger() -> void:
	if trigger:
		trigger.trigger_success.disconnect(_on_trigger_success)
		AbilitySystem.trigger_manager.unregister_ability_trigger(trigger, self)
