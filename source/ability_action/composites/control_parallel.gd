extends ControlAction
class_name ControlParallel

## 并行节点：同时执行所有子节点

enum POLICY {
	REQUIRE_ALL,    # 所有子节点都成功才算成功
	REQUIRE_ONE     # 一个子节点成功就算成功
}

## 成功策略：所有子节点都执行完才算成功，或者只要一个子节点成功就算成功
@export var success_policy: POLICY = POLICY.REQUIRE_ALL
## 当前状态
var status_type: STATUS = STATUS.FAILURE
## 已经执行的子节点
var _executed_children: Array[AbilityAction] = []

## 执行完毕
signal children_executed


## 执行
func _execute(context: AbilityContext) -> STATUS:
	_executed_children.clear()
	for child in children:
		if not child.executed.is_connected(_on_child_executed):
			child.executed.connect(_on_child_executed.bind(child))
	for child in children:
		child.execute(context)
	await children_executed
	return status_type


## 撤销
func _revoke() -> bool:
	for child in _executed_children:
		child.revoke()
	_executed_children.clear()
	return true


## 执行
func _on_child_executed(status: STATUS, child: AbilityAction) -> void:
	_executed_children.append(child)
	if success_policy == POLICY.REQUIRE_ONE:
		status_type = STATUS.SUCCESS
		children_executed.emit()
	else:
		# 所有子节点都执行完了
		if _executed_children.size() >= children.size():
			status_type = STATUS.SUCCESS
			children_executed.emit()
