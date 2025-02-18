# presentation/handlers/camera_handler.gd
extends PresentationHandler
class_name CameraHandler

var _active_tweens: Dictionary = {}

func play(owner: Node, config: Dictionary) -> void:
    var camera = _get_camera(owner)
    if not camera:
        return
        
    # 处理震动
    if config.has("shake"):
        var shake_config = config.get("shake")
        _apply_shake(camera, shake_config)
    
    # 处理缩放
    if config.has("zoom"):
        var zoom_config = config.get("zoom")
        _apply_zoom(camera, zoom_config)
    
    # 处理偏移
    if config.has("offset"):
        var offset_config = config.get("offset")
        _apply_offset(camera, offset_config)

func stop(owner: Node) -> void:
    if _active_tweens.has(owner):
        var tween = _active_tweens[owner]
        if is_instance_valid(tween):
            tween.kill()
        _active_tweens.erase(owner)

func _get_camera(owner: Node) -> Camera2D:
    var camera = owner.get_node_or_null("Camera2D")
    if not camera:
        GASLogger.error("CameraHandler: Camera2D not found in {0}".format([owner.name]))
        return null
    return camera

func _apply_shake(camera: Camera2D, config: Dictionary) -> void:
    var strength = config.get("strength", 8.0)
    var duration = config.get("duration", 0.2)
    var frequency = config.get("frequency", 15.0)
    
    var time = 0.0
    var tween = camera.create_tween()
    _active_tweens[camera.owner] = tween
    
    while time < duration:
        var offset = Vector2(
            randf_range(-strength, strength),
            randf_range(-strength, strength)
        )
        tween.tween_property(camera, "offset", offset, 1.0 / frequency)
        time += 1.0 / frequency
        
    tween.tween_property(camera, "offset", Vector2.ZERO, 1.0 / frequency)

func _apply_zoom(camera: Camera2D, config: Dictionary) -> void:
    var target_zoom = config.get("value", Vector2.ONE)
    var duration = config.get("duration", 0.5)
    
    var tween = camera.create_tween()
    _active_tweens[camera.owner] = tween
    tween.tween_property(camera, "zoom", target_zoom, duration)

func _apply_offset(camera: Camera2D, config: Dictionary) -> void:
    var target_offset = config.get("value", Vector2.ZERO)
    var duration = config.get("duration", 0.5)
    
    var tween = camera.create_tween()
    _active_tweens[camera.owner] = tween
    tween.tween_property(camera, "offset", target_offset, duration)