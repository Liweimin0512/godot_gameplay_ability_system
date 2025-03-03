extends EffectAction
class_name ModifyAbilityResourceEffect

## 修改技能资源值

## 获取的技能资源名
@export var ability_resource_id: StringName = ""
## 获得的技能资源数量
@export var ability_resource_amount: int = 5
## 资源修改方式
@export_enum("value", "percentage") var modify_type : String = "value"
## 是否为临时资源
@export var is_temporary: bool = false
## 临时资源
var _ability_resource : AbilityResource


func _perform_action(context: AbilityContext) -> STATUS:
	var targets : Array[Node] = context.get_all_targets()
	for target in targets:
		var result = _modify_resource(target)
		if result == false:
			return STATUS.FAILURE
	return STATUS.SUCCESS

func _modify_resource(target: Node) -> bool:
	var ability_resource_component : AbilityResourceComponent = target.ability_resource_component
	_ability_resource = ability_resource_component.get_resource(ability_resource_id)
	if not _ability_resource:
		GASLogger.error("ModifyAbilityResourceNode ability_resource is null")
		return false
	var amount = ability_resource_amount
	if modify_type == "percentage":
		amount = ability_resource_component.get_resource_value(ability_resource_id) * amount
	else:
		amount = round(amount)
	if amount > 0:
		_ability_resource.restore(amount)
	else:
		_ability_resource.consume(amount)
	return true


func _description_getter() -> String:
	if modify_type == "value":
		return "获得{0}点{1}".format([ability_resource_amount, _ability_resource.ability_resource_name])
	else:
		return "获得{0}% {1}".format([ability_resource_amount * 100, _ability_resource.ability_resource_name])
