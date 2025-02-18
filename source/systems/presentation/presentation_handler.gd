extends PresentationHandler
class_name AnimationHandler

func play(owner: Node, config: Dictionary) -> void:
    var animator = _get_animator(owner)
    if not animator:
        return
        
    var anim_name = config.get("animation", "")
    if anim_name.is_empty():
        GASLogger.error("AnimationHandler: animation name is empty")
        return
        
    if config.get("blend", false):
        var blend_time = config.get("blend_time", 0.2)
        animator.play(anim_name, blend_time)
    else:
        animator.play(anim_name)

func stop(owner: Node) -> void:
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