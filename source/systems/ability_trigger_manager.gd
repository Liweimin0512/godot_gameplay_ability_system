extends Node
class_name AbilityTriggerManager

## 技能触发器集
@export_storage var _ability_triggers : Dictionary[StringName, Array]

## 游戏事件处理完成
signal game_event_handled(event_name: StringName, event_context: Dictionary)

## 处理游戏事件
func handle_game_event(event_name: StringName, event_context: Dictionary = {}) -> void:
	GASLogger.info("{0} 接收到游戏事件：{1}，事件上下文{2}".format([self, event_name, event_context]))
	game_event_handled.emit(event_name, event_context)
	for ability in _abilities:
		if ability.has_method(event_name):
			ability.call(event_name, event_context)
	var triggers : Array = _ability_triggers.get(event_name, [])
	if triggers.is_empty():
		GASLogger.debug("没有找到触发器：{0}".format([event_name]))
		return
	for trigger : DecoratorTrigger in triggers:
		await trigger.handle_trigger(event_context, func(result: bool, ability: Ability) -> void:
			if result:
				GASLogger.debug("触发器成功：{0}".format([ability]))
				if ability is SkillAbility: ability.apply_cooldown()
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
