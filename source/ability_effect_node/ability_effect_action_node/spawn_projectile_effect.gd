extends AbilityEffectActionNode
class_name SpawnProjectileEffect

## 生成投射物节点

## 投射物场景
@export var projectile_scene: PackedScene
@export var speed: float
## 是否从上一个目标发射
@export var spawn_from_last_target: bool = false
## 起始位置挂点类型
@export var start_position_type: String = "body"
## 目标位置挂点类型
@export var target_position_type: String = "body"

func _perform_action(context: Dictionary) -> STATUS:
    # 获取施法单位
    var caster = context.get("caster")
    
    # 获取起始位置
    var start_pos : Vector2
    var last_target = context.get("last_target")
    if spawn_from_last_target:
        if last_target and last_target.has_method("get_cast_position"):
            start_pos = last_target.get_cast_position("body")
        else:
            GASLogger.error("SpawnProjectileEffect: last_target not found or invalid")
            return STATUS.FAILURE
    else:
        if caster.has_method("get_cast_position"):
            start_pos = caster.get_cast_position(start_position_type)
        else:
            GASLogger.error("SpawnProjectileEffect: caster has no get_cast_position method")
            return STATUS.FAILURE
    
    var target = context.get("target")
    if target == null:
        GASLogger.error("SpawnProjectileEffect: target is null")
        return STATUS.FAILURE
    var target_pos: Vector2
    if target.has_method("get_cast_position"):
        target_pos = target.get_cast_position(target_position_type)
    else:
        GASLogger.error("SpawnProjectileEffect: target has no get_cast_position method")
        return STATUS.FAILURE
    
    var projectile = projectile_scene.instantiate()
    if spawn_from_last_target:
        last_target.add_child(projectile)
    else:
        caster.add_child(projectile)
    if projectile.has_method("setup"):
        projectile.setup({
            "caster": caster,
            "target": target,
            "start_position": start_pos,
            "target_position": target_pos,
            "speed": speed,
        })
    else:
        GASLogger.error("SpawnProjectileEffect: projectile has no setup method")
        return STATUS.FAILURE
    
    # 等待投射物到达目标位置
    await projectile.hit_target
    
    return STATUS.SUCCESS