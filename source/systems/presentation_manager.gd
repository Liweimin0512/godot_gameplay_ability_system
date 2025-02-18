extends Node
class_name PresentationManager

## 表现配置

## 效果处理器映射
var _action_handlers: Dictionary = {
		"animation": AnimationEffectHandler.new(),
		"projectile": ProjectileEffectHandler.new(),
		"particle": ParticleEffectHandler.new(),
		"sound": SoundEffectHandler.new(),
		"camera": CameraEffectHandler.new()
	}

var is_initialized := false
var _presentation_table_type : TableType


signal initialized(success: bool)


func initialize(presentation_table_type : TableType, action_handlers: Dictionary) -> void:
	if is_initialized:
		return
	_presentation_table_type = presentation_table_type
	var _on_presentation_config_loaded = func(_result: Variant):
		is_initialized = true
		initialized.emit(true)
	# 加载表现配置
	DataManager.load_data_table(presentation_table_type, _on_presentation_config_loaded)
	# 注册效果处理器
	_action_handlers = action_handlers
	_register_effect_handlers()
	

func _ready() -> void:
	# 订阅游戏事件
	AbilitySystem.game_event.connect(_on_game_event)


## 注册效果处理器
func register_effect_handler(type: String, handler: EffectHandler) -> void:
	_action_handlers[type] = handler


## 取消注册效果处理器
func unregister_effect_handler(type: String) -> void:
	_effect_handlers.erase(type)


## 加载表现配置
func _load_presentation_config(config_path: String) -> void:
	if not FileAccess.file_exists(config_path):
		push_warning("Presentation config not found: " + config_path)
		return
	
	var file = FileAccess.open(config_path, FileAccess.READ)
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error == OK:
		_presentation_config = json.get_data()
	else:
		push_warning("Failed to parse presentation config: " + json.get_error_message())


## 处理游戏事件
func _on_game_event(event_type: AbilitySystem.GameEventType, context: Dictionary) -> void:
	var ability_name = context.get("ability_name")
	if not ability_name or not _presentation_config.has("ability_presentations"):
		return
	
	var presentations = _presentation_config["ability_presentations"]
	if not presentations.has(ability_name):
		return
	
	var ability_presentation = presentations[ability_name]
	if not ability_presentation.has("events"):
		return
	
	var events = ability_presentation["events"]
	var event_name = AbilitySystem.GameEventType.keys()[event_type]
	if not events.has(event_name):
		return
	
	var event_config = events[event_name]
	_process_event_config(event_config, context)

## 处理事件配置
func _process_event_config(config: Dictionary, context: Dictionary) -> void:
	# 处理动画
	if config.has("animations"):
		for anim_config in config["animations"]:
			_handle_effect("animation", anim_config, context)
	
	# 处理特效
	if config.has("effects"):
		for effect_config in config["effects"]:
			var effect_type = effect_config.get("type")
			if effect_type and _effect_handlers.has(effect_type):
				_handle_effect(effect_type, effect_config, context)
	
	# 处理声音
	if config.has("sound_effects"):
		for sound_config in config["sound_effects"]:
			_handle_effect("sound", sound_config, context)
	
	# 处理相机效果
	if config.has("camera_effects"):
		for camera_config in config["camera_effects"]:
			_handle_effect("camera", camera_config, context)


## 处理具体效果
func _handle_effect(type: String, config: Dictionary, context: Dictionary) -> void:
	if not _effect_handlers.has(type):
		return
	
	var handler = _effect_handlers[type]
	if handler.has_method("handle_effect"):
		handler.handle_effect(config, context)

