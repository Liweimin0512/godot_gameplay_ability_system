extends PresentationHandler
class_name ProjectileHandler

## 投射物处理器接口

func handle_effect(config: Dictionary, context: Dictionary) -> void:
	if not config.has("scene"):
		GASLogger.error("ProjectileHandler: projectile scene is empty")
		return
	
	var projectile_scene = config["scene"]
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
		
	# 添加到场景
	var owner = config.get("actor", null)
	projectile.set("config", config)
	owner.get_parent().add_child(projectile)


class ProjectileConfig:
	extends RefCounted

	var scene : String = ""
	var speed : float = 500.0
	var target : Node = null

	func to_config() -> Dictionary:
		return {
			"scene": scene,
			"speed": speed,
			"target": target
		}
	
	static func from_config(config: Dictionary) -> ProjectileConfig:
		var projectile_config = ProjectileConfig.new()
		projectile_config.scene = config.get("scene", "")
		projectile_config.speed = config.get("speed", 500.0)
		projectile_config.target = config.get("target", null)
		return projectile_config
