@tool
extends Resource
class_name EffectCondition

## 条件类型
enum TYPE {
    AND,    # 所有子条件都满足
    OR,     # 任一子条件满足
    NOT,    # 子条件不满足
    LEAF    # 叶子条件
}

## 条件类型
@export var condition_type: TYPE = TYPE.LEAF
## 子条件
@export var sub_conditions: Array[EffectCondition]
## 条件参数
@export var params: Dictionary

## 评估条件
func evaluate(context: Dictionary) -> bool:
    match condition_type:
        TYPE.AND:
            return _evaluate_and(context)
        TYPE.OR:
            return _evaluate_or(context)
        TYPE.NOT:
            return _evaluate_not(context)
        TYPE.LEAF:
            return _evaluate_leaf(context)
    return false

## 评估AND条件
func _evaluate_and(context: Dictionary) -> bool:
    for condition in sub_conditions:
        if not condition.evaluate(context):
            return false
    return true

## 评估OR条件
func _evaluate_or(context: Dictionary) -> bool:
    for condition in sub_conditions:
        if condition.evaluate(context):
            return true
    return false

## 评估NOT条件
func _evaluate_not(context: Dictionary) -> bool:
    if sub_conditions.size() != 1:
        return false
    return not sub_conditions[0].evaluate(context)

## 评估叶子条件，子类实现
func _evaluate_leaf(_context: Dictionary) -> bool:
    return true
