extends Resource
class_name AbilityEffectNode

## 资源节点基类，通过Resource组成树状结构

## 节点状态
enum STATUS {
	SUCCESS,    ## 成功
	FAILURE,    ## 失败
}

## 节点名称（ID), 用于获取节点
@export var effect_name: StringName = ""

## 是否启用
@export var enabled := true

## 节点状态
var state : STATUS = STATUS.SUCCESS
var _script_name: StringName = "":
	get:
		return get_script().resource_path.get_file().get_basename()
## 执行过了，有些技能需要条件判断，条件不满足需要撤回到不满足的步骤
var is_executed: bool = false

## 节点执行完成
signal executed(status: STATUS)
## 节点撤销完成
signal revoked(status: STATUS)

func _init():
	resource_local_to_scene = true

## 获取节点, 子类实现
func get_node(effect_name: StringName) -> AbilityEffectNode:
	return _get_effect_node(effect_name)

## 执行
func execute(context: Dictionary) -> STATUS:
	if not enabled: return STATUS.FAILURE
	state = await _execute(context)
	if state == STATUS.SUCCESS:
		is_executed = true
	else:
		## 执行失败，撤销
		revoke()
	executed.emit(state)
	return state

## 撤销
func revoke() -> STATUS:
	if not enabled: return STATUS.FAILURE
	# 如果不能撤销（没有执行过），则直接成功
	if not is_executed: return STATUS.SUCCESS
	state = await _revoke()
	revoked.emit(state)
	return state

## 子类中实现的执行方法
func _execute(context: Dictionary) -> STATUS:
	return STATUS.SUCCESS

## 子类中实现的撤销方法
func _revoke() -> STATUS:
	return STATUS.SUCCESS

func _get_effect_node(effect_name: StringName) -> AbilityEffectNode:
	if effect_name == "":
		return self
	return get_node(effect_name)

func _get_context_value(context: Dictionary, key: StringName) -> Variant:
	if context.has(key):
		return context[key]
	GASLogger.error("AbilityEffectNode {0}: _get_context_value: context not has key: {1}".format([_script_name, key]))
	return null

func _to_string() -> String:
	if effect_name == "":
		return _script_name
	return "{0} : {1}".format([_script_name, effect_name])
