extends AbilityAction
class_name DecoratorAction

## 装饰器节点：修改或增强单个子节点的行为

@export var child: AbilityAction


## 设置子节点
func set_child(new_child: AbilityAction) -> void:
	child = new_child


## 清除子节点
func clear_child() -> void:
	if not child: return
	child = null


func get_action_description() -> String:
	return child.get_action_description() if child else ""


## 撤销
func _revoke() -> bool:
	return child.revoke() if child else true


## 获取子节点
func _get_action(p_action_name: StringName) -> AbilityAction:
	return child.get_action(p_action_name) if child else null

