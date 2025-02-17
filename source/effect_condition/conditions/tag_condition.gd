@tool
extends EffectCondition
class_name TagCondition

## 检查目标是否有指定标签

func _evaluate_leaf(context: Dictionary) -> bool:
    var target = context.get("target")
    if not target or not target.has_method("has_tag"):
        return false
    
    var tag = params.get("tag")
    if not tag:
        return false
    
    return target.has_tag(tag)
