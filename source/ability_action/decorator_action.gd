extends AbilityAction
class_name DecoratorAction

## 装饰器节点：修改或增强单个子节点的行为

@export var child: AbilityAction

func set_child(new_child: AbilityAction) -> void:
	child = new_child

func clear_child() -> void:
	if not child: return
	child = null

func _revoke(context: Dictionary) -> bool:
	return await child.revoke(context) if child else true

func _get_action(action_name: StringName) -> AbilityAction:
	if action_name == "":
		return self
	return child.get_node(action_name) if child else null
