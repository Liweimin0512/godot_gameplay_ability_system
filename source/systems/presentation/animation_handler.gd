extends PresentationHandler
class_name AnimationHandler


func handle_effect(config: Dictionary, context: Dictionary) -> void:
	var animation_config := AnimationConfig.from_config(config)
	if not animation_config:
		return

	var targets : Array[Node] = _get_targets(config, context)
	if targets.is_empty():
		return
	
	for target in targets:
		_play(target, animation_config)

func _play(owner: Node, animation_config: AnimationConfig) -> void:
	var animator = _get_animator(owner)
	if not animator:
		return
		
	var anim_name = animation_config.anim_name
		
	if animation_config.blend:
		var blend_time = animation_config.blend_time
		animator.play(anim_name, blend_time)
	else:
		animator.play(anim_name)

func _stop(owner: Node) -> void:
	var animator = _get_animator(owner)
	if animator:
		animator.stop()

func _get_animator(owner: Node) -> AnimationPlayer:
	if not owner:
		return null
	
	# 尝试获取动画播放器
	var animator = owner.get_node_or_null("AnimationPlayer")
	if not animator:
		GASLogger.error("AnimationHandler: AnimationPlayer not found in {0}".format([owner.name]))
		return null
	
	return animator

class AnimationConfig:
	var anim_name : String
	var blend : bool = false
	var blend_time : float = 0.2

	func _init(_anim_name : String, _blend : bool, _blend_time : float) -> void:
		anim_name = _anim_name
		blend = _blend
		blend_time = _blend_time
	
	func to_config() -> Dictionary:
		return {
			"animation": anim_name,
			"blend": blend,
			"blend_time": blend_time
		}
	
	static func from_config(config : Dictionary) -> AnimationConfig:
		if config.get("animation", "").is_empty():
			GASLogger.error("AnimationHandler: animation name is empty")
			return null
		return AnimationConfig.new(
				config.get("animation", ""),
				config.get("blend", false),
				config.get("blend_time", 0.2))
