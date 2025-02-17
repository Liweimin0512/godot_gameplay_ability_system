extends Node
class_name AbilityComponent

## 技能组件，维护广义上的技能（BUFF、SKILL）等
## 当前单位所拥有的全部技能（包括BUFF）

@export var _abilities : Array[Ability]
## 技能触发器集
@export_storage var _ability_triggers : Dictionary[StringName, Array]
## 技能标签
@export var _ability_tags : Array[StringName] = []

## 技能释放前发出
signal ability_cast_started(ability: Ability, context: Dictionary)
## 技能释放时发出
signal ability_cast_finished(ability: Ability, context: Dictionary)
## 技能应用触发
signal ability_applied(ability: Ability, context: Dictionary)
## 技能移除触发
signal ability_removed(ability: Ability, context: Dictionary)
## 技能触发成功
signal ability_trigger_success(ability: Ability, context: Dictionary)
## 技能触发失败
signal ability_trigger_failed(ability: Ability, context: Dictionary)
## 游戏事件处理完成
signal game_event_handled(event_name: StringName, event_context: Dictionary)

func setup(
			ability_set: Array[Ability],
			ability_context: Dictionary = {}
		) -> void:
	for ability in ability_set:
		apply_ability(ability, ability_context)
		print("ability_component: {0} 初始化".format([owner.to_string()]))

#region 技能相关

## 获取全部技能
func get_abilities(ability_tags: Array[StringName] = []) -> Array[Ability]:
	# 空标签表示获取全部技能
	var abilities : Array[Ability] = []
	# 判断标签是否匹配
	for ability : Ability in _abilities:
		if ability_tags.is_empty() or ability.has_tags(ability_tags):
			abilities.append(ability)
	return abilities

## 获取相同名称的技能
func get_same_ability(ability: Ability) -> Ability:
	for a in _abilities:
		if a.ability_name == ability.ability_name and a.ability_tags == ability.ability_tags:
			return a
	return null

## 应用技能
func apply_ability(ability: Ability, ability_context: Dictionary) -> void:
	ability_context.merge({
		"tree": owner.get_tree(),
		"ability_component": self,
		})
	ability.applied.connect(_on_ability_applied.bind(ability))
	ability.cast_started.connect(_on_ability_cast_started.bind(ability))
	ability.cast_finished.connect(_on_ability_cast_finished.bind(ability))
	ability.removed.connect(_on_ability_removed.bind(ability))
	ability.apply(ability_context)
	_abilities.append(ability)

## 移除技能
func remove_ability(ability: Ability, context: Dictionary) -> void:
	if ability.applied.is_connected(_on_ability_applied):
		ability.applied.disconnect(_on_ability_applied.bind(ability))
	if ability.cast_started.is_connected(_on_ability_cast_started):
		ability.cast_started.disconnect(_on_ability_cast_started.bind(ability))
	if ability.cast_finished.is_connected(_on_ability_cast_finished):
		ability.cast_finished.disconnect(_on_ability_cast_finished.bind(ability))
	if ability.removed.is_connected(_on_ability_removed):
		ability.removed.disconnect(_on_ability_removed.bind(ability))
	ability.remove(context)
	_abilities.erase(ability)

## 尝试释放技能
func try_cast_ability(ability: Ability, context: Dictionary) -> bool:
	var ok = await ability.cast(context)
	return ok

#endregion

#region 触发器相关

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

#endregion

#region 标签相关
func has_ability_tag(tag: StringName) -> bool:
	return _ability_tags.has(tag)

func get_ability_tags() -> Array[StringName]:
	return _ability_tags

func add_ability_tag(tag: StringName) -> void:
	_ability_tags.append(tag)

func remove_ability_tag(tag: StringName) -> void:
	_ability_tags.erase(tag)
#endregion

#region 事件处理

func _ready() -> void:
	AbilitySystem.get_singleton().presentation_event.connect(_on_presentation_event)

## 处理表现层事件
func _on_presentation_event(event_type: AbilitySystem.PresentationType, context: Dictionary) -> void:
	# 只处理与当前单位相关的事件
	if not context.has("target") or context.target != owner:
		return
	
	match event_type:
		AbilitySystem.PresentationType.UNIT_ANIMATION:
			_handle_animation_event(context)
		AbilitySystem.PresentationType.UNIT_EFFECT:
			_handle_unit_effect_event(context)

## 处理动画事件
func _handle_animation_event(context: Dictionary) -> void:
	if not owner.has_method("play_animation"):
		GASLogger.error("Owner has no play_animation method")
		return
	
	var params = context.get("params", {})
	var blend_time = params.get("blend_time", 0.0)
	var custom_speed = params.get("custom_speed", 1.0)
	
	# 播放动画
	if context.has("callback"):
		# 如果有回调，等待动画完成
		await owner.play_animation(context.resource, blend_time, custom_speed)
		context.callback.call()
	else:
		owner.play_animation(context.resource, blend_time, custom_speed)

## 处理单位特效事件
func _handle_unit_effect_event(context: Dictionary) -> void:
	var effect_scene = context.resource as PackedScene
	if not effect_scene:
		GASLogger.error("Invalid effect scene")
		return
	
	var effect_instance = effect_scene.instantiate()
	owner.add_child(effect_instance)
	
	# 应用参数
	for key in context.get("params", {}):
		if effect_instance.has_property(key):
			effect_instance.set(key, context.params[key])
	
	# 如果特效是一次性的，设置自动销毁
	if effect_instance.has_method("_on_finished"):
		effect_instance._on_finished.connect(func():
			effect_instance.queue_free()
			if context.has("callback"):
				context.callback.call()
		)

func _on_ability_applied(context: Dictionary, ability: Ability) -> void:
	ability_applied.emit(ability, context)

func _on_ability_removed(context: Dictionary, ability: Ability) -> void:
	ability_removed.emit(ability, context)

func _on_ability_cast_started(context: Dictionary, ability: Ability) -> void:
	ability_cast_started.emit(ability, context)

func _on_ability_cast_finished(context: Dictionary, ability: Ability) -> void:
	ability_cast_finished.emit(ability, context)

#endregion

func _to_string() -> String:
	return owner.to_string()
