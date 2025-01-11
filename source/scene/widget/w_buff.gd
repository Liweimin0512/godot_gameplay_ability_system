extends MarginContainer
class_name W_Buff

## 技能BUFF控件

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

var buff : BuffAbility

func setup(p_buff: BuffAbility) -> void:
	buff = p_buff
	texture_rect.texture = buff.icon
	label.text = str(buff.value)
	buff.value_changed.connect(
		func(value: int) -> void:
			label.text = str(buff.value)
	)
