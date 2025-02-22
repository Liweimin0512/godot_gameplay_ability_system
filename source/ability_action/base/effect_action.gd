extends AbilityAction
class_name EffectAction

## 效果节点：执行具体的游戏效果

func _execute(context: Dictionary) -> STATUS:
	if not _validate_parameters():
		GASLogger.error("ability_action execute failed, because parameters are not valid")
		return STATUS.FAILURE
	var result = await _perform_action(context)
	return result


## 参数验证
func _validate_parameters() -> bool:
	return true


## 子类实现，执行具体的游戏效果
func _perform_action(_context: Dictionary) -> STATUS:
	return STATUS.SUCCESS