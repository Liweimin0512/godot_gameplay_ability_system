extends ControlNode
class_name ControlSelectorNode

## 选择节点：执行子节点直到一个成功

func _execute(context: Dictionary) -> STATUS:
	for child in children:
		var status = await child.execute(context)
		if status != STATUS.FAILURE:
			return status
	return STATUS.FAILURE

func _revoke() -> STATUS:
	for child in children:
		var status = await child.revoke()
		if status != STATUS.FAILURE:
			return status
	return STATUS.FAILURE
