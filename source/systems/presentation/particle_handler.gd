extends PresentationHandler
class_name ParticleHandler

## 粒子处理器接口

func handle_effect(config: Dictionary, context: Dictionary) -> void:

	var targets := _get_targets(config, context)

	for target in targets:
		# 创建并添加粒子
		_create_and_add_particle(target, config)


func _create_and_add_particle(target: Node, config: Dictionary) -> void:
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
		
	
	# 设置自动销毁
	if config.get("one_shot", true):
		particle.one_shot = true
		particle.finished.connect(func(): particle.queue_free())
	
	# 添加到场景
	# 设置位置, 根据配置决定添加在target的头部、胸部、脚部还是手部
	if target.has_method("get_particle_attachment"):
		var attachment = target.get_particle_attachment()
		attachment.add_child(particle)
	else:
		GASLogger.error("ParticleHandler: target does not have method get_particle_attachment")
		target.add_child(particle)
