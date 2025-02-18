extends PresentationHandler
class_name ProjectileHandler

var _active_projectiles: Dictionary = {}

func play(owner: Node, config: Dictionary) -> void:
    var projectile_scene = config.get("scene", "")
    if projectile_scene.is_empty():
        GASLogger.error("ProjectileHandler: projectile scene is empty")
        return
        
    # 加载投射物场景
    var scene = load(projectile_scene)
    if not scene:
        GASLogger.error("ProjectileHandler: failed to load projectile scene: {0}".format([projectile_scene]))
        return
        
    # 实例化投射物
    var projectile = scene.instantiate()
    if not projectile:
        return
        
    # 设置基本属性
    var start_pos = owner.global_position
    var target = config.get("target")
    if not target:
        GASLogger.error("ProjectileHandler: target is null")
        return
        
    projectile.global_position = start_pos
    projectile.speed = config.get("speed", 500)
    projectile.target = target
    
    # 添加到场景
    owner.get_tree().current_scene.add_child(projectile)
    _active_projectiles[owner] = projectile

func stop(owner: Node) -> void:
    if _active_projectiles.has(owner):
        var projectile = _active_projectiles[owner]
        if is_instance_valid(projectile):
            projectile.queue_free()
        _active_projectiles.erase(owner)