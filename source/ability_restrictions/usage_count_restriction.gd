extends AbilityRestriction
class_name UsageCountRestriction

## 使用次数限制器

@export var max_count: int
@export var used_count: int

func _init(p_max_count: int = 0, p_used_count: int = 0) -> void:
	max_count = p_max_count
	used_count = p_used_count

func can_execute(_context: AbilityContext) -> bool:
	var can_use = used_count < max_count
	if not can_use:
		can_use_reason = "次数已用尽"
	return can_use

func before_ability_execute(_context: AbilityContext) -> void:
	used_count += 1
	
func reset() -> void:
	used_count = 0
