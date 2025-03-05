extends Resource
class_name AbilityEffect

## 持续类型
enum DURATION_TYPE {
	INSTANT,    # 即时效果
	INFINITE,   # 无限持续
	TIMED,      # 有限持续
}

@export var effect_id : StringName
@export var effect_tags : Array[StringName]
@export var is_hidden: bool = false         ## 是否隐藏效果

@export_group("Stacking")                   ## 堆叠相关
@export var stack_count : int = 1           ## 可叠加次数
@export var refresh_on_stack: bool = true   ## 在堆叠时刷新效果

@export_group("Duration")                   ## 持续时间相关
@export var duration_type : DURATION_TYPE = DURATION_TYPE.INSTANT
@export var duration: float = 0.0           ## 持续时间（秒或回合）

@export_group("Execution")                  ## 执行相关
@export var trigger : Trigger               ## 触发器，没有触发器则直接执行
@export var action_tree_id: StringName = "" ## 动作树ID

@export_group("modifier")                   ## 修改相关
@export var attribute_modifiers : Array[AbilityAttributeModifier]
@export var tag_modifiers : Array[StringName] = []

# 运行时状态
var source : Node   # 效果来源
var target : Node   # 效果目标
var current_stacks : int = 1                 ## 当前堆叠次数
var remaining_duration : float = 0.0         ## 剩余持续时间
var is_active : bool = false                 ## 是否激活


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

	_apply_attribute_modifiers(target)
	_apply_tag_modifiers(target)
	# 设置触发器

	if not trigger:
		# 不设置触发器，直接执行动作
		_apply_ability_action(context)

func remove_effect() -> void:
	if not is_active:
		GASLogger.warning("Effect is not active")
		return
	is_active = false
	
	# 移除属性修改
	_remove_attribute_modifiers(target)
	# 移除标签修改
	_remove_tag_modifiers(target)


func update_effect(delta : float) -> void:
    if not is_permanent and duration > 0:
        remaining_duration -= delta
        if remaining_duration <= 0:
            remove_effect()
            return


## 添加堆叠
func add_stack() -> bool:
	if current_stacks >= stack_count:
		return false
	current_stacks += 1
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
		attribute_component.apply_attribute_modifier(modifier)


## 移除属性修改器
func _remove_attribute_modifiers(target) -> void:
	var attribute_component : AbilityAttributeComponent = AbilityAttributeComponent.get_attribute_component(target)
	if not attribute_component:
		GASLogger.error("target " + str(target) + " missing AbilityAttributeComponent")
		return
	for modifier in attribute_modifiers:
		attribute_component.remove_attribute_modifier(modifier)


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
	AbilitySystem.action_manager.execute_action_tree(action_tree_id, context)


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
