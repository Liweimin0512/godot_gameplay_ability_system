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

#signal created
signal applied(context: Dictionary)
signal executing(context: Dictionary)
signal executed(context: Dictionary)
signal revoked(context: Dictionary)

func _init():
	resource_local_to_scene = true
	#created.emit()


## 获取节点
func get_action(action_name: StringName) -> AbilityAction:
	return _get_action(action_name)


## 检查是否可以执行
func can_execute(context: Dictionary) -> bool:
	return _can_execute(context)


## 应用
func apply(context: Dictionary) -> void:
	_apply(context)
	applied.emit(context)


## 执行
func execute(context: Dictionary) -> STATUS:
	if not enabled: return STATUS.FAILURE
	executing.emit(context)
	if pre_delay > 0.0:
		GASLogger.debug("ability_action pre_delay: %s" % [pre_delay])
		await AbilitySystem.get_tree().create_timer(pre_delay).timeout
	state = await _execute(context)
	if state == STATUS.SUCCESS:
		is_executed = true
		executed.emit(context)
		if post_delay > 0.0:
			GASLogger.debug("ability_action post_delay: %s" % [post_delay])
			await AbilitySystem.get_tree().create_timer(post_delay).timeout
	else:
		## 执行失败，撤销
		revoke(context)
	return state


## 撤销
func revoke(context: Dictionary) -> bool:
	if not enabled: return false
	# 如果不能撤销（没有执行过），则直接成功
	if not is_executed: return true
	var ok = _revoke(context)
	revoked.emit(ok)
	return ok


## 更新
func update(delta: float) -> void:
	_update(delta)


## 解析参数
func _resolve_parameter(param: String, context: AbilityContext) -> Variant:
	if param.begins_with("@data:"):
		return context.ability.data.get(param.substr(6))
	elif param.begins_with("@var:"):
		return context.get_variable(param.substr(5))
	return param

func _apply(_context: Dictionary) -> void:
	pass

## 子类中实现的执行方法
func _execute(_context: Dictionary) -> STATUS:
	return STATUS.SUCCESS


## 子类中实现的撤销方法
func _revoke(_context: Dictionary) -> bool:
	return true


## 更新
func _update(_delta: float) -> void:
	pass


## 能否执行，子类实现
func _can_execute(_context: Dictionary) -> bool:
	return true


## 获取子节点，子类实现
func _get_action(_action_name: StringName) -> AbilityAction:
	return null


## 获取上下文值
func _get_context_value(context: Dictionary, key: StringName) -> Variant:
	if not context.has(key):
		GASLogger.error("AbilityAction {0}: _get_context_value: context not has key: {1}".format([_script_name, key]))
		return null
	return context[key]


func _to_string() -> String:
	if action_name == "":
		return _script_name
	return "{0} : {1}".format([_script_name, action_name])
