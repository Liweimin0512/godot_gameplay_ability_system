@tool
extends Resource
class_name AbilityAction

## 动作基类，通过Resource组成树状结构

## 节点状态
enum STATUS {
	SUCCESS,    ## 成功
	FAILURE,    ## 失败
}

## 节点名称（ID), 用于获取节点
@export var action_name: StringName = ""

## 是否启用
@export var enabled := true
## 前摇延时
@export var pre_delay: float = 0.0
## 后摇延时
@export var post_delay: float = 0.0

## 节点状态
var state : STATUS = STATUS.SUCCESS
var _script_name: StringName = "":
	get:
		return get_script().resource_path.get_file().get_basename()
## 执行过了，有些技能需要条件判断，条件不满足需要撤回到不满足的步骤
var is_executed: bool = false

signal applied(context: Dictionary)
signal executing(context: Dictionary)
signal executed(context: Dictionary)
signal revoked(context: Dictionary)

func _init():
	resource_local_to_scene = true


## 执行
func execute(context: Dictionary) -> STATUS:
	if not enabled:
		return STATUS.FAILURE

	# 从技能配置中设置属性
	_setup_from_ability_config(context)

	executing.emit(context)
	if pre_delay > 0.0:
		await AbilitySystem.get_tree().create_timer(pre_delay).timeout
	state = await _execute(context)
	if state == STATUS.SUCCESS:
		is_executed = true
		executed.emit(context)
		if post_delay > 0.0:
			await AbilitySystem.get_tree().create_timer(post_delay).timeout
	return state


## 撤销
func revoke() -> bool:
	if not enabled: 
		return false
	# 如果不能撤销（没有执行过），则直接成功
	if not is_executed: 
		return true
	var ok = _revoke()
	revoked.emit(ok)
	return ok


## 获取节点
func get_action(p_action_name: StringName) -> AbilityAction:
	if action_name == p_action_name:
		return self
	return _get_action(p_action_name)


## 获取上下文值
func _get_context_value(context: Dictionary, key: StringName) -> Variant:
	if not context.has(key):
		GASLogger.error("AbilityAction {0}: _get_context_value: context not has key: {1}".format([_script_name, key]))
		return null
	return context[key]


## 获取技能配置
func _get_ability_config(context: Dictionary) -> Dictionary:
	var ability : Ability = context.get("ability", null)
	if not ability:
		GASLogger.error("AbilityAction {0}: _get_ability_config: ability is null!".format([action_name]))
		return {}
	return ability.config


## 解析参数
## TODO 这个是最初的想法，现在显然没什么用
func _resolve_parameter(param: String, context: AbilityContext) -> Variant:
	if param.begins_with("@data:"):
		return context.ability.data.get(param.substr(6))
	elif param.begins_with("@var:"):
		return context.get_variable(param.substr(5))
	return param


## 设置技能配置
func _setup_from_ability_config(context: Dictionary) -> void:
	var ability_config : Dictionary = _get_ability_config(context)
	for param in ability_config:
		var value = ability_config[param]
		set(param, value)


## 子类中实现的执行方法
func _execute(_context: Dictionary) -> STATUS:
	return STATUS.SUCCESS


## 子类中实现的撤销方法
func _revoke() -> bool:
	return true


## 获取子节点，子类实现
func _get_action(_action_name: StringName) -> AbilityAction:
	return null


func _to_string() -> String:
	if action_name == "":
		return _script_name
	return "{0} : {1}".format([_script_name, action_name])
