extends Node

# region 常量定义
const BASE_PATH := "res://addons/godot_gameplay_ability_system"
# endregion

# region 变量定义

## 技能事件名前缀
@export var ability_event_prefix: StringName = "ability"

## 能力效果动作管理器
var action_manager : ActionManagerInterface:
	get:
		if not action_manager:
			action_manager = AbilityActionManager.new()
			add_child(action_manager)
		return action_manager
## 能力表现管理器
var presentation_manager : PresentationManager:
	get:
		if not presentation_manager:
			presentation_manager = PresentationManager.new()
			add_child(presentation_manager)
		return presentation_manager
## 目标选择管理器
var target_selector_manager : AbilityTargetSelectorManager:
	get:
		if not target_selector_manager:
			target_selector_manager = AbilityTargetSelectorManager.new()
			add_child(target_selector_manager)
		return target_selector_manager

## 初始化状态
var _initialized: bool = false

## 资源管理器
var _resource_manager : CoreSystem.ResourceManager:
	get:
		return CoreSystem.resource_manager
## 日志管理器
var _logger: CoreSystem.Logger:
	get:
		return CoreSystem.logger
## 事件总线
var _event_bus : CoreSystem.EventBus:
	get:
		return CoreSystem.event_bus

## 技能组件管理字典
var _ability_components : Dictionary[Node, AbilityComponent] = {}
## 属性组件管理字典
var _attribute_components : Dictionary[Node, AbilityAttributeComponent] = {}
## 资源组件管理字典
var _resource_components : Dictionary[Node, AbilityResourceComponent] = {}

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
	var ability: Ability = DataManager.get_data_model("ability", ability_id)
	if not ability:
		_logger.error("Invalid ability id: %s" % ability_id)
		return null
	
	return ability


## 创建技能效果实例
func create_ability_effect_instance(ability_effect_id: String) -> AbilityEffect:
	var ability_effect: AbilityEffect = DataManager.get_data_model("ability_effect", ability_effect_id)
	if not ability_effect:
		_logger.error("Invalid ability effect id: %s" % ability_effect_id)
		return null
	
	return ability_effect


# 事件相关

## 发送技能事件
func push_ability_event(event_name: StringName, context : AbilityEffectContext = null) -> void:
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

func get_ability_component(unit : Node) -> AbilityComponent:
	var ability_component : AbilityComponent = _ability_components.get(unit, null)
	if not ability_component:
		ability_component = unit.get("ability_component")
		if not ability_component:
			ability_component = unit.get_node_or_null("AbilityComponent")
		_ability_components[unit] = ability_component
	return ability_component


func get_ability_attribute_component(unit : Node) -> AbilityAttributeComponent:
	var ability_attribute_component : AbilityAttributeComponent = _attribute_components.get(unit, null)
	if not ability_attribute_component:
		ability_attribute_component = unit.get("ability_attribute_component")
		if not ability_attribute_component:
			ability_attribute_component = unit.get_node_or_null("AbilityAttributeComponent")
		_attribute_components[unit] = ability_attribute_component
	return ability_attribute_component


func get_ability_resource_component(unit: Node) -> AbilityResourceComponent:
	var ability_resource_component : AbilityResourceComponent = _resource_components.get(unit, null)
	if not ability_resource_component:
		ability_resource_component = unit.get("ability_resource_component")
		if not ability_resource_component:
			ability_resource_component = unit.get_node_or_null("AbilityResourceComponent")
		_resource_components[unit] = ability_resource_component
	return ability_resource_component

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
