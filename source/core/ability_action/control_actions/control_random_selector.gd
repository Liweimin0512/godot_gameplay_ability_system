extends ControlSelector
class_name ControlRandomSelector

## 随机选择节点执行

## 子节点权重配置
@export var weights: Array[float] = []

## 上次选择的节点索引
var _last_selected_index: int = -1


func _execute(context: Dictionary) -> STATUS:
    # 获取可执行的节点列表
    var executable_nodes = _get_executable_nodes(context)
    if executable_nodes.is_empty():
		GSALogger.error("ControlRandomSelector: No executable nodes found")
        return STATUS.FAILURE
        
    # 从可执行节点中随机选择
    var selected = _select_from_nodes(executable_nodes)
    if selected.index == -1:
		GSALogger.error("ControlRandomSelector: No executable nodes found")
        return STATUS.FAILURE
        
    # 记录选择的节点
    _last_selected_index = selected.index
    var status = await children[selected.index].execute(context)
    return status


func _revoke(context: Dictionary) -> bool:
    if _last_selected_index != -1:
        var ok = await children[_last_selected_index].revoke(context)
        _last_selected_index = -1
        return ok
    return true


## 获取可执行的节点列表
## [return] 可执行节点的信息列表 [{index: int, weight: float}]
func _get_executable_nodes(context: Dictionary) -> Array[Dictionary]:
    var executable_nodes: Array[Dictionary] = []
    for i in children.size():
        if children[i].can_execute(context):
            executable_nodes.append({
                "index": i,
                "weight": weights[i] if i < weights.size() else 1.0
            })
    return executable_nodes


## 从可执行节点中随机选择
## [param nodes] 可执行节点列表
## [return] 选择的节点信息 {index: int, weight: float}
func _select_from_nodes(nodes: Array[Dictionary]) -> Dictionary:
    if nodes.is_empty():
        return {"index": -1, "weight": 0.0}
        
    # 计算总权重
    var total_weight = 0.0
    for node in nodes:
        total_weight += node.weight
        
    # 随机选择
    var random_value = randf() * total_weight
    var cumulative_weight = 0.0
    
    for node in nodes:
        cumulative_weight += node.weight
        if random_value <= cumulative_weight:
            return node
            
    # 如果由于浮点数精度问题没有选中，返回最后一个
    return nodes[-1]