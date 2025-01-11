extends DecoratorNode
class_name DecoratorTriggerNode

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
	if ability is SkillAbility and ability.is_cooldown:
		# 处于冷却状态下的Skill没办法触发
		return
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

func _execute(context: Dictionary) -> STATUS:
	if not _registered:
		var ok := _register_trigger(context)
		if not ok:
			GASLogger.error("register trigger failed")
			return STATUS.FAILURE
	_original_context = context.duplicate(true)
	return STATUS.FAILURE

func _revoke() -> STATUS:
	if not _registered: 
		GASLogger.error("trigger not registered")
		return STATUS.FAILURE
	_unregister_trigger()
	_original_context = {}
	return STATUS.FAILURE

## 注册触发器
func _register_trigger(context: Dictionary) -> bool:
	var caster = context.get("caster", null)
	if not caster:
		GASLogger.error("caster is null！ cant register effect trigger!")
		return false
	var ability_component : AbilityComponent = context.ability_component
	ability_component.add_ability_trigger(trigger_type, self)
	_registered = true
	return true

## 解除注册
func _unregister_trigger() -> void:
	# 清理所有信号连接
	if not _registered: return
	var ability_component : AbilityComponent = _original_context.get("ability_component")
	ability_component.remove_ability_trigger(trigger_type, self)
	_registered = false
