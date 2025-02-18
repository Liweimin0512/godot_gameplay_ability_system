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
## 游戏事件信号
signal game_event(event_type: StringName, context: Dictionary)

# endregion

# region 变量定义

var trigger_manager : AbilityTriggerManager:
	get:
		if not trigger_manager:
			trigger_manager = AbilityTriggerManager.new()
			add_child(trigger_manager)
		return trigger_manager
var action_manager : AbilityActionManager:
	get:
		if not action_manager:
			action_manager = AbilityActionManager.new()
			add_child(action_manager)
		return action_manager
var presentation_manager : AbilityPresentationManager:
	get:
		if not presentation_manager:
			presentation_manager = AbilityPresentationManager.new()
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
	action_manager.initialized.connect(
		func(_success: bool):
			pass
	)


## 创建技能实例
func create_ability_instance(ability_id: String) -> Ability:
	var ability_data: Ability = DataManager.get_data_model("ability", ability_id)
	if not ability_data:
		_logger.error("Invalid ability id: %s" % ability_id)
		return null
	
	return ability_data

#endregion

#region 游戏事件系统


## 发送游戏事件
func emit_game_event(event_type: StringName, context: Dictionary) -> void:
	game_event.emit(event_type, context)

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
