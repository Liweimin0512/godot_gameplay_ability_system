extends Node
class_name AbilityTriggerManager

## 技能触发器集
@export_storage var _ability_triggers : Dictionary[StringName, Array]

signal ability_trigger_success(ability: Ability)
signal ability_trigger_failed(ability: Ability)

## 触发
func trigger(trigger_type: StringName, context: Dictionary) -> void:
	var triggers : Array = _ability_triggers.get(trigger_type, [])
	if triggers.is_empty():
		return
	for trigger : DecoratorTrigger in triggers:
		await trigger.handle_trigger(context, func(result: bool, ability: Ability) -> void:
			if result:
				GASLogger.debug("触发器成功：{0}".format([ability]))
				ability_trigger_success.emit(ability)
			else:
				GASLogger.debug("触发器失败：{0}".format([ability]))
				ability_trigger_failed.emit(ability)
		)


## 添加触发器
func add_ability_trigger(trigger_type: StringName, trigger: DecoratorTrigger) -> void:
	if _ability_triggers.has(trigger_type):
		_ability_triggers[trigger_type].append(trigger)
	else:
		_ability_triggers[trigger_type] = [trigger]


## 移除触发器
func remove_ability_trigger(trigger_type: StringName, trigger: DecoratorTrigger) -> void:
	var triggers : Array[DecoratorTrigger] = _ability_triggers.get(trigger_type, [])
	if triggers.has(trigger):
		triggers.erase(trigger)
		_ability_triggers[trigger_type] = triggers
