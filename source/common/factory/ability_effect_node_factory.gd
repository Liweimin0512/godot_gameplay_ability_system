extends Node

## 效果节点工厂，负责根据配置创建效果节点树

## 节点类型映射表
var _node_type_map: Dictionary = {
	# 控制节点
	"sequence": preload("res://addons/godot_gameplay_ability_system/source/ability_action/control_actions/control_sequence.gd"),
	"selector": preload("res://addons/godot_gameplay_ability_system/source/ability_action/control_actions/control_selector.gd"),
	"parallel": preload("res://addons/godot_gameplay_ability_system/source/ability_action/control_actions/control_parallel.gd"),
	"random_selector": preload("res://addons/godot_gameplay_ability_system/source/ability_action/control_actions/control_random_selector.gd"),
	
	# 装饰器节点
	"condition_ability_name": preload("res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/condition_ability_name.gd"),
	"condition_ability_resource": preload("res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/condition_ability_resource.gd"),
	"target_selector": preload("res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/decorator_target_selector.gd"),
	"decorator_delay": preload("res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/decorator_delay.gd"),
	"decorator_probability": preload("res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/decorator_probability.gd"),
	"decorator_trigger": preload("res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/decorator_trigger.gd"),
	"decorator_repeat": preload("res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/decorator_repeat.gd"),

	# 动作节点
	"apply_damage": preload("res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/apply_damage_effect.gd"),
	"apply_ability": preload("res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/apply_ability_effect.gd"),
	"apply_tag": preload("res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/apply_tag_effect.gd"),
	"modify_attribute": preload("res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/modify_attribute_effect.gd"),
	"modify_ability_resource": preload("res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/modify_ability_resource_effect.gd"),
	"modify_damage": preload("res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/modify_damage_effect.gd"),
	"play_animation": preload("res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/play_animation_effect.gd"),
	"play_sound": preload("res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/play_sound_effect.gd"),
	"spawn_projectile": preload("res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/spawn_projectile_effect.gd"),
	"spawn_vfx": preload("res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/spawn_vfx_effect.gd"),
}

## 缓存已加载的JSON配置
var _ability_effect_node_cache: Dictionary = {}

## 注册新的节点类型
func register_node_type(type_name: String, script_path: String) -> void:
	if _node_type_map.has(type_name):
		GASLogger.warning("Node type '%s' already registered, will be overwritten" % type_name)
	
	var script = load(script_path)
	if not script:
		GASLogger.error("Failed to load script: %s" % script_path)
		return
		
	_node_type_map[type_name] = script

## 注销节点类型
func unregister_node_type(type_name: String) -> void:
	if _node_type_map.has(type_name):
		_node_type_map.erase(type_name)

## 获取所有已注册的节点类型
func get_registered_types() -> Array[String]:
	return _node_type_map.keys()

## 检查节点类型是否已注册
func is_type_registered(type_name: String) -> bool:
	return _node_type_map.has(type_name)

## 从JSON文件创建效果节点树
func create_from_json(json_path: String) -> AbilityEffectNode:
	# 先检查缓存
	if _ability_effect_node_cache.has(json_path):
		return _ability_effect_node_cache[json_path]
	var config : Dictionary = JsonLoader.get_cached_json(json_path)
	var node := create_from_config(config)
	if node:
		_ability_effect_node_cache[json_path] = node
	return node

## 从JSON配置创建效果节点树
func create_from_config(config: Dictionary) -> AbilityEffectNode:
	if not config.has("type"):
		GASLogger.error("Effect node config must have 'type' field")
		return null
		
	var node_type = config.get("type")
	if not _node_type_map.has(node_type):
		GASLogger.error("Unknown effect node type: %s" % node_type)
		return null
		
	var node_script = _node_type_map[node_type]
	var node : AbilityEffectNode = node_script.new()
	
	# 设置节点属性
	for key in config:
		if key == "type" or key == "children" or key == "child":
			continue
		var has_property = false
		for p in node.get_property_list():
			if p.name == key:
				has_property = true
				break
		if has_property:  # 只设置节点已有的属性
			var value = config[key]
			# if key == "ability":
			# 	value = value as Ability
			node.set(key, value)
		else:
			GASLogger.error("set property failed! key: %s, node_type: %s" % [key, node_type])

	# 递归创建子节点
	if config.has("children") and config.children is Array:
		for child_config in config.children:
			var child = create_from_config(child_config)
			if child and node.has_method("add_child"):
				node.add_child(child)
			else:
				GASLogger.error("add child failed：%s" % [node_type])
	elif config.has("child"):
		var child_config :Dictionary = config.child
		var child = create_from_config(child_config)
		if child and node.has_method("set_child"):
			node.set_child(child)
		else:
			GASLogger.error("set child failed! %s" %[node_type])
	
	return node
