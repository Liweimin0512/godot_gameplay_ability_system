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
## 触发器
@export var trigger : Trigger = null
## 动作树
@export var action_tree_id: StringName
## 子能力
@export var sub_abilities : Array[Ability] = []
## 是否自动
@export var is_auto : bool = false

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

var caster : Node

## 从数据字典初始化
## [param data] 数据字典
func _init_from_data(data : Dictionary) -> void:
	ability_id = data.get("ID", "")
	if data.has("trigger"):
		trigger = Trigger.new(data.get("trigger", {}))
	for restriction_config in data.get("restrictions", []):
		var restriction : AbilityRestriction = AbilitySystem.create_restriction(restriction_config)
		add_restriction(restriction)
	for ability_id in data.get("sub_abilities", []):
		var sub_ability : Ability = AbilitySystem.create_ability_instance(ability_id)
		sub_abilities.append(sub_ability)


## 应用技能
func apply(context: AbilityContext) -> void:
	context.ability = self

	# 如果是触发能力，记得注册到触发器管理器中
	_setup_trigger()

	# 应用动作树
	AbilitySystem.action_manager.apply_action_tree(self)
	AbilitySystem.push_ability_event("ability_applied", context)

	# 应用子能力
	for sub_ability in sub_abilities:
		sub_ability.apply(context)

	# 如果是自动能力，立即执行
	if is_auto:
		await execute(context)

	is_active = true

## 移除技能
func remove() -> void:
	# 移除动作树
	AbilitySystem.action_manager.remove_action_tree(self)
	AbilitySystem.push_ability_event("ability_removed")

	_cleanup_trigger()
	
	for sub_ability in sub_abilities:
		sub_ability.remove()

	is_active = false


## 能否执行
func can_execute(context: AbilityContext) -> bool:
	# 缓存检查
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - _cache_time < CACHE_DURATION:
		return _cached_can_execute

	context.ability = self
	_cached_can_execute = _check_can_execute(context)
	_cache_time = current_time
	return _cached_can_execute


## 执行技能
func execute(context: AbilityContext) -> void:
	if _is_executing: 
		GASLogger.error("Ability %s is already executing" % ability_id)
		return

	if not can_execute(context): 
		return

	_is_executing = true
	_execution_count += 1
	_last_execution_time = Time.get_ticks_msec() / 1000.0
	
	_before_execute(context)
	await _execute_internal(context)
	_after_execute(context)

	_is_executing = false


## 重置
## [TODO] 暂时只重置限制器, 而且没调用，后续优化
func reset() -> void:
	trigger.reset()
	for restriction in restrictions:
		restriction.reset()


## 添加限制器
func add_restriction(restriction: AbilityRestriction) -> AbilityRestriction:
	restrictions.append(restriction)
	return restriction


## 获取可选地目标
func get_available_targets(context: Dictionary) -> Array:
	var selector = _get_target_selector()
	if not selector: return []
	return selector.get_available_targets(self, context)


## 验证选择的目标，确保目标合法
func validate_targets(targets: Array, context: Dictionary) -> bool:
	var selector = _get_target_selector()
	if not selector: return false
	return selector.validate_targets(self, targets, context)


#endregion

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

# 私有方法
## 在执行前调用
func _before_execute(context: AbilityContext) -> void:
	AbilitySystem.push_ability_event("ability_executing", context)
	for restriction in restrictions:
		restriction.before_ability_execute(context)


# 新增内部执行方法，便于子类重写具体执行逻辑
func _execute_internal(context: AbilityContext) -> void:
	# 执行自身行为树
	if not action_tree_id.is_empty():
		await AbilitySystem.action_manager.execute_action_tree(self, context)
	# 执行子能力行为树
	for sub_ability in sub_abilities:
		sub_ability.execute(context)


## 在执行后调用
func _after_execute(context: AbilityContext) -> void:
	AbilitySystem.push_ability_event("ability_executed", context)
	for restriction in restrictions:
		restriction.after_ability_execute(context)


## 检查能否执行
func _check_can_execute(context: AbilityContext) -> bool:
	# 检查限制器
	for restriction in restrictions:
		var can_use = restriction.can_execute(context)
		if not can_use:
			_can_use_reason = restriction.can_use_reason
			return false

	# 如果是触发类型能力，检查触发次数
	if trigger:
		return trigger.should_trigger(context.to_dictionary())
	
	return true


## 设置触发器
func _setup_trigger() -> void:
	if trigger:
		trigger.trigger_success.connect(_on_trigger_success)
		AbilitySystem.trigger_manager.register_ability_trigger(trigger, self)


## 清理触发器
func _cleanup_trigger() -> void:
	if trigger:
		trigger.trigger_success.disconnect(_on_trigger_success)
		AbilitySystem.trigger_manager.unregister_ability_trigger(trigger, self)


## 触发器成功
func _on_trigger_success(context: Dictionary) -> void:
	if is_active: 
		execute(AbilityContext.from_dictionary(context))


## 获取目标选择器
## 子类可以重写这个方法返回特定的选择器
func _get_target_selector() -> AbilityTargetSelector:
	return null
