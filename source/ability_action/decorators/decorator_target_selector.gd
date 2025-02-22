extends DecoratorAction
class_name DecoratorTargetSelector

## 目标选择器装饰器：选择目标

## 目标类型，self: 自身，ally: 友军，enemy: 敌军，all: 所有
@export_enum("self", "ally", "enemy", "all") var target_type : String = "self"
## 随机选择或者全部
@export_enum("random", "all") var select_type : String = "random"
## 随机个数
@export var random_amount: int = 1
## 是否并行执行
@export var is_parallel: bool = false
## 目标列表
var _targets : Array = []
## 已经执行的目标
var _executed_targets : Array = []

## 所有目标执行完毕
signal all_targets_executed
## 所有目标撤销完毕
signal all_targets_revoked


func _execute(context: Dictionary) -> STATUS:
	var enemies = context.get("enemies")
	var allies = context.get("allies")
	var caster = context.get("caster")
	if select_type == "random":
		_targets = _select_random(allies, enemies, caster)
	else:
		_targets = _select_all(allies, enemies, caster)

	for target in _targets:
		child.executed.connect(_on_child_executed.bind(target))
		var target_context = context.duplicate(true)
		target_context["target"] = target
		if is_parallel:
			child.execute(target_context)
		else:
			await child.execute(target_context)
	if is_parallel:
		await all_targets_executed
	return STATUS.SUCCESS


func _revoke() -> bool:
	for target in _targets:
		child.revoke()
	_targets.clear()
	_executed_targets.clear()
	return true


## 选择随机
func _select_random(allies: Array, enemies: Array, caster: Node) -> Array:
	var target_pool = []
	match target_type:
		"self":
			target_pool.append(caster)
		"ally":
			target_pool.append_array(allies)
		"enemy":
			target_pool.append_array(enemies)
		"all":
			target_pool.append_array(allies + enemies)
	var targets = []
	for i in range(random_amount):
		var target = target_pool.pick_random()
		target_pool.erase(target)
		targets.append(target)
	return targets

## 选择全部
func _select_all(allies: Array, enemies: Array, caster: Node) -> Array:
	match target_type:
		"self":
			return [caster]
		"ally":
			return allies
		"enemy":
			return enemies
		"all":
			return allies + enemies
	return []


func _on_child_executed(_status: STATUS, target: Node) -> void:
	_executed_targets.append(target)
	if _executed_targets.size() >= _targets.size():
		all_targets_executed.emit()