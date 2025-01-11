extends DecoratorNode
class_name ConditionAbilityNameNode

## 技能名称条件判断

@export var ability_names: PackedStringArray

func _execute(context: Dictionary) -> STATUS:
	var ability_name : String = context.ability.ability_name
	if ability_names.is_empty() : return STATUS.SUCCESS
	if not ability_name.is_empty() and ability_name in ability_names:
		GASLogger.info("技能名称{0}符合条件".format([ability_name]))
		return await child.execute(context)
	GASLogger.info("技能名称{0}不符合条件".format([ability_name]))
	return STATUS.FAILURE