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
@export var effect_container: AbilityEffectNode
## 效果配置文件路径
@export_file("*.json") var effect_config_path: String

## 技能上下文
var _context : Dictionary

signal applied(context: Dictionary)
signal removed(context: Dictionary)
signal cast_started(context: Dictionary)
signal cast_finished(context: Dictionary)

## 应用技能
func apply(ability_component: AbilityComponent, context: Dictionary) -> void:
	_context = context.duplicate(true)
	_context.ability = self
	if not effect_config_path.is_empty():
		_load_effect_config()
	_apply(_context)
	applied.emit(_context)
	if is_auto_cast:
		cast(_context)

## 移除技能
func remove() -> void:
	await effect_container.revoke()
	_remove()
	removed.emit(_context)

## 执行技能
func cast(context: Dictionary) -> bool:
	cast_started.emit(context)
	_context.merge(context, true)
	if not _can_cast(_context):
		return false
	var ok = await _cast(_context)
	cast_finished.emit(_context)
	return ok

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

func _remove() -> void:
	pass

## 判断能否施放, 子类实现
func _can_cast(_context: Dictionary) -> bool:
	return true

func _cast(context: Dictionary) -> bool:
	if not effect_container: return false
	var result = await effect_container.execute(_context)
	if result == AbilityEffectNode.STATUS.SUCCESS:
		GASLogger.info("技能{0}执行成功".format([self]))
		cast_finished.emit(context)
		return true
	else:
		GASLogger.error("技能{0}执行失败".format([self]))
		# 撤销执行
		effect_container.revoke()
		return false

## 从配置加载效果节点树
func _load_effect_config() -> void:
	if effect_config_path.is_empty():
		return
	var effect_tree = EffectNodeFactory.create_from_json(effect_config_path)
	if effect_tree:
		effect_container = effect_tree
	else:
		GASLogger.error("Failed to load effect config from: %s" % effect_config_path)

func _to_string() -> String:
	return ability_name
