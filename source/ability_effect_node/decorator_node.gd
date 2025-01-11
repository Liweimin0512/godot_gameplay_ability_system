extends AbilityEffectNode
class_name DecoratorNode

## 装饰器节点：修改或增强单个子节点的行为

@export var child: AbilityEffectNode

func set_child(new_child: AbilityEffectNode) -> void:
	child = new_child

func clear_child() -> void:
	if not child: return
	child = null

func _revoke() -> STATUS:
	return await child.revoke() if child else STATUS.SUCCESS

func _get_effect_node(effect_name: StringName) -> AbilityEffectNode:
	if effect_name == "":
		return self
	return child.get_node(effect_name) if child else null
