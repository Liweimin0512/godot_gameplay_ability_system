# core/ability_target_selector.gd
extends RefCounted
class_name AbilityTargetSelector

## 技能目标选择器

## 获取可用目标
func get_available_targets(ability: Ability, context: AbilityEffectContext) -> Array:
	return []


## 验证目标
func validate_targets(ability: Ability, targets: Array, context: AbilityEffectContext) -> bool:
	return false


## 获取实际执行时的目标
## 这些是技能实际生效的目标，可能和选择的目标不同
## 比如：选择一个目标但实际影响多个目标的技能
func get_actual_targets(ability: Ability, context: AbilityEffectContext) -> Array:
	return context.get_all_targets()


## 应用目标过滤器
func apply_filters(targets: Array, filters: Array, context: AbilityEffectContext) -> Array:
	var filtered = targets
	for filter in filters:
		filtered = _apply_filter(filtered, filter, context)
	return filtered


## 应用单个过滤器
func _apply_filter(targets: Array, filter: Dictionary, context: AbilityEffectContext) -> Array:
	var filter_type : String = filter.get("type", "")
	if filter.is_empty() or filter_type == "":
		return targets
	elif filter_type == "alive":
		return targets.filter(func(t): return t.is_alive)
	elif filter_type == "dead":
		return targets.filter(func(t): return not t.is_alive)
	elif filter_type == "team":
		return targets.filter(func(t): return t.team == filter.team)
	elif filter_type == "distance":
		return targets.filter(func(t): 
			return t.global_position.distance_to(context.caster.global_position) <= filter.max_distance
		)
	return targets
