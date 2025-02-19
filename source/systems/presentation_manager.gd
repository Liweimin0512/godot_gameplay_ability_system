extends PresentationManagerInterface
class_name PresentationManager

## 表现配置

## 效果处理器映射
var _action_handlers: Dictionary = {
		"animation": AnimationHandler.new(),
		"projectile": ProjectileHandler.new(),
		"particle": ParticleHandler.new(),
		"sound": SoundHandler.new(),
		"camera": CameraHandler.new()
	}

var _presentation_table_type : TableType

func initialize(presentation_table_type : TableType, action_handlers: Dictionary = {}) -> void:
	if _initialized:
		return
	_presentation_table_type = presentation_table_type
	var _on_presentation_config_loaded = func(_result: Variant):
		_initialized = true
		initialized.emit(true)
	# 加载表现配置
	DataManager.load_data_table(presentation_table_type, _on_presentation_config_loaded)
	# 注册效果处理器
	_action_handlers.merge(action_handlers, true)
	AbilitySystem.ability_event.connect(_on_ability_event)


## 注册效果处理器
func register_effect_handler(type: String, handler: PresentationHandler) -> void:
	_action_handlers[type] = handler

## 获取效果处理器
func get_effect_handler(type: String) -> PresentationHandler:
	return _action_handlers.get(type, null)

## 取消注册效果处理器
func unregister_effect_handler(type: String) -> void:
	if not _action_handlers.has(type):
		GASLogger.error("Invalid effect handler type: " + type)
		return
	_action_handlers.erase(type)


## 处理游戏事件
func _on_ability_event(event_type: StringName, context: Dictionary = {}) -> void:
	var ability : Ability = context.get("ability", null)
	if not ability:
		GASLogger.error("Ability event context does not contain ability")
		return
	var ability_presentation = DataManager.get_table_item(_presentation_table_type.table_name, ability.ability_name)
	if not ability_presentation:
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
			var effect_type : StringName = effect_config.get("type", "")
			if not effect_type.is_empty() and _action_handlers.has(effect_type):
				_handle_effect(effect_type, effect_config, context)
			else:
				GASLogger.error("Invalid effect type: " + effect_type)


## 处理具体效果
func _handle_effect(type: String, config: Dictionary, context: Dictionary) -> void:
	if not _action_handlers.has(type):
		GASLogger.error("Invalid effect type: " + type)
		return
	
	var handler = _action_handlers[type]
	if handler.has_method("handle_effect"):
		handler.handle_effect(config, context)
