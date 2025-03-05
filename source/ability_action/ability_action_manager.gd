extends ActionManagerInterface
class_name AbilityActionManager

## 效果节点类型注册表
var _action_node_types: Dictionary[String, GDScript] = {}
## 效果节点路径映射表
var _action_path_types: Dictionary[String, String]
## 待加载效果脚本数量
var _action_loading_count : int = 0

var _resource_manager: CoreSystem.ResourceManager
var _data_manager : DataManager
var _action_table_type : TableType

## 效果树缓存
var _action_trees: Dictionary[StringName, AbilityAction] = {}


## 初始化
func initialize(resource_manager : CoreSystem.ResourceManager , data_manager : DataManager, 
		action_paths: Dictionary, action_table_type : TableType) -> void:
	if _initialized:
		return
	
	_resource_manager = resource_manager
	_data_manager = data_manager
	_action_table_type = action_table_type
	var model_complete_callable : Callable = func(_result: Variant):
		# 配置加载完成初始化完成
		initialized.emit(true)
		_initialized = true
	var resource_load_callable : Callable = func(resource_path: String, resource: Resource):
		if resource_path in _action_path_types.values():
			var type_name := _action_path_types.find_key(resource_path)
			_action_node_types[type_name] = resource
			_action_loading_count -= 1
			if _action_loading_count <= 0:
				# 脚本加载完成加载配置
				_data_manager.load_data_table(_action_table_type, model_complete_callable)

	_resource_manager.resource_loaded.connect(resource_load_callable)
	
	_action_path_types = AbilityDefinition.DEFAULT_ACTION_NODE_PATHS.duplicate()
	_action_path_types.merge(action_paths)
	# 注册效果节点类型
	_register_action_nodes()


## 应用行动树
func apply_action_tree(action_id: StringName) -> void:
	var action_tree : AbilityAction = _action_trees.get(action_id, null)
	if action_tree == null:
		action_tree = _create_action_tree(action_id)
		if not action_tree:
			GASLogger.error("Failed to create action tree: %s" % action_id)
			return
		_action_trees[action_id] = action_tree


## 执行行动树
func execute_action_tree(action_id: StringName, context: AbilityEffectContext) -> void:
	var action_tree : AbilityAction = _get_action_tree(action_id)
	if not action_tree:
		return
	await action_tree.execute(context)


## 移除行动树缓存
func remove_action_tree(action_id: StringName) -> void:
	var action_tree : AbilityAction = _get_action_tree(action_id)
	if not action_tree:
		return
	action_tree.revoke()


## 获取行动树描述
func get_tree_description(action_id: StringName, context: AbilityEffectContext) -> String:
	var action_tree : AbilityAction = _get_action_tree(action_id)
	if not action_tree:
		return ""
	return action_tree.get_tree_description(context)


## 获取行动树
func _create_action_tree(action_tree_id : StringName) -> AbilityAction:
	if _action_trees.has(action_tree_id):
		return _action_trees[action_tree_id]
	
	var action_tree_config : Dictionary = _data_manager.get_table_item(_action_table_type.table_name, action_tree_id)
	if not action_tree_config:
		GASLogger.warning("Action tree not registered: %s" % action_tree_id)
		return null
	var action_tree : AbilityAction = _create_action_from_config(action_tree_config)
	_action_trees[action_tree_id] = action_tree
	return action_tree


## 获取行动树
func _get_action_tree(action_id: StringName) -> AbilityAction:
	var action_tree : AbilityAction = _action_trees.get(action_id, null)
	if not action_tree:
		GASLogger.error("Failed to get action tree: %s" % action_id)
		return null
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
		if key == "type":
			continue
		var has_property = false
		for p in node.get_property_list():
			if p.name == key:
				has_property = true
				break
		if has_property:  # 只设置节点已有的属性
			var value = config[key]
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
				GASLogger.error("add child failed:%s" % [node_type])
	elif config.has("child"):
		var child_config :Dictionary = config.child
		var child = _create_action_from_config(child_config)
		if child and node.has_method("set_child"):
			node.set_child(child)
		else:
			GASLogger.error("set child failed! %s" %[node_type])

	node.set_meta("config", config)
	return node
