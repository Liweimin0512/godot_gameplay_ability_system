extends ControlAction
class_name ControlSelector

## 选择节点：执行子节点直到一个成功

## 上次选择的节点索引
var _last_selected_index: int = -1


## 执行
## [param context] 上下文
## [return] 节点状态
func _execute(context: AbilityEffectContext) -> STATUS:
	var index: int = 0
	for child in children:
		var status = await child.execute(context)
		if status != STATUS.FAILURE:
			_last_selected_index = index
			return status
		index += 1
	return STATUS.FAILURE


## 撤销
## [param context] 上下文
## [return] 是否撤销成功
func _revoke() -> bool:
	if _last_selected_index == -1:
		GASLogger.error("ControlSelectorAction revoke failed, because no child selected")
		return false
	# 撤销上一次执行的节点的执行
	var ok = children[_last_selected_index].revoke()
	_last_selected_index = -1
	return ok
