extends AbilityEffectActionNode
class_name PlayAnimationNode

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
	if not unit or not unit.has_method("play_animation"):
		GASLogger.error("PlayAnimationNode unit {0} is null or unit has no play_animation method, animation_name: {1}".format([unit, animation_name]))
		return STATUS.FAILURE

	if wait_for_completion:
		# 等待动画完成
		GASLogger.info("PlayAnimationNode wait_for_completion: %s" % [animation_name])
		await unit.play_animation(animation_name, blend_time, custom_speed)
		GASLogger.info("PlayAnimationNode completed: %s" % [animation_name])
	else:
		unit.play_animation(animation_name, blend_time, custom_speed)
		GASLogger.info("PlayAnimationNode unit.play_animation: %s" % [animation_name])
		
	return STATUS.SUCCESS
