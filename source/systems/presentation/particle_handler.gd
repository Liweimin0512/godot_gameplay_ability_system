extends PresentationHandler
class_name ParticleHandler

var _active_particles: Dictionary = {}

func play(owner: Node, config: Dictionary) -> void:
    var particle_scene = config.get("scene", "")
    if particle_scene.is_empty():
        GASLogger.error("ParticleHandler: particle scene is empty")
        return
        
    # 加载粒子场景
    var scene = load(particle_scene)
    if not scene:
        GASLogger.error("ParticleHandler: failed to load particle scene: {0}".format([particle_scene]))
        return
        
    # 实例化粒子
    var particle: GPUParticles2D = scene.instantiate()
    if not particle:
        return
        
    # 设置位置
    var offset = config.get("offset", Vector2.ZERO)
    particle.position = offset
    
    # 设置自动销毁
    if config.get("one_shot", true):
        particle.one_shot = true
        particle.finished.connect(func(): particle.queue_free())
    
    # 添加到场景
    owner.add_child(particle)
    _active_particles[owner] = particle

func stop(owner: Node) -> void:
    if _active_particles.has(owner):
        var particle = _active_particles[owner]
        if is_instance_valid(particle):
            particle.queue_free()
        _active_particles.erase(owner)