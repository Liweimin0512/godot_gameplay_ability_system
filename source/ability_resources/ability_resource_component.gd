extends Node
class_name AbilityResourceComponent

## 技能资源组件

## 当前单位所有的技能消耗资源，同名资源是单例
@export var _ability_resources : Dictionary[StringName, AbilityResource]
## 技能组件
@export var _ability_component : AbilityComponent
## 属性组件
@export var _attribute_component : AbilityAttributeComponent

## 资源当前值变化时发出
signal resource_current_value_changed(res_id: StringName, value: float)
## 资源最大值变化时发出
signal resource_max_value_changed(res_id: StringName, value: float, max_value: float)


func _ready() -> void:
	if not _ability_component:
		_ability_component = get_parent().ability_component
	if not _attribute_component:
		_attribute_component = get_parent().ability_attribute_component


func setup(
		ability_resource_set : Array[AbilityResource],
		p_ability_component : AbilityComponent = null,
		p_ability_attribute_component : AbilityAttributeComponent = null,
		) -> void:
	if p_ability_component != null:
		_ability_component = p_ability_component
	if p_ability_attribute_component != null:
		_attribute_component = p_ability_attribute_component
	if not _ability_component:
		GASLogger.error("can not found ability component")
		return
	for res : AbilityResource in ability_resource_set:
		add_resource(res)


## 添加资源
func add_resource(resource: AbilityResource) -> void:
	if _ability_resources.has(resource.ability_resource_id):
		GASLogger.error("resource already exists: {0}".format([resource.ability_resource_id]))
		return
	resource.initialization(_attribute_component)
	_ability_resources[resource.ability_resource_id] = resource
	if not resource.current_value_changed.is_connected(_on_resource_current_value_changed):
		resource.current_value_changed.connect(_on_resource_current_value_changed.bind(resource))
	if not resource.max_value_changed.is_connected(_on_resource_max_value_changed):
		resource.max_value_changed.connect(_on_resource_max_value_changed.bind(resource))


## 移除资源
func remove_resource(resource_id: StringName) -> void:
	var res : AbilityResource = get_resource(resource_id)
	if not res:
		GASLogger.error("can not found resource by id: {0}".format([resource_id]))
		return
	if res.current_value_changed.is_connected(_on_resource_current_value_changed):
		res.current_value_changed.disconnect(_on_resource_current_value_changed)
	if res.max_value_changed.is_connected(_on_resource_max_value_changed):
		res.max_value_changed.disconnect(_on_resource_max_value_changed)
	_ability_resources.erase(resource_id)


## 检查资源是否足够消耗
func has_enough_resources(res_id: StringName, cost: int) -> bool:
	if res_id.is_empty(): return true
	return get_resource_value(res_id) >= cost


## 获取资源数量
func get_resource_value(res_id: StringName) -> int:
	var res := get_resource(res_id)
	if res:
		return res.current_value
	GASLogger.error("can not found resource by id: {0}".format([res_id]))
	return 0


## 获取资源百分比
## [param res_id] 资源ID
## [return] 百分比
func get_resource_percent(res_id: StringName) -> float:
	var res := get_resource(res_id)
	if res:
		return res.current_value / res.max_value
	GASLogger.error("can not found resource by id: {0}".format([res_id]))
	return 0.0


## 获取资源
func get_resource(res_id: StringName) -> AbilityResource:
	return _ability_resources.get(res_id, null)


## 消耗资源
func consume_resources(res_id: StringName, cost: int) -> bool:
	var res := get_resource(res_id)
	if res:
		return res.consume(cost)
	return false


## 获取所有资源
func get_resources() -> Array[AbilityResource]:
	return _ability_resources.values()


## 资源当前值改变
func _on_resource_current_value_changed(value: float, res: AbilityResource) -> void:
	resource_current_value_changed.emit(res.ability_resource_id, value)


## 资源最大值改变
func _on_resource_max_value_changed(value: float, max_value: float, res: AbilityResource) -> void:
	resource_max_value_changed.emit(res.ability_resource_id, value, max_value)
