extends DecoratorAction
class_name DecoratorRepeat

## 重复装饰器：重复执行子节点

## 重复次数
@export var repeat_count: int = 1
## 重复间隔
@export var repeat_interval: float = 0.0

func _execute(context: AbilityEffectContext) -> STATUS:
	for i in repeat_count:
		context.repeat_index = i + 1
		# 执行子节点
		var status = await child.execute(context)
		if status == STATUS.FAILURE:
			return STATUS.FAILURE
		# 如果需要间隔，则等待间隔时间
		if repeat_interval > 0 and i < repeat_count - 1:
			await AbilitySystem.get_tree().create_timer(repeat_interval).timeout
	return STATUS.SUCCESS
