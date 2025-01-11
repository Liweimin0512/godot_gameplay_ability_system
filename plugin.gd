@tool
extends EditorPlugin

const PLUGIN_NAME = "GodotGameplayAbilitySystem"
const PLUGIN_VERSION = "0.1.0"
const GenerateEffectInspectorPlugin = preload("res://addons/godot_gameplay_ability_system/source/editor/generate_effect_inspector_plugin.gd")

var inspector_plugin = GenerateEffectInspectorPlugin.new()

func _enter_tree() -> void:
	# 注册自定义类型
	_register_custom_types()
	add_autoload_singleton("JsonLoader", "source/common/autoload/json_loader.gd")
	add_autoload_singleton("EffectNodeFactory", "source/common/factory/ability_effect_node_factory.gd")
	print("{0} v{1} initialized".format([PLUGIN_NAME, PLUGIN_VERSION]))
	add_inspector_plugin(inspector_plugin)

func _exit_tree() -> void:
	# 移除自定义类型
	_unregister_custom_types()
	remove_autoload_singleton("JsonLoader")
	remove_autoload_singleton("EffectNodeFactory")
	print("{0} v{1} unloaded".format([PLUGIN_NAME, PLUGIN_VERSION]))
	remove_inspector_plugin(inspector_plugin)

func _register_custom_types() -> void:
	# 注册核心组件
	add_custom_type("AbilityComponent", "Node", preload("source/ability_component.gd"), preload("icons/ability_component.svg"))
	add_custom_type("Ability", "Resource", preload("source/core/ability.gd"), preload("icons/ability.svg"))
	add_custom_type("AbilityAttribute", "Resource", preload("source/core/ability_attribute.gd"), preload("icons/attribute.svg"))
	add_custom_type("AbilityResource", "Resource", preload("source/core/ability_resource.gd"), preload("icons/ability_resource.svg"))
	add_custom_type("AbilityResourceComponent", "Node", preload("source/ability_resource_component.gd"), preload("icons/ability_resource_component.svg"))
	add_custom_type("AbilityAttributeComponent", "Node", preload("source/ability_attribute_component.gd"), preload("icons/ability_attribute_component.svg"))

func _unregister_custom_types() -> void:
	# 移除注册的类型
	remove_custom_type("AbilityComponent")
	remove_custom_type("Ability")
	remove_custom_type("AbilityAttribute")
	remove_custom_type("AbilityResource")
	remove_custom_type("AbilityResourceComponent")
	remove_custom_type("AbilityAttributeComponent")
