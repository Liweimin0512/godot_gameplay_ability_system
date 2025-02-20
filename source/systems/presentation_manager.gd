extends PresentationManagerInterface
class_name PresentationManager

## 表现配置


var _presentation_table_type : TableType

## 表现请求
signal presentation_requested(presentation_id: StringName, config: Dictionary, context: Dictionary)

func initialize(presentation_table_type : TableType) -> void:
	if _initialized:
		return
	_presentation_table_type = presentation_table_type
	var _on_presentation_config_loaded = func(_result: Variant):
		_initialized = true
		initialized.emit(true)
	# 加载表现配置
	DataManager.load_data_table(presentation_table_type, _on_presentation_config_loaded)
	AbilitySystem.ability_event.connect(_on_ability_event)

## 处理游戏事件
func _on_ability_event(event_type: StringName, context: Dictionary = {}) -> void:
	var ability : Ability = context.get("ability", null)
	if not ability:
		GASLogger.error("Ability event context does not contain ability")
		return
	var ability_presentation = DataManager.get_table_item(_presentation_table_type.table_name, ability.ability_id)
	if not ability_presentation or ability_presentation.is_empty():
		GASLogger.error("Invalid ability name: " + ability.ability_name)
		return
	
	var events = ability_presentation["events"]
	if not events.has(event_type):
		return
	
	var event_config = events[event_type]
	_process_event_config(event_config, context)


## 处理事件配置
func _process_event_config(config: Dictionary, context: Dictionary) -> void:
	# 处理动画
	if config.has("animations"):
		for anim_config in config["animations"]:
			_handle_effect("animation", anim_config, context)

	# 处理声音
	if config.has("sound_effects"):
		for sound_config in config["sound_effects"]:
			_handle_effect("sound", sound_config, context)
	
	# 处理相机效果
	if config.has("camera_effects"):
		for camera_config in config["camera_effects"]:
			_handle_effect("camera", camera_config, context)

	
	# 处理特效
	if config.has("effects"):
		for effect_config in config["effects"]:
			_handle_effect("effect", effect_config, context)


## 处理具体效果
func _handle_effect(type: StringName, config: Dictionary, context: Dictionary) -> void:
	var pre_delay : float = config.get("pre_delay", 0.0)
	if pre_delay > 0.0:
		await get_tree().create_timer(pre_delay).timeout
	presentation_requested.emit(type, config, context)
