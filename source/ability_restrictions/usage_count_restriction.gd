extends AbilityRestriction
class_name UsageCountRestriction

## 使用次数限制器

@export var max_count: int
@export var used_count: int

func _init(config : Dictionary = {}) -> void:
    max_count = config.get("max_count", 0)
    used_count = 0

func can_execute(_context: Dictionary) -> bool:
    var can_use = used_count < max_count
    if not can_use:
        can_use_reason = "次数已用尽"
    return can_use

func before_ability_execute(_context: Dictionary) -> void:
    used_count += 1
    
func reset() -> void:
    used_count = 0