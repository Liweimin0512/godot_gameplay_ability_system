extends ManagerInterface
class_name ActionManagerInterface

## 动作管理器接口

## 初始化
func initialize(
		_resource_manager : CoreSystem.ResourceManager , 
		_data_manager : DataManager, 
		_action_paths: Dictionary, 
		_action_table_type : TableType) -> void:
	pass

## 应用行动树
func apply_action_tree(_action_tree_id: StringName, _context: Dictionary) -> void:
	pass


## 移除行动树缓存
func remove_action_tree(_action_tree_id: StringName, _context: Dictionary) -> void:
	pass


## 执行行动树
func execute_action_tree(_action_tree_id: StringName, _context: Dictionary) -> void:
	pass

## 获取行动树
func get_action_tree(action_tree_id: StringName) -> AbilityAction:
	return null
