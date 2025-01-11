extends AbilityResource
class_name RageResource

## 怒气类资源
## 受到伤害时 +5
## 造成伤害时 +10
## 扩展：击杀单位时 +20

## 造成伤害时恢复的值
@export var regain_hited: int = 10
## 受到伤害时恢复的值
@export var regain_hurted: int = 5

func initialization(attribute_component: AbilityAttributeComponent) -> void:
	super(attribute_component)
	current_value = 0

## 造成伤害后恢复怒气
func on_post_hit(_context: Dictionary) -> void:
	GASLogger.info("on_post_hit: %s" % [regain_hited])
	restore(regain_hited)

## 受到伤害后恢复怒气
func on_post_hurt(_context: Dictionary) -> void:
	GASLogger.info("on_post_hurt: %s" % [regain_hurted])
	restore(regain_hurted)

func _get_resource_name() -> StringName:
	return "怒气值"
