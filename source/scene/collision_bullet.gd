extends Node2D
class_name CollisionBullet

## 基于碰撞检测的子弹

@export var hit_area : Area2D

## 击中目标
signal hit_target(target: Node2D)

var caster: Node2D
var target: Node2D
var start_position: Vector2
var target_position: Vector2
var speed: float

func _ready() -> void:
	hit_area.area_entered.connect(_on_hit_area_entered)
	hit_area.body_entered.connect(_on_hit_body_entered)

func _process(delta: float) -> void:
	_move_to_target(delta)

func setup(context: Dictionary) -> void:
	caster = context.get("caster")
	target = context.get("target")
	start_position = context.get("start_position")
	target_position = context.get("target_position")
	speed = context.get("speed")
	position = start_position

func _on_hit_area_entered(area: Area2D) -> void:
	hit_target.emit(area)

func _on_hit_body_entered(body: Node2D) -> void:
	hit_target.emit(body)

func _move_to_target(delta: float) -> void:
	global_position = global_position.move_toward(target_position, speed * delta)
