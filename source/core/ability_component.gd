extends Node
class_name AbilityComponent

## 技能组件，维护广义上的技能（BUFF、SKILL）等
## 当前单位所拥有的全部技能（包括BUFF）

@export var _abilities : Array[Ability]									## 技能列表
@export var _ability_tags : Array[StringName] = []						## 技能标签
@export var _ability_effects : Array[AbilityEffect] = []				## 技能效果

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

func setup(ability_set: Array[Ability]) -> void:
	for ability in ability_set:
		apply_ability(ability, AbilityContext.from_dictionary({"caster": self}))
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
func apply_ability(ability: Ability, ability_context: AbilityContext) -> void:
	ability.caster = get_parent()
	ability.apply(ability_context)
	_abilities.append(ability)


## 移除技能
func remove_ability(ability: Ability) -> void:
	ability.remove()
	_abilities.erase(ability)


## 尝试释放技能
func try_execute_ability(ability: Ability, context: AbilityContext) -> void:
	await ability.execute(context)

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

#region 能力效果相关

## 添加效果
func add_ability_effect(effect: AbilityEffect) -> void:
	_ability_effects.append(effect)

## 移除效果
func remove_ability_effect(effect: AbilityEffect) -> void:
	_ability_effects.erase(effect)

## 更新效果
func update_ability_effects(delta : float) -> void:
	for effect in _ability_effects:
		effect.update_effect(delta)

#endregion

func _to_string() -> String:
	return get_parent().to_string()

static func get_ability_component(owner: Node) -> AbilityComponent:
	var component : AbilityComponent = owner.get("ability_component")
	if not component:
		component = owner.get_node_or_null("AbilityComponent")
	if not component:
		_logger.error("owner {0} missing AbilityComponent".format([owner.to_string()]))
	return component
