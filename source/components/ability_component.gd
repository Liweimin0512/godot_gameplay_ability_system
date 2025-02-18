extends Node
class_name AbilityComponent

## 技能组件，维护广义上的技能（BUFF、SKILL）等
## 当前单位所拥有的全部技能（包括BUFF）

@export var _abilities : Array[Ability]
## 技能标签
@export var _ability_tags : Array[StringName] = []

## 技能释放前发出
signal ability_cast_started(ability: Ability, context: Dictionary)
## 技能释放时发出
signal ability_cast_finished(ability: Ability, context: Dictionary)
## 技能应用触发
signal ability_applied(ability: Ability, context: Dictionary)
## 技能移除触发
signal ability_removed(ability: Ability, context: Dictionary)
## 技能触发成功
signal ability_trigger_success(ability: Ability, context: Dictionary)
## 技能触发失败
signal ability_trigger_failed(ability: Ability, context: Dictionary)

func setup(
			ability_set: Array[Ability],
			ability_context: Dictionary = {}
		) -> void:
	for ability in ability_set:
		apply_ability(ability, ability_context)
		print("ability_component: {0} 初始化".format([owner.to_string()]))

#region 技能相关

## 获取全部技能
func get_abilities(ability_tags: Array[StringName] = []) -> Array[Ability]:
	# 空标签表示获取全部技能
	var abilities : Array[Ability] = []
	# 判断标签是否匹配
	for ability : Ability in _abilities:
		if ability_tags.is_empty() or ability.has_tags(ability_tags):
			abilities.append(ability)
	return abilities

## 获取相同名称的技能
func get_same_ability(ability: Ability) -> Ability:
	for a in _abilities:
		if a.ability_name == ability.ability_name and a.ability_tags == ability.ability_tags:
			return a
	return null

## 应用技能
func apply_ability(ability: Ability, ability_context: Dictionary) -> void:
	ability_context.merge({
		"tree": owner.get_tree(),
		"ability_component": self,
		})
	ability.applied.connect(_on_ability_applied.bind(ability))
	ability.cast_started.connect(_on_ability_cast_started.bind(ability))
	ability.cast_finished.connect(_on_ability_cast_finished.bind(ability))
	ability.removed.connect(_on_ability_removed.bind(ability))
	ability.apply(ability_context)
	_abilities.append(ability)

## 移除技能
func remove_ability(ability: Ability, context: Dictionary) -> void:
	if ability.applied.is_connected(_on_ability_applied):
		ability.applied.disconnect(_on_ability_applied.bind(ability))
	if ability.cast_started.is_connected(_on_ability_cast_started):
		ability.cast_started.disconnect(_on_ability_cast_started.bind(ability))
	if ability.cast_finished.is_connected(_on_ability_cast_finished):
		ability.cast_finished.disconnect(_on_ability_cast_finished.bind(ability))
	if ability.removed.is_connected(_on_ability_removed):
		ability.removed.disconnect(_on_ability_removed.bind(ability))
	ability.remove(context)
	_abilities.erase(ability)

## 尝试释放技能
func try_cast_ability(ability: Ability, context: Dictionary) -> bool:
	var ok = await ability.cast(context)
	return ok

#endregion

#region 标签相关
func has_ability_tag(tag: StringName) -> bool:
	return _ability_tags.has(tag)

func get_ability_tags() -> Array[StringName]:
	return _ability_tags

func add_ability_tag(tag: StringName) -> void:
	_ability_tags.append(tag)

func remove_ability_tag(tag: StringName) -> void:
	_ability_tags.erase(tag)
#endregion

#region 技能相关

func _on_ability_applied(context: Dictionary, ability: Ability) -> void:
	ability_applied.emit(ability, context)

func _on_ability_removed(context: Dictionary, ability: Ability) -> void:
	ability_removed.emit(ability, context)

func _on_ability_cast_started(context: Dictionary, ability: Ability) -> void:
	ability_cast_started.emit(ability, context)

func _on_ability_cast_finished(context: Dictionary, ability: Ability) -> void:
	ability_cast_finished.emit(ability, context)

#endregion

func _to_string() -> String:
	return get_parent().to_string()
