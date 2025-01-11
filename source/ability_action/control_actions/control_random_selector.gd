extends ControlAction
class_name ControlRandomSelector

## 子节点权重配置
@export var weights: Array[float] = []

## 上次选择的节点索引
var _last_selected_index: int = -1

func _execute(context: Dictionary) -> STATUS:
	# 选择节点
	var selected_index = _select_node()
	if selected_index == -1:
		return STATUS.FAILURE
	
	# 记录选择的节点
	_last_selected_index = selected_index
	
	await context.get("tree").create_timer(0.1).timeout
	var status = await children[selected_index].execute(context)
	return status

func _revoke(context: Dictionary) -> bool:
	# 撤销选择的节点
	if _last_selected_index != -1:
		var ok = await children[_last_selected_index].revoke(context)
		return ok
	return true

# 选择节点
func _select_node() -> int:
	# 根据权重选择节点
	var random_weight : Array[float] = []
	for i in children.size():
		if i < weights.size():
			random_weight.append(weights[i])
		else:
			random_weight.append(1.0)
	var total_weight = random_weight.reduce(func(a, b): return a + b, 0.0)
	var random_value = randf_range(0, total_weight)
	var cumulative_weight = 0.0
	for i in range(random_weight.size()):
		cumulative_weight += random_weight[i]
		if random_value < cumulative_weight:
			return i
	return -1
