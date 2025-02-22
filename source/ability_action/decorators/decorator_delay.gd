extends DecoratorAction
class_name DecoratorDelay

## 延时装饰器：延迟执行子节点

@export var delay_time: float = 1.0            # 延迟时间（秒）
@export var skip_first_delay: bool = false     # 是否跳过首次延迟
@export var ignore_time_scale: bool = false    # 是否忽略时间缩放

var _is_first_execution: bool = true

## 执行装饰器
func _execute(context: Dictionary) -> STATUS:
	# 检查子节点
	if not child : return STATUS.FAILURE
		
	# 处理首次执行
	if _is_first_execution and skip_first_delay:
		_is_first_execution = false
		return await child.execute(context)
		
	# 开始延时
	var tree := context.get("tree") as SceneTree
	if not tree:
		push_error("DelayDecorator: No SceneTree found in context")
		return STATUS.FAILURE
		
	# 存储上下文供后续使用
	var stored_context = context.duplicate()
	
	# 创建定时器
	await tree.create_timer(
		delay_time,
		ignore_time_scale,
		false,  # 不处理物理帧
		true    # 处理暂停
	).timeout
	return await child.execute(context)
