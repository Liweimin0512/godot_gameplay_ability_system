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
## 修改的资源数量
var _amount : int

func _perform_action(context: Dictionary = {}) -> STATUS:
	var target : Node = _get_context_value(context, "target")
	var ability_resource_component : AbilityResourceComponent = target.ability_resource_component
	_ability_resource = ability_resource_component.get_resource(ability_resource_id)
	if not _ability_resource:
		GASLogger.error("ModifyAbilityResourceNode ability_resource is null")
		return STATUS.FAILURE
	_amount = ability_resource_amount
	if modify_type == "percentage":
		_amount = ability_resource_component.get_resource_value(ability_resource_id) * _amount
	else:
		_amount = round(_amount)
	if _amount > 0:
		_ability_resource.restore(_amount)
	else:
		_ability_resource.consume(_amount)
	return STATUS.SUCCESS


func _revoke() -> bool:
	if is_temporary:
		if _amount > 0:
			_ability_resource.consume(_amount)
		else:
			_ability_resource.restore(_amount)
	return true

func _description_getter() -> String:
	if modify_type == "value":
		return "获得{0}点{1}".format([_amount, _ability_resource.ability_resource_name])
	else:
		return "获得{0}% {1}".format([_amount * 100, _ability_resource.ability_resource_name])
