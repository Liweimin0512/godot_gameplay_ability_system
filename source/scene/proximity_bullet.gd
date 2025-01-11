extends Node2D
class_name ProximityBullet

## 基于距离的子弹

## 击中距离
@export var hit_distance : float = 10
## 目标
var target: Node2D
var caster: Node2D
var start_position: Vector2
var target_position: Vector2
var speed: float

## 击中目标
signal hit_target(target: Node2D)

func _process(delta: float) -> void:
	var distance = global_position.distance_to(target.global_position)
	if distance <= hit_distance:
		hit_target.emit(target)
		queue_free()
	else:
		move_to_target(delta)

func setup(context: Dictionary) -> void:
	caster = context.get("caster")
	target = context.get("target")
	start_position = context.get("start_position")
	target_position = context.get("target_position")
	speed = context.get("speed")
	position = start_position

## 移动到目标
func move_to_target(delta: float) -> void:
	global_position = global_position.move_toward(target.global_position, speed * delta)
