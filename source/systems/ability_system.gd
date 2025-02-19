extends Node

# region 常量定义
const BASE_PATH := "res://addons/godot_gameplay_ability_system"
# endregion

# region 变量定义

## 技能事件名前缀
@export var ability_event_prefix: StringName = "ability"

var trigger_manager : AbilityTriggerManager:
	get:
		if not trigger_manager:
			trigger_manager = AbilityTriggerManager.new()
			add_child(trigger_manager)
		return trigger_manager
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
signal ability_event(event_name : StringName, payload: Array)

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
		action_handlers: Dictionary = {},
		) -> void:
	if _initialized:
		return
	_logger.info("Initializing AbilitySystem...")
	action_manager.initialized.connect(
		func(success: bool):
			presentation_manager.initialize(presentation_table_type, action_handlers)
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

## 发送技能事件
func push_ability_event(event_name: StringName, payload : Variant = []) -> void:
	_event_bus.push_event(_get_ability_event_name(event_name), payload)
	if not payload is Array:
		payload = [payload]
	ability_event.emit(event_name, payload)

## 订阅技能事件
func subscribe_ability_event(event_name: StringName, callback: Callable) -> void:
	_event_bus.subscribe(_get_ability_event_name(event_name), callback)
	ability_event.connect(callback)

## 取消订阅技能事件
func unsubscribe_ability_event(event_name: StringName, callback: Callable) -> void:
	_event_bus.unsubscribe(_get_ability_event_name(event_name), callback)
	ability_event.disconnect(callback)

func _get_ability_event_name(event_name: StringName) -> StringName:
	return ability_event_prefix + "_" + event_name

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
