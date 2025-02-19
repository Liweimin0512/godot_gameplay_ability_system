extends ManagerInterface
class_name PresentationManagerInterface


## 表现管理器接口

func initialize(_presentation_table_type : TableType, _action_handlers: Dictionary = {}) -> void:
	pass

## 注册效果处理器
func register_effect_handler(_type: String, _handler: PresentationHandler) -> void:
	pass

## 获取效果处理器
func get_effect_handler(_type: String) -> PresentationHandler:
	return null

## 取消注册效果处理器
func unregister_effect_handler(_type: String) -> void:
	pass
