extends Resource
class_name Ability

## 技能基类，提供基础的技能系统功能

# 缓存有效期
const CACHE_DURATION : float = 0.1 # 100ms

@export var ability_id : StringName								## 技能ID
@export var ability_tags: Array[StringName] = []				## 标签
@export var restrictions: Array[AbilityRestriction]				## 限制器
@export var sub_abilities : Array[Ability] = []					## 子能力
@export var is_auto : bool = false								## 是否自动
@export var ability_effects : Array[AbilityEffect] = []			## 效果

# 运行时状态
# 缓存相关
var _cached_can_execute := false								## 缓存能否执行
var _cache_time : float = 0.0									## 缓存时间
# 状态追踪
var _execution_count : int = 0									## 执行次数
var _last_execution_time : float = 0.0							## 最后执行时间
var _is_executing : bool = false								## 是否正在执行

var is_active : bool = false									## 是否激活
var caster : Node												## 施法者

var _can_use_reason : String = ""								## 不能使用的原因


## 从数据字典初始化
## [param data] 数据字典
func _init_from_data(data : Dictionary) -> void:
	ability_id = data.get("ID", "")
	for restriction_config in data.get("restrictions", []):
		var restriction : AbilityRestriction = AbilitySystem.create_restriction(restriction_config)
		add_restriction(restriction)
	for ability_id in data.get("sub_abilities", []):
		var sub_ability : Ability = AbilitySystem.create_ability_instance(ability_id)
		sub_abilities.append(sub_ability)
	for effect_id in data.get("ability_effects", []):
		var effect : AbilityEffect = AbilitySystem.create_ability_effect_instance(effect_id)
		ability_effects.append(effect)


## 应用技能
func apply(context: AbilityEffectContext) -> void:
	if is_active:
		GASLogger.warning("Ability is already active")
		return
	is_active = true

	context.ability = self
	# 应用动作树
	# 如果是自动能力，立即执行
	if is_auto:
		await execute(context)

	AbilitySystem.push_ability_event("ability_applied", context)

	# 应用子能力
	for sub_ability in sub_abilities:
		sub_ability.apply(context)


## 移除技能
func remove() -> void:
	if not is_active:
		GASLogger.warning("Ability is not active")
		return
	is_active = false

	# 移除动作树
	for effect in ability_effects:
		effect.remove_effect()
	AbilitySystem.push_ability_event("ability_removed")
	
	for sub_ability in sub_abilities:
		sub_ability.remove()


## 更新
func update(delta : float) -> void:
	if not is_active:
		return
	
	# 更新限制器
	for restriction in restrictions:
		restriction.update(delta)

	# 更新自身effects
	for effect in ability_effects:
		effect.update_effect(delta)
	
	# 更新子能力
	for sub_ability in sub_abilities:
		sub_ability.update(delta)


## 能否执行
func can_execute(context: AbilityEffectContext) -> bool:
	# 缓存检查
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - _cache_time < CACHE_DURATION:
		return _cached_can_execute

	context.ability = self
	_cached_can_execute = _check_can_execute(context)
	_cache_time = current_time
	return _cached_can_execute


## 执行技能
func execute(context: AbilityEffectContext) -> void:
	if _is_executing: 
		GASLogger.error("Ability %s is already executing" % ability_id)
		return

	if not can_execute(context): 
		return

	_is_executing = true
	_execution_count += 1
	_last_execution_time = Time.get_ticks_msec() / 1000.0
	
	# 获取实际执行时的目标
	var targets = _get_actual_targets(context)
	targets.erase(context.target)
	context.additional_targets = targets
	
	_before_execute(context)
	await _execute_internal(context)
	_after_execute(context)

	_is_executing = false


## 重置
## [TODO] 暂时只重置限制器, 而且没调用，后续优化
func reset() -> void:
	for restriction in restrictions:
		restriction.reset()


## 添加限制器
func add_restriction(restriction: AbilityRestriction) -> AbilityRestriction:
	restrictions.append(restriction)
	return restriction


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
func _before_execute(context: AbilityEffectContext) -> void:
	AbilitySystem.push_ability_event("ability_executing", context)
	for restriction in restrictions:
		restriction.before_ability_execute(context)


# 新增内部执行方法，便于子类重写具体执行逻辑
func _execute_internal(context: AbilityEffectContext) -> void:
	# 应用效果
	for effect in ability_effects:
		effect.apply_effect(context)

	# 执行子能力行为树
	for sub_ability in sub_abilities:
		sub_ability.execute(context)


## 在执行后调用
func _after_execute(context: AbilityEffectContext) -> void:
	AbilitySystem.push_ability_event("ability_executed", context)
	for restriction in restrictions:
		restriction.after_ability_execute(context)


## 检查能否执行
func _check_can_execute(context: AbilityEffectContext) -> bool:
	# 检查限制器
	for restriction in restrictions:
		var can_use = restriction.can_execute(context)
		if not can_use:
			_can_use_reason = restriction.can_use_reason
			return false
	
	return true


## 获取实际执行时的目标
func _get_actual_targets(context: AbilityEffectContext) -> Array:
	var selector = _get_target_selector()
	if not selector: return []
	return selector.get_actual_targets(self, context)


## 获取目标选择器
## 子类可以重写这个方法返回特定的选择器
func _get_target_selector() -> AbilityTargetSelector:
	return null
