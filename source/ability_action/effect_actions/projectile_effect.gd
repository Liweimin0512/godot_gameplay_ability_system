@tool
extends AbilityAction

@export var speed: float = 500.0
@export var wait_for_hit: bool = true

func _perform_action(context: Dictionary) -> STATUS:
	var from_pos = context.get("from")
	var to_pos = context.get("to")
	
	if not from_pos or not to_pos:
		return STATUS.FAILURE
	
	# 发送投射物开始事件
	var ability_system = AbilitySystem.get_singleton()
	ability_system.emit_game_event(
		AbilitySystem.GameEventType.PROJECTILE_START,
		{
			"ability_name": context.get("ability_name"),
			"from": from_pos,
			"to": to_pos,
			"speed": speed,
			"source": context.get("source"),
			"target": context.get("target"),
			"chain_index": context.get("index", 0)
		}
	)
	
	if wait_for_hit:
		# 等待投射物命中
		var distance = from_pos.distance_to(to_pos)
		var duration = distance / speed
		await get_tree().create_timer(duration).timeout
		
		# 发送投射物命中事件
		ability_system.emit_game_event(
			AbilitySystem.GameEventType.PROJECTILE_HIT,
			{
				"ability_name": context.get("ability_name"),
				"hit_position": to_pos,
				"source": context.get("source"),
				"target": context.get("target"),
				"chain_index": context.get("index", 0)
			}
		)
	
	return STATUS.SUCCESS
