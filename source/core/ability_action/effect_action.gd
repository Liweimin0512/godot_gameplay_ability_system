extends AbilityAction
class_name EffectAction

## 效果节点：执行具体的游戏效果

## 记录是否执行成功
var _is_success: bool = false


func _execute(context: Dictionary) -> STATUS:
	if not _validate_parameters():
		GASLogger.error("ability_action execute failed, because parameters are not valid")
		_is_success = false
		return STATUS.FAILURE
	var result = await _perform_action(context)
	if result == STATUS.SUCCESS:
		_is_success = true
	return result


func _revoke(context: Dictionary) -> bool:
	if _is_success:
		return _revoke_action(context)
	GASLogger.error("ability_action revoke failed, because execute failed")
	return false

## 参数验证
func _validate_parameters() -> bool:
	return true


## 子类实现，执行具体的游戏效果
func _perform_action(_context: Dictionary) -> STATUS:
	return STATUS.SUCCESS


## 子类实现，撤销具体的游戏效果
func _revoke_action(_context: Dictionary) -> bool:
	return true
