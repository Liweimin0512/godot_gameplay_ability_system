@tool
extends AbilityAction

## 获取技能的开关状态
@export var variable: StringName = "is_active"

func _perform_action(context: Dictionary) -> STATUS:
	var ability = context.get("ability")
	if not ability:
		return STATUS.FAILURE
		
	# 获取或初始化开关状态
	var is_active = ability.get_meta("toggle_state", false)
	# 切换状态
	is_active = not is_active
	# 保存状态
	ability.set_meta("toggle_state", is_active)
	# 存入上下文变量
	context[variable] = is_active
	
	return STATUS.SUCCESS
