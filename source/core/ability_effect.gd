extends Resource
class_name AbilityEffect

## 持续类型
enum DURATION_TYPE {
	INSTANT,    # 即时效果，执行之后立刻销毁
	INFINITE,   # 无限持续，直到手动移除
	TIMED,      # 有限持续，持续时间或回合数
}

@export var effect_id : StringName
@export var effect_tags : Array[StringName]
@export var is_hidden: bool = false             ## 是否隐藏效果

@export_group("Stacking")                       ## 堆叠相关
@export var can_stack : bool = false            ## 是否能堆叠
@export var stack_count : int = 1               ## 可叠加次数
@export var refresh_on_stack: bool = true       ## 在堆叠时刷新效果
## 堆叠时的参数计算规则
@export var stack_param_rules : Dictionary = {
	# "param_name": {
	#     "type": "add"|"multiply"|"max"|"custom",
	#     "value": float,  # 加法或乘法的系数
	#     "custom_func": Callable  # 自定义计算函数
	# }
}

@export_group("Duration")                       ## 持续时间相关
@export var duration_type : DURATION_TYPE = DURATION_TYPE.INSTANT
@export var duration: float = 0.0               ## 持续时间（秒或回合）

@export_group("Actions")                      ## 执行相关
@export var trigger : Trigger                   ## 触发器，没有触发器则直接执行
@export var action_tree_id: StringName = ""     ## 动作树ID
@export var effect_params : Dictionary = {}:    ## 效果参数配置
	set(value):
		effect_params = value
		_update_params_with_stacks()

@export_group("Modifier")                       ## 修改相关
@export var attribute_modifiers : Array[AbilityAttributeModifier]
@export var tag_modifiers : Array[StringName] = []


# 运行时状态
var source : Node   # 效果来源
var target : Node   # 效果目标
var current_stacks : int = 1                 ## 当前堆叠次数
var remaining_duration : float = 0.0         ## 剩余持续时间
var is_active : bool = false                 ## 是否激活
var applied_attribute_modifiers : Array[AbilityAttributeModifier] = [] # 记录已经应用的属性修改器
var current_params: Dictionary

signal stack_limit_reached                                          ## 堆叠次数达到上限
signal stack_changed(old_value : int, new_value : int)              ## 堆叠次数变化
signal effect_started                                               ## 效果开始
signal effect_ended                                                 ## 效果结束
signal effect_paused                                                ## 效果暂停
signal effect_resumed                                               ## 效果恢复

func _init_from_data(data: Dictionary) -> void:
	for atr_modifier_data in data.get("attribute_modifiers", []):
		attribute_modifiers.append(AbilityAttributeModifier.new(
			atr_modifier_data.get("attribute_name", ""),
			atr_modifier_data.get("modifier_type", "value"),
			atr_modifier_data.get("value", 0.0)
			))
	var trigger_data : Dictionary = data.get("trigger")
	if not trigger_data.is_empty():
		trigger = Trigger.new(data.get("trigger", {}))


func apply_effect(context: AbilityEffectContext) -> void:
	if is_active:
		GASLogger.warning("Effect is already active")
		return

	is_active = true
	source = context.caster
	target = context.target

	if duration_type == DURATION_TYPE.INSTANT:
		_apply_ability_action(context)
		remove_effect() # 即时效果直接销毁
		return

	_apply_attribute_modifiers(target)
	_apply_tag_modifiers(target)
	
	# 设置触发器
	_setup_trigger()


func remove_effect() -> void:
	if not is_active:
		GASLogger.warning("Effect is not active")
		return
	is_active = false
	
	# 移除属性修改
	_remove_attribute_modifiers(target)
	# 移除标签修改
	_remove_tag_modifiers(target)

	# 清理触发器
	_cleanup_trigger()


## 更新
func update_effect(delta : float) -> void:
	if not is_active:
		return
	
	if duration_type == DURATION_TYPE.TIMED and duration > 0:
		remaining_duration -= delta
		if remaining_duration <= 0:
			remove_effect()
			return

	# 更新持续效果，如果需要
	_update_attribute_modifiers()


## 添加堆叠
func try_stack() -> bool:
	if not can_stack or current_stacks >= stack_count:
		return false

	current_stacks += 1
	if refresh_on_stack:
		remaining_duration = duration

	# 更新效果参数
	_update_params_with_stacks()

	# 更新修改器
	_remove_attribute_modifiers(target)         # 先移除旧的
	_apply_attribute_modifiers(target)          # 再应用新的

	return true


## 移除堆叠
func remove_stack() -> void:
	current_stacks -= 1
	if current_stacks < 0:
		remove_effect()


## 应用属性修改器
func _apply_attribute_modifiers(target) -> void:
	## 应用属性修改
	var attribute_component : AbilityAttributeComponent = AbilityAttributeComponent.get_attribute_component(target)
	if not attribute_component:
		GASLogger.error("target " + str(target) + " missing AbilityAttributeComponent")
		return
	for modifier in attribute_modifiers:
		# 根据堆叠调整修改器的值
		var stacked_modifier = modifier.duplicate()
		stacked_modifier.value *= current_stacks
		attribute_component.apply_attribute_modifier(stacked_modifier)
		applied_attribute_modifiers.append(stacked_modifier)


## 移除属性修改器
func _remove_attribute_modifiers(target) -> void:
	var attribute_component : AbilityAttributeComponent = AbilityAttributeComponent.get_attribute_component(target)
	if not attribute_component:
		GASLogger.error("target " + str(target) + " missing AbilityAttributeComponent")
		return
	for modifier in applied_attribute_modifiers:
		attribute_component.remove_attribute_modifier(modifier)


## 更新修改器
## [TODO] 这里可以处理需要随时间变化的修改器
func _update_attribute_modifiers() -> void:
	pass


## 应用标签修改
func _apply_tag_modifiers(target) -> void:
	var ability_component : AbilityComponent = AbilityComponent.get_ability_component(target)
	if not ability_component:
		return
	for tag in tag_modifiers:
		ability_component.add_tag(tag)


## 移除标签修改
func _remove_tag_modifiers(target) -> void:
	var ability_component : AbilityComponent = AbilityComponent.get_ability_component(target)
	if not ability_component: return
	for tag in tag_modifiers:
		ability_component.remove_tag(tag)


## 应用动作
func _apply_ability_action(context: AbilityEffectContext) -> void:
	if action_tree_id.is_empty():
		return
	context.effect_params = current_params
	await AbilitySystem.action_manager.execute_action_tree(action_tree_id, context)

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
		_apply_ability_action(AbilityEffectContext.from_dictionary(context))


## 更新当前参数
func _update_params_with_stacks() -> void:
	current_params = effect_params.duplicate(true)

	if current_stacks <= 1: return

	# 根据堆叠规则计算参数
	for param_name in stack_param_rules:
		var rule = stack_param_rules[param_name]
		var base_value = effect_params.get(param_name, 0.0)

		match rule.type:
			"add":
				current_params[param_name] = base_value + (rule.value * (current_stacks - 1))
			"multiply":
				current_params[param_name] = base_value * pow(rule.value, current_stacks - 1)
			"max":
				current_params[param_name] = maxf(base_value, rule.value)
			"custom":
				if rule.has("custom_func"):
					current_params[param_name] = rule.custom_func.call(base_value, current_stacks)
			_:
				GASLogger.error("Invalid stack param rule type: " + rule.type)
