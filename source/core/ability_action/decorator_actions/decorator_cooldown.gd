extends DecoratorAction
class_name DecoratorCooldown

## 冷却时间
@export var cooldown: float = 0.0
## 剩余冷却时间
var remaining_cooldown: float = 0.0


func _execute(context: Dictionary) -> STATUS:
    var result = await child.execute(context)
    if result == STATUS.SUCCESS:
        # 执行成功才开始冷却
        remaining_cooldown = cooldown
    return result


func _can_execute(context: Dictionary) -> bool:
    # 先检查自身冷却
    if remaining_cooldown > 0:
        return false
    # 再检查子节点
    return child.can_execute(context) if child else true


## 更新冷却时间
func _update(delta: float) -> void:
    super(delta)
    if remaining_cooldown > 0:
        remaining_cooldown = max(0, remaining_cooldown - delta)
