extends AbilityEffectActionNode
class_name SpawnVFXNode

## 生成特效节点

## 特效场景
@export var vfx_scene: PackedScene
## 是否附加到目标
@export var attach_to_target: bool = false
## 偏移量
@export var offset: Vector2
## 是否自动释放
@export var auto_free: bool = true
## 是否等待完成
@export var wait_for_completion: bool = false
## 挂载特效目标类型
@export_enum("target", "caster")
var mount_target_type: String = "target"
## 挂载点类型：身体、头、脚、手、武器
@export_enum("body", "head", "foot", "hand", "weapon")
var mount_point_type: String = "body"
## 特效节点
var _vfx: Node

func _perform_action(context: Dictionary) -> STATUS:
    var target = context.get(mount_target_type)
    if not target:
        GASLogger.error("SpawnVFXNode target is null")
        return STATUS.FAILURE
    var attach_point : Vector2
    if target.has_method("get_attach_point"):
        attach_point = target.get_attach_point(mount_point_type)
    _vfx = vfx_scene.instantiate()    
    if attach_to_target:
        # 附加到目标
        target.add_child(_vfx)
        _vfx.position = attach_point + offset
    else:
        # 附加到场景
        var tree = context.get("tree")
        tree.current_scene.add_child(_vfx)
        _vfx.global_position = target.global_position + attach_point + offset
    
    if _vfx.has_method("play") and auto_free:
        _vfx.play()

    if wait_for_completion:
        # 等待特效结束
        await _vfx.tree_exited
    
    return STATUS.SUCCESS

func _revoke_action() -> STATUS:
    # 如果特效不是自动释放的，则需要手动释放
    if not auto_free and _vfx:
        _vfx.get_parent().remove_child(_vfx)
        _vfx.queue_free()
    return STATUS.SUCCESS
