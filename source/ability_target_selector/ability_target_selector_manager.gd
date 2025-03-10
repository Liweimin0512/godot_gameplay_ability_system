# ability_target_selector_manager.gd
extends Node
class_name AbilityTargetSelectorManager

var _selectors: Dictionary = {}  # 类型 -> 选择器实例的映射


## 注册目标选择器
func register_selector(type: StringName, selector: AbilityTargetSelector) -> void:
    _selectors[type] = selector


## 获取目标选择器
func get_selector(type: StringName) -> AbilityTargetSelector:
    return _selectors.get(type)


## 选择目标
func select_targets(type: StringName, context: AbilityEffectContext) -> Array:
    var selector = get_selector(type)
    if selector:
        return selector.select_targets(context)
    return [context.target] if context.target else []