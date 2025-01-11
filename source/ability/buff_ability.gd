extends Ability
class_name BuffAbility

## BUFF系统，自管理生命周期的被动技能
## Buff系统允许角色在战斗中获得临时的增益效果，
## 这些效果可以增强角色的属性、提供特殊能力或影响战斗的其他方面。
## Buff可以来自技能、物品、环境等多种来源。

## buff类型
@export_enum("duration", "value") var buff_type: int
## 是否永久
@export var is_permanent: bool = false
## buff值，含义取决于BUFF类型，数值型代表层数，持续型代表持续时间
@export var value: int:
	set(v):
		value = v
		value_changed.emit(value)
## 是否允许堆叠
@export var can_stack : bool = false

signal value_changed(value: int)

func _init() -> void:
	ability_tags.append("buff")
	is_auto_cast = true

## 应用技能
func _apply(context: Dictionary) -> void:
	var ability_component : AbilityComponent = _context.get("ability_component")
	if not ability_component:
		GASLogger.error("can not found ability_component in context! {0}".format([self]))
	var old : BuffAbility = ability_component.get_same_ability(self)
	if old:
		if old.can_stack:
			_merge_buff(old, self)
			GASLogger.info("合并BUFF：{0}".format([self]))
		old.remove()
	else:
		_context["source"] = self
		GASLogger.info("应用BUFF：{0}".format([self]))

## 更新BUFF状态
func _update() -> void:
	GASLogger.debug("更新{0} BUFF状态".format([self]))
	if is_permanent: return
	if buff_type == 1: 
		var ability_component : AbilityComponent = _context.get("ability_component")
		ability_component.remove_ability(self)
	elif buff_type == 0:
		value -= 1
		if value <= 0:
			var ability_component : AbilityComponent = _context.get("ability_component")
			ability_component.remove_ability(self)
	GASLogger.debug("更新buff {0} 的状态，完成！ 当前层数{1}".format([self, value]))

## 合并BUFF
func _merge_buff(old: BuffAbility, new: BuffAbility) -> void:
	new.value += old.value

func _to_string() -> String:
	return "{0}层数{1}".format([ability_name, value])
