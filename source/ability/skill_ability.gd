extends Ability
class_name SkillAbility

## 技能

## 目标类型，如self, ally, enemy
@export var target_type: StringName
## 技能消耗
@export var ability_costs: Array[AbilityCost] = []
## 冷却时间
@export var cooldown: float = 0.0
## 当前冷却时间
@export_storage var current_cooldown : float = 0.0:
	set(value):
		current_cooldown = value
		cooldown_changed.emit(current_cooldown)
## 技能是否显示在UI中
@export var is_show : bool = true
## 是否正处在冷却状态
var is_cooldown: bool:
	get:
		return current_cooldown > 0
## 是否为可用的主动技能
var is_available : bool = false:
	get:
		if is_auto_cast or is_cooldown: return false
		if can_cost: return true
		return false
## 是否足够消耗
var can_cost: bool = false:
	get:
		for cost in ability_costs:
			if not cost.can_cost(_context):
				return false
		return true

## 技能上下文
var _context : Dictionary = {}

signal cooldown_changed(value: float) 

func _init() -> void:
	resource_local_to_scene = true
	ability_tags.append("skill")

## 应用冷却
func apply_cooldown() -> void:
	if cooldown <= 0: return
	current_cooldown = cooldown

func _apply(context: Dictionary) -> void:
	_context = context

func _remove(context: Dictionary) -> void:
	_context.clear()

## 执行技能
func _cast(context: Dictionary) -> void:
	_context = context
	var caster : Node = context.get("caster")
	var target : Node
	if target_type == "self":
		target = caster
	else:
		target = _context.get("target", null)
	if can_cost:
		cost(_context)
	apply_cooldown()
	context.set("target", target)

## 消耗
func cost(context: Dictionary) -> void:
	for cost in ability_costs:
		cost.cost(context)

## 更新冷却时间
func _update_cooldown(amount: int) -> void:
	if is_cooldown:
		current_cooldown -= amount

func _to_string() -> String:
	return "{0} cooldown: {1}".format([ability_name, current_cooldown])
