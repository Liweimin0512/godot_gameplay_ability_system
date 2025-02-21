extends Node

# region 常量定义
const BASE_PATH := "res://addons/godot_gameplay_ability_system"
# endregion

# region 变量定义

## 技能事件名前缀
@export var ability_event_prefix: StringName = "ability"
# 注册的限制器类型
var _restriction_types : Dictionary = {
	&"cooldown": CooldownRestriction,
	&"usage_count": UsageCountRestriction,
	&"resource_cost": ResourceCostRestriction,
}

var trigger_manager : CoreSystem.TriggerManager:
	get:
		return CoreSystem.trigger_manager
	set(_value):
		push_error("trigger_manager is read-only")
var action_manager : ActionManagerInterface:
	get:
		if not action_manager:
			action_manager = AbilityActionManager.new()
			add_child(action_manager)
		return action_manager
var presentation_manager : PresentationManager:
	get:
		if not presentation_manager:
			presentation_manager = PresentationManager.new()
			add_child(presentation_manager)
		return presentation_manager

var _initialized: bool = false

## 资源管理器
var _resource_manager : CoreSystem.ResourceManager:
	get:
		return CoreSystem.resource_manager
var _logger: CoreSystem.Logger:
	get:
		return CoreSystem.logger
		
var _event_bus : CoreSystem.EventBus:
	get:
		return CoreSystem.event_bus

# endregion

## 初始化完成信号
signal initialized(success: bool)
signal ability_event(event_name : StringName, context : Dictionary)

# region 公共方法

## 初始化
## [param model_types] 模型类型数组
## [param action_table_type] 动作表类型
## [param completed_callable] 初始化完成回调
func initialize(
		model_types: Array[ModelType],
		action_table_type: TableType,
		presentation_table_type: TableType,
		action_paths: Dictionary = {},
		) -> void:
	if _initialized:
		return
	_logger.info("Initializing AbilitySystem...")
	action_manager.initialized.connect(
		func(success: bool):
			presentation_manager.initialize(presentation_table_type)
	)
	var _on_model_loaded = func(_result: Array[String], success: bool):
		initialized.emit(success)
		_initialized = success
	presentation_manager.initialized.connect(func(success: bool): DataManager.load_models(model_types, _on_model_loaded.bind(success)))
	action_manager.initialize(_resource_manager, DataManager, action_paths, action_table_type)

## 创建技能实例
func create_ability_instance(ability_id: String) -> Ability:
	var ability_data: Ability = DataManager.get_data_model("ability", ability_id)
	if not ability_data:
		_logger.error("Invalid ability id: %s" % ability_id)
		return null
	
	return ability_data


# 事件相关

## 处理游戏事件
func handle_game_event(event_name: StringName, context : Dictionary = {}) -> void:
	trigger_manager.handle_event(_get_ability_event_name(event_name), context)

## 添加触发器
func register_trigger(trigger_type: StringName, trigger: Trigger) -> void:
	trigger_manager.register_trigger(trigger_type, trigger)

## 移除触发器
func unregister_trigger(trigger_type: StringName, trigger: Trigger) -> void:
	trigger_manager.unregister_trigger(trigger_type, trigger)

## 发送技能事件
func push_ability_event(event_name: StringName, context : Dictionary = {}) -> void:
	_event_bus.push_event(_get_ability_event_name(event_name), context)
	ability_event.emit(event_name, context)

## 订阅技能事件
func subscribe_ability_event(event_name: StringName, callback: Callable) -> void:
	_event_bus.subscribe(_get_ability_event_name(event_name), callback)

## 取消订阅技能事件
func unsubscribe_ability_event(event_name: StringName, callback: Callable) -> void:
	_event_bus.unsubscribe(_get_ability_event_name(event_name), callback)

func _get_ability_event_name(event_name: StringName) -> StringName:
	return ability_event_prefix + "_" + event_name


# 限制器相关

## 注册限制器类型
func register_restriction_type(type: StringName, restriction_class: GDScript) -> void:
	_restriction_types[type] = restriction_class
	
## 注销限制器类型
func unregister_restriction_type(type: StringName) -> void:
	_restriction_types.erase(type)

## 创建限制器实例
func create_restriction(config: Dictionary) -> AbilityRestriction:
	var type = config.get("type", "")
	if not _restriction_types.has(type):
		GASLogger.error("Unknown restriction type: %s" % type)
		return null
		
	var restriction_class = _restriction_types[type]
	return restriction_class.new(config)

#endregion

#region 私有方法

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
