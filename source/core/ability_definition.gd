extends RefCounted
class_name AbilityDefinition

## 默认效果节点路径映射表
const DEFAULT_ACTION_NODE_PATHS: Dictionary[String, String] = {
	# 控制节点
	"sequence": "res://addons/godot_gameplay_ability_system/source/ability_action/composites/control_sequence.gd",
	"selector": "res://addons/godot_gameplay_ability_system/source/ability_action/composites/control_selector.gd",
	"parallel": "res://addons/godot_gameplay_ability_system/source/ability_action/composites/control_parallel.gd",
	"random_selector": "res://addons/godot_gameplay_ability_system/source/ability_action/composites/control_random_selector.gd",
	
	# 装饰器节点
	"condition_ability": "res://addons/godot_gameplay_ability_system/source/ability_action/decorators/condition_ability.gd",
	"condition_ability_resource": "res://addons/godot_gameplay_ability_system/source/ability_action/decorators/condition_ability_resource.gd",
	"target_selector": "res://addons/godot_gameplay_ability_system/source/ability_action/decorators/decorator_target_selector.gd",
	"decorator_delay": "res://addons/godot_gameplay_ability_system/source/ability_action/decorators/decorator_delay.gd",
	"decorator_probability": "res://addons/godot_gameplay_ability_system/source/ability_action/decorators/decorator_probability.gd",
	"decorator_repeat": "res://addons/godot_gameplay_ability_system/source/ability_action/decorators/decorator_repeat.gd",

	# 动作节点
	"apply_damage": "res://addons/godot_gameplay_ability_system/source/ability_action/effects/base_damage_effect.gd",
	"apply_ability": "res://addons/godot_gameplay_ability_system/source/ability_action/effects/apply_ability_effect.gd",
	"apply_tag": "res://addons/godot_gameplay_ability_system/source/ability_action/effects/apply_tag_effect.gd",
	"modify_attribute": "res://addons/godot_gameplay_ability_system/source/ability_action/effects/modify_attribute_effect.gd",
	"modify_ability_resource": "res://addons/godot_gameplay_ability_system/source/ability_action/effects/modify_ability_resource_effect.gd",
	"modify_damage": "res://addons/godot_gameplay_ability_system/source/ability_action/effects/modify_damage_effect.gd",
}
