extends EffectAction
class_name PlayAnimationEffect

## 播放动画节点

## 动画名称
@export var animation_name: String
## 混合时间
@export var blend_time: float = -1
## 自定义速度
@export var custom_speed: float = 1.0
## 是否等待完成
@export var wait_for_completion: bool = false
## 播放动画的单位
@export_enum("caster", "target")
var animation_unit_type: String = "caster"

func _perform_action(context: Dictionary) -> STATUS:
	var unit = context.get(animation_unit_type)
	if not unit:
		GASLogger.error("PlayAnimationNode unit is null")
		return STATUS.FAILURE
	
	var ability_system = AbilitySystem.get_singleton()
	if not ability_system:
		GASLogger.error("AbilitySystem singleton not found")
		return STATUS.FAILURE
	
	if wait_for_completion:
		# 创建完成回调
		var done = false
		var callback = func():
			done = true
		
		# 发送动画事件
		var animation_context = AbilitySystem.create_animation_context(
			unit,
			animation_name,
			{"blend_time": blend_time, "custom_speed": custom_speed},
			callback
		)
		ability_system.emit_presentation_event(AbilitySystem.PresentationType.UNIT_ANIMATION, animation_context)
		
		# 等待动画完成
		while not done:
			await unit.get_tree().process_frame
	else:
		# 直接发送动画事件
		var animation_context = AbilitySystem.create_animation_context(
			unit,
			animation_name,
			{"blend_time": blend_time, "custom_speed": custom_speed}
		)
		ability_system.emit_presentation_event(AbilitySystem.PresentationType.UNIT_ANIMATION, animation_context)
	
	return STATUS.SUCCESS
