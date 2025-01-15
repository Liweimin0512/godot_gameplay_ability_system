extends Node
class_name W_Status

const W_BUFF = preload("res://addons/godot_gameplay_ability_system/source/scene/widget/w_buff.tscn")
const W_ABILITY_RESOURCE = preload("res://addons/godot_gameplay_ability_system/source/scene/widget/w_ability_resource.tscn")

@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var w_buff_container: MarginContainer = %W_BuffContainer
@onready var grid_container: GridContainer = %GridContainer

@export var ability_resource_colors: Dictionary[StringName, Color] = {
	"health": Color.RED,
	"rage": Color.DARK_RED,
	"energy": Color.YELLOW,
	"mana": Color.BLUE,
}

var _ability_character: Node

func setup(ability_character : Node) -> void:
	_ability_character = ability_character
	var ability_component : AbilityComponent = _ability_character.get("ability_component")
	var ability_resource_component: AbilityResourceComponent = _ability_character.get("ability_resource_component")
	if not ability_component:
		GASLogger.error("cannt found ability component in node: {0}".format([ability_character]))
		return
	if not ability_resource_component:
		GASLogger.error("cannt found ability resource component in node: {0}".format([ability_character]))
	$VBoxContainer/W_AbilityResource.queue_free()
	for res : AbilityResource in ability_resource_component.get_resources():
		var w_res : W_AbilityResource = W_ABILITY_RESOURCE.instantiate()
		v_box_container.add_child(w_res)
		w_res.setup(res, ability_resource_colors[res.ability_resource_id])
	ability_component.ability_applied.connect(
		func(ability: Ability, _context: Dictionary) -> void:
			if ability is BuffAbility: 
				add_buff(ability)
	)
	ability_component.ability_removed.connect(
		func(ability: Ability, _context: Dictionary) -> void:
			if ability is BuffAbility: 
				remove_buff(ability)
	)
	w_buff_container.move_to_front()

func add_buff(buff: BuffAbility) -> void:
	var w_buff : W_Buff = W_BUFF.instantiate()
	grid_container.add_child(w_buff)
	w_buff.setup(buff)

func get_buff(buff: BuffAbility) -> W_Buff:
	for w_buff : W_Buff in grid_container.get_children():
		if w_buff.buff == buff:
			return w_buff
	return null

func remove_buff(buff: BuffAbility) -> void:
	var w_buff := get_buff(buff)
	if w_buff:
		grid_container.remove_child(w_buff)
		w_buff.queue_free()
