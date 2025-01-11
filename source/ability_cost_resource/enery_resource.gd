extends AbilityResource
class_name EneryResource

## 能量，适合敏捷系英雄单位
## 随时间快速恢复

## 每次回复的值
@export var per_regain: int

func _get_resource_name() -> StringName:
	return "能量值"
