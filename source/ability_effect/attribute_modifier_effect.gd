extends AbilityEffect
class_name AttributeModifierEffect

## 修改属性的效果

@export var attribute_modifiers : Array[AbilityAttributeModifier]
var applied_attribute_modifiers : Array[AbilityAttributeModifier] = [] # 记录已经应用的属性修改器

func _activate(context: AbilityEffectContext) -> void:
	## 应用属性修改
    pass


func _deactivate(context: AbilityEffectContext) -> void:
    ## 移除属性修改
    pass


## 应用属性修改器
func _apply_attribute_modifiers(target) -> void:
	## 应用属性修改
	var attribute_component : AbilityAttributeComponent = AbilityAttributeComponent.get_attribute_component(target)
	if not attribute_component:
		GASLogger.error("target " + str(target) + " missing AbilityAttributeComponent")
		return
	for modifier in attribute_modifiers:
		# 根据堆叠调整修改器的值
		var stacked_modifier = modifier.duplicate()
		stacked_modifier.value *= current_stacks
		attribute_component.apply_attribute_modifier(stacked_modifier)
		applied_attribute_modifiers.append(stacked_modifier)


## 移除属性修改器
func _remove_attribute_modifiers(target) -> void:
	var attribute_component : AbilityAttributeComponent = AbilityAttributeComponent.get_attribute_component(target)
	if not attribute_component:
		GASLogger.error("target " + str(target) + " missing AbilityAttributeComponent")
		return
	for modifier in applied_attribute_modifiers:
		attribute_component.remove_attribute_modifier(modifier)


## 更新修改器
## [TODO] 这里可以处理需要随时间变化的修改器
func _update_attribute_modifiers() -> void:
	pass
