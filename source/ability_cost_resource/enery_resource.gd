extends AbilityResource
class_name EneryResource

## 能量，适合敏捷系英雄单位
## 随时间快速恢复

## 每次回复的值
@export var per_regain: int

func _initialization(attribute_component: AbilityAttributeComponent) -> void:
	ability_resource_id = "energy"
	ability_resource_name = "能量值"
