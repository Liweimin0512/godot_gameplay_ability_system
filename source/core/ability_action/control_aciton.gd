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

func _apply(context: Dictionary) -> void:
	for child in children:
		child.apply(context)

func _update(delta: float) -> void:
	for child in children:
		child.update(delta)


func _get_action(action_name: StringName) -> AbilityAction:
	for child in children:
		if child.action_name == action_name:
			return child
		var node = child.get_node(action_name)
		if node:
			return node
	return null
