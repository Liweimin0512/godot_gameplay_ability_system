extends Node
class_name AbilityComponent

## 技能组件，维护广义上的技能（BUFF、SKILL）等
## 当前单位所拥有的全部技能（包括BUFF）
@export var _abilities : Array[Ability]									## 技能列表
@export var _ability_tags : Array[StringName] = []						## 技能标签
@export var _ability_effects : Array[AbilityEffect] = []				## 技能效果（非Ability来源，比如武器带有效果，或自定义BUFF系统等）


func setup(ability_set: Array[Ability]) -> void:
	for ability in ability_set:
		apply_ability(ability, AbilityEffectContext.from_dictionary({"caster": self}))
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
func apply_ability(ability: Ability, ability_context: AbilityEffectContext) -> void:
	ability.caster = get_parent()
	ability.apply(ability_context)
	_abilities.append(ability)


## 移除技能
func remove_ability(ability: Ability) -> void:
	ability.remove()
	_abilities.erase(ability)


## 尝试释放技能
func try_execute_ability(ability: Ability, context: AbilityEffectContext) -> void:
	await ability.execute(context)


## 更新技能
func update_abilities(delta: float) -> void:
	for ability in _abilities:
		ability.update(delta)


#endregion

#region 标签相关

func has_ability_tag(tag: StringName) -> bool:
	return _ability_tags.has(tag)


func has_any_tags(tags: Array[StringName]) -> bool:
	return _has_any_tags(_ability_tags, tags)


func has_all_tags(tags: Array[StringName]) -> bool:
	return _has_all_tags(_ability_tags, tags)


func get_ability_tags() -> Array[StringName]:
	return _ability_tags


func add_ability_tag(tag: StringName) -> void:
	_ability_tags.append(tag)


func remove_ability_tag(tag: StringName) -> void:
	_ability_tags.erase(tag)


func _has_all_tags(source_tags : Array[StringName], query_tags : Array[StringName]) -> bool:
	# 空标签数组表示匹配全部标签
	if query_tags.is_empty():
		return true

	# 检查是否包含全部标签
	return query_tags.all(func(tag: StringName) -> bool: return source_tags.has(tag))


## 检查是否包含任意标签
func _has_any_tags(source_tags : Array[StringName], query_tags : Array[StringName]) -> bool:
	# 空标签数组表示匹配全部标签
	if query_tags.is_empty():
		return true

	# 检查是否包含任意标签
	return query_tags.any(func(tag: StringName) -> bool: return source_tags.has(tag))

#endregion

#region 能力效果相关

## 添加效果
func add_ability_effect(effect: AbilityEffect, context: AbilityEffectContext) -> void:
	effect.apply_effect(context)
	_ability_effects.append(effect)


## 移除效果
func remove_ability_effect(effect: AbilityEffect) -> void:
	effect.remove_effect()
	_ability_effects.erase(effect)


## 更新效果
func update_ability_effects(delta : float) -> void:
	for effect in _ability_effects:
		# [TODO] 更新之后没有移除失效的EFFECT
		effect.update_effect(delta)


func get_effects_by_all_tags(tags: Array[StringName]) -> Array[AbilityEffect]:
	var matched_effects: Array[AbilityEffect] = []
	
	# 1. 检查独立效果
	for effect in _ability_effects:
		if _has_all_tags(effect.effect_tags, tags):
			matched_effects.append(effect)
	
	# 2. 检查技能效果
	for ability in _abilities:
		for effect in ability.ability_effects:
			if _has_all_tags(effect.effect_tags, tags):
				matched_effects.append(effect)
	
	return matched_effects


func get_effects_by_any_tags(tags: Array[StringName]) -> Array[AbilityEffect]:
	var matched_effects: Array[AbilityEffect] = []

	# 检查独立效果
	for effect in _ability_effects:
		if _has_any_tags(effect.effect_tags, tags):
			matched_effects.append(effect)
	
	# 检查技能效果
	for ability in _abilities:
		for effect in ability.ability_effects:
			if _has_any_tags(effect.effect_tags, tags):
				matched_effects.append(effect)
	
	return matched_effects


## 检查是否存在指定标签的效果
func has_effect_with_tags(tags : Array[StringName]) -> bool:
	return not get_effects_by_all_tags(tags).is_empty()


## 移除带有特定标签的效果
func remove_effects_by_tags(tags : Array[StringName]) -> void:
	var effects = get_effects_by_all_tags(tags)
	for effect in effects:
		remove_ability_effect(effect)


#endregion

func _to_string() -> String:
	return get_parent().to_string()


static func get_ability_component(owner: Node) -> AbilityComponent:
	var component : AbilityComponent = owner.get("ability_component")
	if not component:
		component = owner.get_node_or_null("AbilityComponent")
	if not component:
		GASLogger.error("owner {0} missing AbilityComponent".format([owner.to_string()]))
	return component
