extends DecoratorAction
class_name ConditionAbilityResource

## 资源条件判断，是否足够

## 资源目标
@export_enum("caster", "target") var resource_target : String = "caster"
## 资源名称
@export var ability_resource_name: StringName
## 需要资源值
@export var need_resource_value: float

## 执行
func _execute(context: AbilityEffectContext) -> STATUS:
	if not _check_resource_condition(context):
		return STATUS.FAILURE
	return await child.execute(context) if child else STATUS.SUCCESS


## 资源条件判断
func _check_resource_condition(context: AbilityEffectContext) -> bool:
	var source = context.get(resource_target)
	if not source:
		GASLogger.error("{0} is null".format([resource_target]))
		return false
	
	var ability_resource_component : AbilityResourceComponent = source.ability_resource_component
	if not ability_resource_component:
		GASLogger.error("{0} : ability_resource_component is null".format([resource_target]))
		return false

	return ability_resource_component.has_enough_resources(ability_resource_name, need_resource_value)
