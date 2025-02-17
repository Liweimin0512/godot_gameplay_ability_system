extends Node

# region 常量定义
const BASE_PATH := "res://addons/godot_gameplay_ability_system"
# endregion

# region 信号定义
## 初始化完成信号
signal initialized(success: bool)
## 技能施放信号
signal ability_activated(ability: Ability, activator: Node)
## 技能效果应用信号
signal ability_effect_applied(effect: AbilityAction, target: Node)
## 表现层事件信号
signal presentation_event(event_type: PresentationType, context: Dictionary)
## 游戏事件信号
signal game_event(event_type: GameEventType, context: Dictionary)
# endregion

# region 变量定义
var _logger: CoreSystem.Logger:
	get:
		return CoreSystem.logger
var _initialized: bool = false

## 效果节点类型注册表
var _effect_node_types: Dictionary[String, GDScript] = {}
## 效果节点路径映射表
var _effect_path_types: Dictionary[String, String] = {
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
	"play_animation": "res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/play_animation_effect.gd",
	"play_sound": "res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/play_sound_effect.gd",
	"spawn_projectile": "res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/spawn_projectile_effect.gd",
	"spawn_vfx": "res://addons/godot_gameplay_ability_system/source/ability_action/effect_actions/spawn_vfx_effect.gd",
}
## 资源管理器
var _resource_manager : CoreSystem.ResourceManager:
	get:
		return CoreSystem.resource_manager
## 待加载效果脚本数量
var _effect_loading_count : int = 0

# endregion

# region 公共方法
## 初始化
## [param model_types] 模型类型数组
## [param action_table_type] 动作表类型
## [param completed_callable] 初始化完成回调
func initialize(
		model_types: Array[ModelType],
		action_table_type: TableType,
		completed_callable: Callable = Callable()
		) -> void:
	if _initialized:
		return
	_logger.info("Initializing AbilitySystem...")
	_resource_manager.resource_loaded.connect(
		func(resource_path: String, resource: Resource):
			if resource_path in _effect_path_types.values():
				var type_name := _effect_path_types.find_key(resource_path)
				_effect_node_types[type_name] = resource
				_effect_loading_count -= 1
				if _effect_loading_count <= 0:
					# 注册模型类型
					_register_model_types(model_types, action_table_type, completed_callable)
	)
		
	# 注册默认效果节点类型
	_register_default_effect_nodes()

## 注册效果节点类型
func register_effect_node_type(type_name: String, script_path: String) -> void:
	_effect_path_types[type_name] = script_path
	if _effect_node_types.has(type_name):
		_logger.warning("Effect node type already registered: %s" % type_name)
		return
	_resource_manager.load_resource(script_path, _resource_manager.LOAD_MODE.LAZY)
	_effect_node_types[type_name] = null
	_effect_loading_count += 1
	_logger.debug("Registered effect node type: %s" % type_name)

## 从配置数据创建效果节点树
func create_effect_from_config(config: Dictionary) -> AbilityAction:
	if not config.has("type"):
		GASLogger.error("Effect node config must have 'type' field")
		return null
		
	var node_type = config.get("type")
	if not _effect_node_types.has(node_type):
		GASLogger.error("Unknown effect node type: %s" % node_type)
		return null
		
	var node_script = _effect_node_types[node_type]
	var node : AbilityAction = node_script.new()
	
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
			var child = create_effect_from_config(child_config)
			if child and node.has_method("add_child"):
				node.add_child(child)
			else:
				GASLogger.error("add child failed：%s" % [node_type])
	elif config.has("child"):
		var child_config :Dictionary = config.child
		var child = create_effect_from_config(child_config)
		if child and node.has_method("set_child"):
			node.set_child(child)
		else:
			GASLogger.error("set child failed! %s" %[node_type])
	
	return node

## 创建技能实例
func create_ability_instance(ability_id: String) -> Ability:
	var ability_data: Ability = DataManager.get_data_model("ability", ability_id)
	if not ability_data:
		_logger.error("Invalid ability id: %s" % ability_id)
		return null
	
	return ability_data

#endregion

#region 表现层事件系统

## 表现层事件类型
enum PresentationType {
	UNIT_ANIMATION,    # 单位动画
	UNIT_EFFECT,      # 单位特效
	GLOBAL_EFFECT,    # 全局特效
	SOUND_EFFECT,     # 音效
	CAMERA_EFFECT,    # 相机效果
}

## 发送表现层事件
## context中的通用字段：
## - target: Node2D 目标节点（对于单位相关的事件）
## - resource: Resource 资源（动画名称、特效预设等）
## - params: Dictionary 参数（blend_time、custom_speed等）
## - callback: Callable 完成回调（可选）
func emit_presentation_event(event_type: PresentationType, context: Dictionary) -> void:
	presentation_event.emit(event_type, context)

## 创建单位动画事件上下文
static func create_animation_context(
		target: Node2D, 
		animation_name: String, 
		params: Dictionary = {}, 
		callback: Callable = Callable()
	) -> Dictionary:
	return {
		"target": target,
		"resource": animation_name,
		"params": params,
		"callback": callback
	}

## 创建单位特效事件上下文
static func create_unit_effect_context(
		target: Node2D,
		effect_scene: PackedScene,
		params: Dictionary = {},
		callback: Callable = Callable()
	) -> Dictionary:
	return {
		"target": target,
		"resource": effect_scene,
		"params": params,
		"callback": callback
	}

## 创建全局特效事件上下文
static func create_global_effect_context(
		effect_scene: PackedScene,
		position: Vector2,
		params: Dictionary = {},
		callback: Callable = Callable()
	) -> Dictionary:
	params.merge({"position": position})
	return {
		"resource": effect_scene,
		"params": params,
		"callback": callback
	}

#endregion

#region 游戏事件系统

## 游戏事件类型
enum GameEventType {
	ABILITY_START,        # 技能开始
	ABILITY_END,         # 技能结束
	DAMAGE_APPLIED,      # 伤害应用
	EFFECT_APPLIED,      # 效果应用
	HEAL_APPLIED,        # 治疗应用
	STATUS_APPLIED,      # 状态应用
}

## 发送游戏事件
func emit_game_event(event_type: GameEventType, context: Dictionary) -> void:
	game_event.emit(event_type, context)

#endregion

#region 私有方法
## 注册默认效果节点类型
func _register_default_effect_nodes() -> void:
	for type_name in _effect_path_types:
		var script_path: String = _effect_path_types[type_name]
		register_effect_node_type(type_name, script_path)

func _register_ability_action_types(action_table_type: TableType, completed_callable: Callable = Callable()) -> void:
	DataManager.load_data_table(action_table_type, _on_ability_action_types_loaded.bind(completed_callable))

## 注册模型类型
## [param model_types] 模型类型数组
## [param action_table_types] 动作表类型字典
## [param completed_callable] 完成回调
func _register_model_types(
		model_types: Array[ModelType], 
		action_table_type: TableType, 
		completed_callable: Callable = Callable()) -> void:
	DataManager.load_models(
		model_types, 
		func(result: Array[String]) -> void:
			_register_ability_action_types(action_table_type, completed_callable),
		_on_load_progress)
	_logger.debug("Load Model Types......")

func _on_ability_action_types_loaded(type_name: String, completed_callable: Callable = Callable()) -> void:
	_logger.debug("Load Action Table: %s" % type_name)
	
	if completed_callable.is_valid():
		completed_callable.call()
	_initialized = true
	initialized.emit(true)
	_logger.info("AbilitySystem initialized successfully")

## 加载进度回调
## [param progress] 加载进度
func _on_load_progress(progress: int, total: int) -> void:
	_logger.debug("Loading progress: %.2f%%" % (progress/total * 100))
# endregion
