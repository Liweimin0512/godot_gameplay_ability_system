extends DecoratorAction
class_name DecoratorTrigger

## 触发器节点

## 触发类型
@export var trigger_type: StringName = ""
## 是否持续触发
@export var persistent: bool = true
## 触发次数限制 (-1为无限)
@export var trigger_count: int = -1
## 当前触发次数
var _current_triggers: int = 0
## 是否已注册
var _registered: bool = false
## 原始上下文
var _original_context: Dictionary

## 处理触发器, AbilityComponent 调用
func handle_trigger(trigger_data: Dictionary, callback:  Callable = Callable()) -> void:
	var ability = _get_context_value(_original_context, "ability")

	# 检查子节点
	if not child:
		GASLogger.error("child is null")
		return

	# 检查触发次数
	if trigger_count > 0 and _current_triggers >= trigger_count:
		GASLogger.debug("trigger count reached, unregister trigger")
		_unregister_trigger()
		return

	# 合并上下文
	# var new_context = _original_context.duplicate()
	_original_context.merge(trigger_data, true)
	
	# 执行子节点
	var result := await child.execute(_original_context)

	# 检查是否需要解除注册
	if not persistent or (trigger_count > 0 and _current_triggers >= trigger_count):
		_unregister_trigger()
		
	if callback.is_valid():
		if result == STATUS.SUCCESS:
			GASLogger.debug("trigger success")
			callback.call(true, ability)
		else:
			GASLogger.debug("trigger failed")
			callback.call(false, ability)

func _apply(context: Dictionary) -> void:
	if not _registered:
		var ok := _register_trigger(context)
		if ok:
			_original_context = context.duplicate(true)
		else:
			GASLogger.error("register trigger failed")
	if child:
		child.apply(context)

func _revoke(context: Dictionary) -> bool:
	if not _registered: 
		GASLogger.error("trigger not registered")
		return false
	_unregister_trigger()
	_original_context = {}
	return true

## 触发器默认不能手动释放
func _can_execute(trigger_data: Dictionary) -> bool:
	return false

## 注册触发器
func _register_trigger(context: Dictionary) -> bool:
	if _registered: return false
	AbilitySystem.trigger_manager.add_ability_trigger(trigger_type, self)
	_registered = true
	return true

## 解除注册
func _unregister_trigger() -> void:
	# 清理所有信号连接
	if not _registered: return
	AbilitySystem.trigger_manager.remove_ability_trigger(trigger_type, self)
	_registered = false
