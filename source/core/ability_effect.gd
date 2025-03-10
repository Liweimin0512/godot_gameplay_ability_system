extends Resource
class_name AbilityEffect


# 缓存有效期
const CACHE_DURATION : float = 0.1 # 100ms

@export var effect_id : StringName
@export var effect_tags : Array[StringName]
@export var trigger : GameplayTrigger                   					## 触发器，没有触发器则直接执行
@export var sub_effects : Array[AbilityEffect]  					## 子效果
@export var priority : int = 0										## 执行优先级
@export var exclusive_tags : Array[StringName] = []					## 互斥标签
@export var level : int = 0											## 效果等级

@export_group("Stacking")                       					## 堆叠相关
@export var can_stack : bool = false            					## 是否能堆叠
@export var stack_count : int = 1               					## 可叠加次数
@export var refresh_duration_on_stack: bool = true     				## 堆叠时是否刷新持续时间

# 运行时状态
var is_active : bool = false                   					## 是否激活
var current_stacks : int = 1                   					## 当前堆叠数
# 缓存相关
var _cached_can_execute := false								## 缓存能否执行
var _cache_time : float = 0.0									## 缓存时间
# 状态追踪
var _execution_count : int = 0									## 执行次数
var _last_execution_time : float = 0.0							## 最后执行时间
var _is_executing : bool = false								## 是否正在执行

signal effect_started                                               ## 效果开始
signal effect_ended                                                 ## 效果结束
signal effect_paused                                                ## 效果暂停
signal effect_resumed                                               ## 效果恢复


func _init_from_data(data: Dictionary) -> void:
	var trigger_data : Dictionary = data.get("trigger")
	if not trigger_data.is_empty():
		trigger = GameplayTrigger.new(data.get("trigger", {}))
	for sub_effect_id in data.get("sub_effects", []):
		var sub_effect : AbilityEffect = AbilitySystem.create_ability_effect_instance(sub_effect_id)
		if sub_effect:
			sub_effects.append(sub_effect)


## 激活
func activate(context: AbilityEffectContext) -> void:
	if is_active:
		GASLogger.warning("Effect is already active")
		return

	is_active = true

	# 设置触发器
	if not _setup_trigger(context):
		await execute(context)
	
	_activate(context)

	for sub_effect in sub_effects:
		await sub_effect.activate(context)


## 执行
func execute(context: AbilityEffectContext) -> bool:
	if _is_executing: 
		GASLogger.error("Effect %s is already executing" % effect_id)
		return false

	if not is_active:
		GASLogger.warning("Effect is not active")
		return false

	if not can_execute(context):
		return false

	_is_executing = true
	_execution_count += 1
	_last_execution_time = Time.get_ticks_msec() / 1000.0

	_before_execute(context)
	await _execute_internal(context)
	_after_execute(context)

	_is_executing = false
	return true


## 更新效果
func update(delta : float) -> void:
	if not is_active:
		return

	_update(delta)
	
	# 更新子效果
	for sub_effect in sub_effects:
		sub_effect.update_effect(delta)


## 停用
func deactivate() -> void:
	if not is_active:
		GASLogger.warning("Effect is not active")
		return
	is_active = false

	_deactivate()
	for sub_effect in sub_effects:
		sub_effect.deactivate()

	# 清理触发器
	_cleanup_trigger()


func reset() -> void:
	_reset()


func can_execute(context : AbilityEffectContext) -> bool:
	if not _can_execute(context):
		return false

	# 缓存检查
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - _cache_time < CACHE_DURATION:
		return _cached_can_execute

	if not _can_execute(context):
		_cached_can_execute = false
	elif trigger:
		_cached_can_execute = trigger.should_trigger(context.to_dictionary())
	_cache_time = current_time
	return _cached_can_execute


## 尝试堆叠
func try_stack() -> bool:
	if not can_stack or current_stacks >= stack_count:
		return false
	
	current_stacks += 1
	if refresh_duration_on_stack:
		_refresh_duration()

	_on_stack()
	return true


## 移除堆叠
func remove_stack(stack_count : int = 1) -> void:
	current_stacks -= stack_count
	_on_remove_stack()
	if current_stacks <= 0:
		deactivate()
		return


#region 标签相关

## 添加标签
func add_tag(tag: StringName) -> void:
	effect_tags.append(tag)


## 移除标签
func remove_tag(tag: StringName) -> void:
	effect_tags.erase(tag)


## 是否包含标签
func has_tag(tag: StringName) -> bool:
	return effect_tags.has(tag)


## 是否包含标签
func has_tags(tags: Array[StringName]) -> bool:
	return tags.all(func(tag: StringName) -> bool: return effect_tags.has(tag))

#endregion


## 设置触发器
func _setup_trigger(context : AbilityEffectContext) -> bool:
	if trigger:
		trigger.triggered.connect(_on_trigger_triggered)
		trigger.activate(context.to_dictionary())
		return true
	return false


## 清理触发器
func _cleanup_trigger() -> void:
	if trigger:
		trigger.triggered.disconnect(_on_trigger_triggered)
		trigger.deactivate()


## 触发器触发
func _on_trigger_triggered(context: Dictionary) -> void:
	if is_active: 
		execute(AbilityEffectContext.from_dictionary(context))


func _activate(context: AbilityEffectContext) -> void:
	pass

func _deactivate() -> void:
	pass

func _update(delta : float) -> void:
	pass

func _before_execute(context: AbilityEffectContext) -> void:
	pass

func _execute_internal(context: AbilityEffectContext) -> void:
	pass

func _after_execute(context: AbilityEffectContext) -> void:
	pass

## 堆叠时调用（由派生类实现）
func _on_stack() -> void:
	pass

## 移除堆叠时调用（由派生类实现）
func _on_remove_stack() -> void:
	pass

## 刷新持续时间（由派生类实现）
func _refresh_duration() -> void:
	pass

func _can_execute(context : AbilityEffectContext) -> bool:
	return true

func _reset() -> void:
	pass


## 获取可选目标
func get_available_targets(context: AbilityEffectContext) -> Array:
	var selector = _get_target_selector()
	if not selector: return []
	return selector.get_available_targets(self, context)


## 验证选择的目标，确保目标合法
func validate_targets(targets: Array, context: AbilityEffectContext) -> bool:
	var selector = _get_target_selector()
	if not selector: return false
	return selector.validate_targets(self, targets, context)


#endregion

## 获取实际执行时的目标
func _get_actual_targets(context: AbilityEffectContext) -> Array:
	var selector = _get_target_selector()
	if not selector: return []
	return selector.get_actual_targets(self, context)


## 获取目标选择器
## 子类可以重写这个方法返回特定的选择器
func _get_target_selector() -> AbilityTargetSelector:
	return null
