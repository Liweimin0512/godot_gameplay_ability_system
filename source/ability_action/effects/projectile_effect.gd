@tool
extends AbilityAction
class_name ProjectileEffect

## 投射物效果

## 投射物速度
@export var speed: float = 500.0
## 是否等待投射物碰撞
@export var wait_for_hit: bool = true
## 起始位置挂点
@export var from_node_type : StringName = ""
## 目标位置挂点
@export var to_node_type : StringName = ""

func _perform_action(context: AbilityEffectContext) -> STATUS:
	var from_pos = context.get("from")
	var to_pos = context.get("to")
	
	if not from_pos or not to_pos:
		return STATUS.FAILURE
	
	# 发送投射物开始事件
	AbilitySystem.push_ability_event("projectile_start", context)
	if wait_for_hit:
		# 等待投射物命中
		var distance = from_pos.distance_to(to_pos)
		var duration = distance / speed
		await AbilitySystem.get_tree().create_timer(duration).timeout
		
	# 发送投射物命中事件
	AbilitySystem.push_ability_event("projectile_hit", context)	
	return STATUS.SUCCESS

class ProjectileConfig:
	@export var speed: float = 500.0
	@export var wait_for_hit: bool = true

	func to_dict() -> Dictionary:
		return {
			"speed": speed,
			"wait_for_hit": wait_for_hit
		}

	static func from_dict(dict: Dictionary) -> ProjectileConfig:
		var config = ProjectileConfig.new()
		config.speed = dict.get("speed", 500.0)
		config.wait_for_hit = dict.get("wait_for_hit", true)
		return config
