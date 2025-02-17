extends Node

## 表现配置
var _presentation_config: Dictionary = {}
## 效果处理器映射
var _effect_handlers: Dictionary = {}

func _ready() -> void:
	# 订阅游戏事件
	AbilitySystem.get_singleton().game_event.connect(_on_game_event)
	# 加载表现配置
	_load_presentation_config()
	# 注册效果处理器
	_register_effect_handlers()

## 加载表现配置
func _load_presentation_config() -> void:
	var config_path = "res://data/presentation/presentation_config.json"
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

## 注册效果处理器
func _register_effect_handlers() -> void:
	# 注册基础效果处理器
	_effect_handlers = {
		"animation": AnimationEffectHandler.new(),
		"projectile": ProjectileEffectHandler.new(),
		"particle": ParticleEffectHandler.new(),
		"sound": SoundEffectHandler.new(),
		"camera": CameraEffectHandler.new()
	}

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

## 解析变量和公式
func _parse_value(value: Variant, context: Dictionary) -> Variant:
	if typeof(value) != TYPE_STRING:
		return value
	
	# 处理上下文变量
	if value.begins_with("@context:"):
		var var_name = value.substr(9)
		return context.get(var_name, null)
	
	# 处理公式
	if value.begins_with("@formula:"):
		var formula = value.substr(9)
		# TODO: 实现公式解析器
		return _evaluate_formula(formula, context)
	
	return value

## 评估公式
func _evaluate_formula(formula: String, context: Dictionary) -> Variant:
	# TODO: 实现一个简单的公式解析器
	# 示例: "1.0 - (@context:chain_index * 0.2)"
	return 1.0  # 临时返回默认值
