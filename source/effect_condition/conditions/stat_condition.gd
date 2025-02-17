@tool
extends EffectCondition
class_name StatCondition

## 检查目标的属性值

enum COMPARE {
    LESS,           # <
    LESS_EQUAL,     # <=
    EQUAL,          # ==
    GREATER_EQUAL,  # >=
    GREATER         # >
}

func _evaluate_leaf(context: Dictionary) -> bool:
    var target = context.get("target")
    if not target or not target.has_method("get_stat"):
        return false
    
    var stat = params.get("stat")
    var value = params.get("value")
    var compare = params.get("compare", COMPARE.EQUAL)
    
    if not stat or not value:
        return false
    
    var current = target.get_stat(stat)
    
    match compare:
        COMPARE.LESS:
            return current < value
        COMPARE.LESS_EQUAL:
            return current <= value
        COMPARE.EQUAL:
            return current == value
        COMPARE.GREATER_EQUAL:
            return current >= value
        COMPARE.GREATER:
            return current > value
    
    return false
