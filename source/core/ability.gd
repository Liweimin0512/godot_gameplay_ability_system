extends Resource
class_name Ability

## 技能基类，提供基础的技能系统功能

## 技能名称
@export var ability_name: StringName
## 技能类型
@export var ability_tags: Array[StringName] = []
## 技能描述
@export var ability_description: String
## 技能图标
@export var icon: Texture2D
## 技能是否在满足条件时自动施放
@export var is_auto_cast: bool
## 效果容器
@export var effect_container: AbilityAction

signal applied(context: Dictionary)
signal removed(context: Dictionary)
signal cast_started(context: Dictionary)
signal cast_finished(context: Dictionary)

## 从数据字典初始化
## [param data] 数据字典
func _init_from_data(data : Dictionary) -> void:
	var effectID : StringName = data.get("effect_id", "")
	if effectID.is_empty():
		GASLogger.info("Effect ID is empty, ability: %s" % ability_name)
		return
	var effect_config : Dictionary = DataManager.get_table_item("ability_action", effectID)
	if effect_config.is_empty():
		GASLogger.info("Effect config is empty, ability: %s" % ability_name)
		return
	effect_container = AbilitySystem.create_effect_from_config(effect_config)
	if not effect_container:
		GASLogger.error("Failed to load effect config from: %s" % effectID)

## 应用技能
func apply(context: Dictionary) -> void:
	context.ability = self
	_apply(context)
	if is_auto_cast:
		await cast(context)
	applied.emit(context)

## 移除技能
func remove(context: Dictionary) -> void:
	await effect_container.revoke(context)
	_remove(context)
	removed.emit(context)

## 执行技能
func cast(context: Dictionary) -> bool:
	cast_started.emit(context)
	if not _can_cast(context):
		return false
	if not effect_container: 
		GASLogger.error("Effect container is null, ability: %s" % ability_name)
		return false
	await _cast(context)
	var result = await effect_container.execute(context)
	cast_finished.emit(context)
	return result

## 添加标签
func add_tag(tag: StringName) -> void:
	ability_tags.append(tag)

## 移除标签
func remove_tag(tag: StringName) -> void:
	ability_tags.erase(tag)

## 是否包含标签
func has_tag(tag: StringName) -> bool:
	return ability_tags.has(tag)

## 是否包含标签
func has_tags(tags: Array[StringName]) -> bool:
	return tags.all(func(tag: StringName) -> bool: return ability_tags.has(tag))

func _apply(context: Dictionary) -> void:
	pass

func _remove(context: Dictionary) -> void:
	pass

## 判断能否施放, 子类实现
func _can_cast(context: Dictionary) -> bool:
	return true

func _cast(context: Dictionary) -> void:
	pass

func _to_string() -> String:
	return ability_name
