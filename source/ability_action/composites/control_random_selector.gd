extends ControlSelector
class_name ControlRandomSelector

## 随机选择节点执行

## 子节点权重配置
@export var weights: Array[float] = []

func _execute(context: AbilityEffectContext) -> STATUS:
	if children.is_empty():
		GASLogger.error("ControlRandomSelector: No children")
		return STATUS.FAILURE

	# 获取可执行的节点列表
	var executable_nodes := _get_executable_nodes(context)
	# 从可执行节点中随机选择
	var selected := _select_from_nodes(executable_nodes)
	if selected.index == -1:
		GASLogger.error("ControlRandomSelector: No executable nodes found")
		return STATUS.FAILURE
		
	# 记录选择的节点
	_last_selected_index = selected.index
	var status = await children[selected.index].execute(context)
	return status


## 获取可执行的节点列表
## [return] 可执行节点的信息列表 [{index: int, weight: float}]
func _get_executable_nodes(_context: AbilityEffectContext) -> Array[Dictionary]:
	var executable_nodes: Array[Dictionary] = []
	for i in children.size():
		executable_nodes.append({"index": i, "weight": weights[i] if i < weights.size() else 1.0})
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
