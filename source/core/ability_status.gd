extends Resource
class_name AbilityStatus


## 持续类型
enum DURATION_TYPE {
	INSTANT,    # 即时效果，执行之后立刻销毁
	INFINITE,   # 无限持续，直到手动移除
	TIMED,      # 有限持续，持续时间或回合数
}

@export var status_id : StringName
@export var status_tags : Array[StringName]
@export var is_hidden: bool = false             ## 是否隐藏效果


@export_group("Duration")                       ## 持续时间相关
@export var duration_type : DURATION_TYPE = DURATION_TYPE.INSTANT
@export var duration: float = 0.0               ## 持续时间（秒或回合）

@export_group("Modifier")                       ## 修改相关
@export var tag_modifiers : Array[StringName] = []
@export var effects : Array[AbilityEffect]
@export var effect_params : Dictionary = {}:    ## 效果参数配置
	set(value):
		effect_params = value
		_update_params_with_stacks()

# 运行时状态
var source : Node   # 效果来源
var target : Node   # 效果目标
var current_stacks : int = 1                 ## 当前堆叠次数
var remaining_duration : float = 0.0         ## 剩余持续时间
var is_active : bool = false                 ## 是否激活
var current_params: Dictionary

signal stack_limit_reached                                          ## 堆叠次数达到上限
signal stack_changed(old_value : int, new_value : int)              ## 堆叠次数变化


func _init_from_data(data: Dictionary) -> void:
	for atr_modifier_data in data.get("attribute_modifiers", []):
		attribute_modifiers.append(AbilityAttributeModifier.new(
			atr_modifier_data.get("attribute_name", ""),
			atr_modifier_data.get("modifier_type", "value"),
			atr_modifier_data.get("value", 0.0)
			))


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
