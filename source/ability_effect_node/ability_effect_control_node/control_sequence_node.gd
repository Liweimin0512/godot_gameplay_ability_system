extends ControlNode
class_name ControlSequenceNode

## 序列节点：按顺序执行所有子节点，一个失败则整体失败

func _execute(context: Dictionary) -> STATUS:
	for child in children:
		var status = await child.execute(context)
		if status != STATUS.SUCCESS:
			return status
	return STATUS.SUCCESS

func _revoke() -> STATUS:
	for child in children:
		var status = await child.revoke()
		if status != STATUS.SUCCESS:
			return status
	return STATUS.SUCCESS
