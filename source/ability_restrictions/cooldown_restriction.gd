extends AbilityRestriction
class_name CooldownRestriction

## 冷却时间限制器

@export var cooldown_time: float = 0.0              ## 冷却时间
@export var remaining_cooldown_time: float = 0.0    ## 剩余冷却时间

func _init(config : Dictionary = {}) -> void:
    cooldown_time = config.get("cooldown", 0.0)
    remaining_cooldown_time = cooldown_time

func can_execute(_context: Dictionary) -> bool:
    var can_use = remaining_cooldown_time <= 0
    if not can_use:
        can_use_reason = "cooldown"
    return can_use

func before_ability_execute(_context: Dictionary) -> void:
    remaining_cooldown_time = cooldown_time