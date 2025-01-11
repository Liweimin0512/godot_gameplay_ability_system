extends EditorInspectorPlugin

const GenerateEffectConfigButton = preload("res://addons/godot_gameplay_ability_system/source/editor/generate_effect_config_button.gd")

func _can_handle(object):
	# We support all objects in this example.
	return object is EffectEditorNode

func _parse_begin(object: Object) -> void:
	var button_load := Button.new()
	button_load.text = "读取配置"
	add_custom_control(button_load)
	var button_save := Button.new()
	button_save.text = "存储配置"
	add_custom_control(button_save)
	button_load.pressed.connect(func() -> void: object.call("_on_load"))
	button_save.pressed.connect(func() -> void: object.call("_on_save"))
