extends PresentationHandler
class_name CameraHandler

var _camera : Camera2D

func set_camera(camera: Camera2D) -> void:
	_camera = camera

func handle_effect(config: Dictionary, _context: Dictionary) -> void:
	if not _camera:
		GASLogger.error("CameraHandler: Camera2D not found")
		return
		
	# 处理震动
	if config.has("shake"):
		var shake_config := CameraShakeConfig.from_dict(config)
		_apply_shake(_camera, shake_config)
	
	# 处理缩放
	if config.has("zoom"):
		var zoom_config := CameraZoomConfig.from_dict(config)
		_apply_zoom(_camera, zoom_config)
	
	# 处理偏移
	if config.has("offset"):
		var offset_config := CameraOffsetConfig.from_dict(config)
		_apply_offset(_camera, offset_config)


func _apply_shake(camera: Camera2D, config: CameraShakeConfig) -> void:
	var time = 0.0
	var tween = camera.create_tween()	
	while time < config.duration:
		var offset = Vector2(
			randf_range(-config.strength, config.strength),
			randf_range(-config.strength, config.strength)
		)
		tween.tween_property(camera, "offset", offset, 1.0 / config.frequency)
		time += 1.0 / config.frequency
	tween.tween_property(camera, "offset", Vector2.ZERO, 1.0 / config.frequency)

func _apply_zoom(camera: Camera2D, config: CameraZoomConfig) -> void:
	var tween = camera.create_tween()
	tween.tween_property(camera, "zoom", config.value, config.duration)


func _apply_offset(camera: Camera2D, config: CameraOffsetConfig) -> void:
	var tween = camera.create_tween()
	tween.tween_property(camera, "offset", config.value, config.duration)


class CameraShakeConfig:
	var strength : float = 8.0
	var duration : float = 0.2
	var frequency : float = 15.0

	func to_dict() -> Dictionary:
		return {
			"strength": strength,
			"duration": duration,
			"frequency": frequency
		}

	static func from_dict(config: Dictionary) -> CameraShakeConfig:
		var shake_config = CameraShakeConfig.new()
		shake_config.strength = config.get("strength", 8.0)
		shake_config.duration = config.get("duration", 0.2)
		shake_config.frequency = config.get("frequency", 15.0)
		return shake_config


class CameraZoomConfig:
	var value : Vector2 = Vector2.ONE
	var duration : float = 0.5

	func to_dict() -> Dictionary:
		return {
			"value": value,
			"duration": duration
		}

	static func from_dict(config: Dictionary) -> CameraZoomConfig:
		var zoom_config = CameraZoomConfig.new()
		zoom_config.value = config.get("value", Vector2.ONE)
		zoom_config.duration = config.get("duration", 0.5)
		return zoom_config


class CameraOffsetConfig:
	var value : Vector2 = Vector2.ZERO
	var duration : float = 0.5
	var ease_type : Tween.EaseType = Tween.EASE_IN_OUT
	var trans_type : Tween.TransitionType = Tween.TRANS_CUBIC

	func to_dict() -> Dictionary:
		return {
			"value": value,
			"duration": duration,
			"ease_type": ease_type,
			"trans_type": trans_type
		}
	
	static func from_dict(config: Dictionary) -> CameraOffsetConfig:
		var offset_config = CameraOffsetConfig.new()
		offset_config.value = config.get("value", Vector2.ZERO)
		offset_config.duration = config.get("duration", 0.5)
		offset_config.ease_type = config.get("ease_type", Tween.EASE_IN_OUT)
		offset_config.trans_type = config.get("trans_type", Tween.TRANS_CUBIC)
		return offset_config
