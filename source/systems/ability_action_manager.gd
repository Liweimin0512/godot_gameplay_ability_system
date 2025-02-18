extends Node
class_name AbilityActionManager

## 效果节点类型注册表
var _action_node_types: Dictionary[String, GDScript] = {}
## 效果节点路径映射表
var _action_path_types: Dictionary[String, String] = {
	# 控制节点
	"sequence": "res://addons/godot_gameplay_ability_system/source/ability_action/control_actions/control_sequence.gd",
	"selector": "res://addons/godot_gameplay_ability_system/source/ability_action/control_actions/control_selector.gd",
	"parallel": "res://addons/godot_gameplay_ability_system/source/ability_action/control_actions/control_parallel.gd",
	"random_selector": "res://addons/godot_gameplay_ability_system/source/ability_action/control_actions/control_random_selector.gd",
	
	# 装饰器节点
	"condition_ability_name": "res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/condition_ability_name.gd",
	"condition_ability_resource": "res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/condition_ability_resource.gd",
	"target_selector": "res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/decorator_target_selector.gd",
	"decorator_delay": "res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/decorator_delay.gd",
	"decorator_probability": "res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/decorator_probability.gd",
	"decorator_trigger": "res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/decorator_trigger.gd",
	"decorator_repeat": "res://addons/godot_gameplay_ability_system/source/ability_action/decorator_actions/decorator_repeat.gd",

	# 动作节点
	"apply_damage": "res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/apply_damage_effect.gd",
	"apply_ability": "res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/apply_ability_effect.gd",
	"apply_tag": "res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/apply_tag_effect.gd",
	"modify_attribute": "res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/modify_attribute_effect.gd",
	"modify_ability_resource": "res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/modify_ability_resource_effect.gd",
	"modify_damage": "res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/modify_damage_effect.gd",
    "projectile": "res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/spawn_projectile_effect.gd",
}
## 待加载效果脚本数量
var _action_loading_count : int = 0

var _resource_manager: CoreSystem.ResourceManager
var _data_manager : DataManager
var _action_table_path : String
var _is_initialized : bool = false

## 效果树缓存
var _action_trees: Dictionary[StringName, AbilityAction] = {}

signal initialized(success: bool)
signal action_created(action: AbilityAction)

## 初始化
func initialize(resource_manager : CoreSystem.ResourceManager , data_manager : DataManager, action_paths: Dictionary, action_table_path : String) -> void:
	if _is_initialized:
		return
	
	_resource_manager = resource_manager
	_data_manager = data_manager
	_action_table_path = action_table_path
	var model_complete_callable : Callable = func(_result: Variant):
		# 配置加载完成初始化完成
		initialized.emit(true)
		_is_initialized = true
	var resource_load_callable : Callable = func(resource_path: String, resource: Resource):
		if resource_path in _action_path_types.values():
			var type_name := _action_path_types.find_key(resource_path)
			_action_node_types[type_name] = resource
			_action_loading_count -= 1
			if _action_loading_count <= 0:
				# 脚本加载完成加载配置
				_data_manager.load_data_table(TableType.new(_action_table_path, [_action_table_path]), model_complete_callable)

	_resource_manager.resource_loaded.connect(resource_load_callable)
	
	_action_path_types.merge(action_paths)
	# 注册效果节点类型
	_register_action_nodes()


## 应用行动树
func apply_action_tree(action_tree_id: StringName, context: Dictionary) -> void:
	var action_tree : AbilityAction = get_action_tree(action_tree_id)
	if not action_tree:
		GASLogger.error("Failed to load action tree: %s" % action_tree_id)
		return
	action_tree.apply(context)
	AbilitySystem.emit_game_event("ability_applied", context)


## 移除行动树缓存
func remove_action_tree(action_tree_id: StringName, context: Dictionary) -> void:
	var action_tree : AbilityAction = get_action_tree(action_tree_id)
	if not action_tree:
		return
	action_tree.revoke(context)
	AbilitySystem.emit_game_event("ability_removed", context)


## 能否执行行动树
func can_execute_action_tree(action_tree_id: StringName, context: Dictionary) -> bool:
	var action_tree : AbilityAction = get_action_tree(action_tree_id)
	if not action_tree:
		return false
	return action_tree.can_execute(context)


## 执行行动树
func execute_action_tree(action_tree_id: StringName, context: Dictionary) -> void:
	var action_tree : AbilityAction = get_action_tree(action_tree_id)
	if not action_tree:
		return
	var ability_executing_callable : Callable = func():
		await action_tree.execute(context)
		AbilitySystem.emit_game_event("ability_executed", context)
	context.merge({"callable": ability_executing_callable})
	AbilitySystem.emit_game_event("ability_executing", context)


## 获取行动树
func get_action_tree(action_tree_id: StringName) -> AbilityAction:
	if _action_trees.has(action_tree_id):
		return _action_trees[action_tree_id]
	var action_tree_config : Dictionary = _data_manager.get_table_item(_action_table_path, action_tree_id)
	if not action_tree_config:
		GASLogger.warning("Action tree not registered: %s" % action_tree_id)
		return null
	var action_tree : AbilityAction = _create_action_from_config(action_tree_config)
	_action_trees[action_tree_id] = action_tree
	return action_tree


## 注册效果节点类型
func _register_action_type(type_name: String, script_path: String) -> void:
	_action_path_types[type_name] = script_path
	if _action_node_types.has(type_name):
		GASLogger.warning("Action node type already registered: %s" % type_name)
		return
	_resource_manager.load_resource(script_path, _resource_manager.LOAD_MODE.LAZY)
	_action_node_types[type_name] = null
	_action_loading_count += 1
	GASLogger.debug("Registered action node type: %s" % type_name)


## 注册行动节点类型
func _register_action_nodes() -> void:
	for type_name in _action_path_types:
		var script_path: String = _action_path_types[type_name]
		_register_action_type(type_name, script_path)


## 创建行动树
func _create_action_from_config(config: Dictionary) -> AbilityAction:
	if not config.has("type"):
		GASLogger.error("Action tree config must have 'type' field")
		return null
	var node_type = config.get("type")
	if not _action_node_types.has(node_type):
		GASLogger.error("Unknown action tree type: %s" % node_type)
		return null
		
	var node_script = _action_node_types[node_type]
	var node : AbilityAction = node_script.new()
	
	# 设置节点属性
	for key in config:
		if key == "children" or key == "child":
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
			var child = _create_action_from_config(child_config)
			if child and node.has_method("add_child"):
				node.add_child(child)
			else:
				GASLogger.error("add child failed：%s" % [node_type])
	elif config.has("child"):
		var child_config :Dictionary = config.child
		var child = _create_action_from_config(child_config)
		if child and node.has_method("set_child"):
			node.set_child(child)
		else:
			GASLogger.error("set child failed! %s" %[node_type])
	
	action_created.emit(node)
	return node
