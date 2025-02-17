@tool
extends EffectCondition
class_name DistanceCondition

## 检查与目标的距离

func _evaluate_leaf(context: Dictionary) -> bool:
    var target = context.get("target")
    var caster = context.get("caster")
    if not target or not caster:
        return false
    
    var max_distance = params.get("max_distance", INF)
    var min_distance = params.get("min_distance", 0)
    
    var distance = target.global_position.distance_to(caster.global_position)
    return distance >= min_distance and distance <= max_distance
