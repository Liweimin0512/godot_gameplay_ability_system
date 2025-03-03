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


func _init():
	resource_local_to_scene = true


## 执行
func execute(context: AbilityContext) -> STATUS:
	if not enabled:
		return STATUS.FAILURE

	if pre_delay > 0.0:
		await AbilitySystem.get_tree().create_timer(pre_delay).timeout
	state = await _execute(context)
	if state == STATUS.SUCCESS:
		is_executed = true
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
	return ok


## 获取节点
func get_action(p_action_name: StringName) -> AbilityAction:
	if action_name == p_action_name:
		return self
	return _get_action(p_action_name)


## 子类中实现的执行方法
func _execute(_context: AbilityContext) -> STATUS:
	return STATUS.SUCCESS


## 子类中实现的撤销方法
func _revoke() -> bool:
	return true


## 获取子节点，子类实现
func _get_action(_action_name: StringName) -> AbilityAction:
	return null


## 获取动作描述
func get_action_description() -> String:
	return ""


## 获取完整的行为树描述（包括所有子节点）
func get_tree_description() -> String:
	var descriptions = []
	
	# 获取当前节点的描述
	var current_desc = get_action_description()
	if not current_desc.is_empty():
		descriptions.append(current_desc)
	
	return "\n".join(descriptions)


func _to_string() -> String:
	if action_name == "":
		return _script_name
	return "{0} : {1}".format([_script_name, action_name])
