extends ControlAction
class_name ControlSelector

## 选择节点：执行子节点直到一个成功

var _last_selected_index: int = -1

func _execute(context: Dictionary) -> STATUS:
	var index: int = 0
	for child in children:
		var status = await child.execute(context)
		if status != STATUS.FAILURE:
			_last_selected_index = index
			return status
		index += 1
	return STATUS.FAILURE

func _revoke(context: Dictionary) -> bool:
	if _last_selected_index != -1:
		var ok = await children[_last_selected_index].revoke(context)
		return ok
	GASLogger.error("ControlSelectorAction revoke failed, because no child selected")
	return false
