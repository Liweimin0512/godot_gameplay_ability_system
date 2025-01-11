extends MarginContainer
class_name W_SkillIcon

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

var _skill_ability: SkillAbility

func setup(skill: SkillAbility) -> void:
	_skill_ability = skill
	texture_rect.texture = _skill_ability.icon
	_skill_ability.cooldown_changed.connect(
		func(cooldown: int) -> void:_update_cooldown_display(cooldown)
	)
	_update_cooldown_display(_skill_ability.current_cooldown)

func _update_cooldown_display(cooldown: int) -> void:
	label.text = str(cooldown)
	label.visible = cooldown > 0
