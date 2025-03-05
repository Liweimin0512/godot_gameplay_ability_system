extends AbilityAction
class_name ControlAction

## 控制节点：负责控制多个子节点的执行流程
@export var children: Array[AbilityAction]


func add_child(child: AbilityAction) -> void:
	children.append(child)


func remove_child(child: AbilityAction) -> void:
	children.erase(child)


func clear_children() -> void:
	children.clear()


func _get_action(p_action_name: StringName) -> AbilityAction:
	for child in children:
		var action = child.get_action(p_action_name)
		if action:
			return action
	return null


func get_action_description(context: AbilityEffectContext) -> String:
	var descriptions : Array[String] = []

	for child in children:
		var current_desc = child.get_action_description(context)
		if current_desc != "":
			descriptions.append(current_desc)
	
	return "\n".join(descriptions)
