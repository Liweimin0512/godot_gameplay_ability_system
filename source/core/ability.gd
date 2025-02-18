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
## 动作树
@export var action_tree_id: StringName
## 数据配置
@export var config: Dictionary

## 从数据字典初始化
## [param data] 数据字典
func _init_from_data(_data : Dictionary) -> void:
	pass


## 应用技能
func apply(context: Dictionary) -> void:
	context.ability = self
	context.merge(config, true)
	# 应用动作树
	await AbilitySystem.action_tree_manager.apply_action_tree(action_tree_id, context)


## 移除技能
func remove(context: Dictionary) -> void:
	# 移除动作树
	AbilitySystem.action_tree_manager.remove_action_tree(action_tree_id, context)


## 能否执行
func can_cast(context: Dictionary) -> bool:
	return AbilitySystem.action_tree_manager.can_cast_action_tree(action_tree_id, context)


## 执行技能
func cast(context: Dictionary) -> void:
	await AbilitySystem.action_tree_manager.cast_action_tree(action_tree_id, context)


#region 标签相关

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

#endregion