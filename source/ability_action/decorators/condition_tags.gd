extends DecoratorAction
class_name ConditionTags

## 标签判断

@export_enum("caster", "target") var tag_owner : String = "caster"
@export_enum("any", "all") var match_type : String = "any"
@export var tags : Array[StringName]

## 执行
func _execute(context: AbilityEffectContext) -> STATUS:
	var source : Node= context.get(tag_owner)
	if not source:
		GASLogger.error("{0} is null".format([tag_owner]))
		return STATUS.FAILURE
	
	var ability_component : AbilityComponent = AbilitySystem.get_ability_component(source)
	if not ability_component:
		GASLogger.error("ConditionAbility context does not contain ability_component")
		return STATUS.FAILURE

	match match_type:
		"any":
			if ability_component.has_any_tags(tags):
				return await child.execute(context) if child else STATUS.SUCCESS
			return STATUS.FAILURE
		"all":
			if ability_component.has_all_tags(tags):
				return await child.execute(context) if child else STATUS.SUCCESS
			return STATUS.FAILURE

	return STATUS.FAILURE
