class_name AbilityEffectComponent
extends Node

var _active_effects: Array[AbilityEffect] = []

## 应用效果
func apply_effect(effect: AbilityEffect, context: AbilityEffectContext) -> bool:
    # 检查互斥
    if not _check_exclusive_tags(effect):
        return false
        
    # 根据优先级排序处理互斥效果
    _handle_exclusive_effects(effect)
    
    # 应用新效果
    _active_effects.append(effect)
    await effect.activate(context)
    return true

## 检查互斥标签
func _check_exclusive_tags(new_effect: AbilityEffect) -> bool:
    # 检查新效果的标签是否与现有效果互斥
    for active_effect in _active_effects:
        # 检查双向互斥
        if _are_effects_exclusive(active_effect, new_effect):
            # 如果新效果优先级更高，移除旧效果
            if new_effect.priority > active_effect.priority:
                active_effect.deactivate()
                _active_effects.erase(active_effect)
            else:
                # 否则拒绝新效果
                return false
    return true

## 检查效果是否互斥
func _are_effects_exclusive(effect1: AbilityEffect, effect2: AbilityEffect) -> bool:
    # 检查effect1的标签是否在effect2的互斥标签中
    for tag in effect1.effect_tags:
        if tag in effect2.exclusive_tags:
            return true
    
    # 检查effect2的标签是否在effect1的互斥标签中
    for tag in effect2.effect_tags:
        if tag in effect1.exclusive_tags:
            return true
    
    return false

## 处理互斥效果
func _handle_exclusive_effects(new_effect: AbilityEffect) -> void:
    # 按优先级排序现有效果
    _active_effects.sort_custom(func(a, b): return a.priority > b.priority)
    
    # 移除所有优先级较低的互斥效果
    var i = _active_effects.size() - 1
    while i >= 0:
        var active_effect = _active_effects[i]
        if _are_effects_exclusive(active_effect, new_effect) and active_effect.priority < new_effect.priority:
            active_effect.deactivate()
            _active_effects.remove_at(i)
        i -= 1


## 获取效果
func get_effect(effect_id: StringName) -> AbilityEffect:
    for effect in _active_effects:
        if effect.effect_id == effect_id:
            return effect
    return null


## 获取同类效果
func get_effects_by_tags(tags: Array[StringName]) -> Array[AbilityEffect]:
    var matching_effects: Array[AbilityEffect] = []
    for effect in _active_effects:
        if _has_any_tags(effect.effect_tags, tags):
            matching_effects.append(effect)
    return matching_effects


## 应用效果
func apply_effect(effect: AbilityEffect, context: AbilityEffectContext) -> bool:
    # 检查是否已有相同效果
    var existing_effect = get_effect(effect.effect_id)
    if existing_effect:
        # 如果可以堆叠，尝试堆叠
        if existing_effect.can_stack:
            # 检查等级
            if existing_effect.level > effect.level:
                return false  # 已有更高等级效果
            elif existing_effect.level < effect.level:
                # 移除低等级效果，应用新效果
                existing_effect.deactivate()
                _active_effects.erase(existing_effect)
            else:
                # 同等级，尝试堆叠
                return await existing_effect.try_stack(context)
                
    # 检查互斥
    if not _check_exclusive_tags(effect):
        return false
        
    # 处理互斥效果
    _handle_exclusive_effects(effect)
    
    # 应用新效果
    _active_effects.append(effect)
    await effect.activate(context)
    return true