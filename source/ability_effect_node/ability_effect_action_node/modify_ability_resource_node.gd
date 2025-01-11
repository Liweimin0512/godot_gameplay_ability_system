extends AbilityEffectActionNode
class_name ModifyAbilityResourceNode

## 修改技能资源值

## 获取的技能资源名
@export var ability_resource_name: StringName = ""
## 获得的技能资源数量
@export var ability_resource_amount: float = 5
## 资源修改方式
@export_enum("value", "percentage") var modify_type : String = "value"

func _perform_action(context: Dictionary = {}) -> STATUS:
	var caster : Node = context.caster
	var ability_resource_component : AbilityResourceComponent = caster.ability_resource_component
	var ability_resource : AbilityResource = ability_resource_component.get_resource(ability_resource_name)
	if not ability_resource:
		GASLogger.error("ModifyAbilityResourceNode ability_resource is null")
		return STATUS.FAILURE
	var _amount := ability_resource_amount
	if modify_type == "percentage":
		_amount = ability_resource_component.get_resource_value(ability_resource_name) * _amount
	if _amount > 0:
		ability_resource.restore(int(_amount))
	else:
		ability_resource.consume(int(_amount))
	return STATUS.SUCCESS

func _description_getter() -> String:
	var _amount : float = ability_resource_amount
	if modify_type == "value":
		return "获得{0}点{1}".format([
			_amount, ability_resource_name
			])
	else:
		return "获得{0}% {1}".format([_amount * 100, ability_resource_name])
