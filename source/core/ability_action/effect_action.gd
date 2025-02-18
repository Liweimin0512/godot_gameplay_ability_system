extends AbilityAction
class_name EffectAction

## 效果节点：执行具体的游戏效果

## 前摇延时
@export var pre_delay: float = 0.0
## 后摇延时
@export var post_delay: float = 0.0
## 记录是否执行成功
var _is_success: bool = false

func _execute(context: Dictionary) -> STATUS:
	if not _validate_parameters():
		_is_success = false
		return STATUS.FAILURE
	var scene_tree : SceneTree = _get_context_value(context, "tree")
	if not scene_tree:
		GASLogger.error("ability_action {0} execute failed, because scene tree is null".format([self]))
		return STATUS.FAILURE
	if pre_delay > 0.0:
		GASLogger.debug("ability_action pre_delay: %s" % [pre_delay])
		await scene_tree.create_timer(pre_delay).timeout
	var result = await _perform_action(context)
	if result == STATUS.SUCCESS:
		_is_success = true
	if post_delay > 0.0:
		GASLogger.debug("ability_action post_delay: %s" % [post_delay])
		await scene_tree.create_timer(post_delay).timeout
	return result

func _revoke(context: Dictionary) -> bool:
	if _is_success:
		return _revoke_action(context)
	GASLogger.error("ability_action revoke failed, because execute failed")
	return false

func _validate_parameters() -> bool:
	return true

## 子类实现，执行具体的游戏效果
func _perform_action(_context: Dictionary) -> STATUS:
	return STATUS.SUCCESS

## 子类实现，撤销具体的游戏效果
func _revoke_action(_context: Dictionary) -> bool:
	return true
