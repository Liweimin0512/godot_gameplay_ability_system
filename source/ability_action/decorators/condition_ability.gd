extends DecoratorAction
class_name ConditionAbility

## 技能ID条件判断

@export var ability_ids: PackedStringArray


## 执行
func _execute(context: AbilityEffectContext) -> STATUS:
	if ability_ids.is_empty():
		# 未设置技能ID，直接成功
		return await child.execute(context) if child else STATUS.SUCCESS

	var ability : Ability = context.ability
	if not ability:
		GASLogger.error("ConditionAbility context does not contain ability")
		return STATUS.FAILURE

	if ability.ability_id.is_empty():
		# 未设置技能ID，直接成功
		return await child.execute(context) if child else STATUS.SUCCESS

	if ability.ability_id in ability_ids:
		return await child.execute(context) if child else STATUS.SUCCESS

	GASLogger.info("技能名称{0}不符合条件".format([ability.ability_id]))
	return STATUS.FAILURE
