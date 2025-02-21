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

func _apply(context: Dictionary) -> void:
	if child:
		child.apply(context)

## 撤销
func _revoke(context: Dictionary) -> bool:
	return child.revoke(context) if child else true


func _update(delta: float) -> void:
	if not child: return
	child.update(delta)


## 能否执行
func _can_execute(context: Dictionary) -> bool:
	return true if not child else child.can_execute(context)


## 获取子节点
func _get_action(action_name: StringName) -> AbilityAction:
	if action_name == "":
		return self
	return child.get_node(action_name) if child else null
