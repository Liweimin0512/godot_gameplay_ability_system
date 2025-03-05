extends DecoratorAction
class_name DecoratorProbability

## 概率装饰器：按概率决定是否执行子节点

## 概率
@export_range(0.0, 1.0) var probability: float = 0.5

func _execute(context: AbilityEffectContext) -> STATUS:
	if randf() > probability:
		return STATUS.FAILURE
	return await child.execute(context) if child else STATUS.SUCCESS
