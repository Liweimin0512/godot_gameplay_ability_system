extends EffectAction
class_name PlaySoundEffect

## 播放音效节点

## 音效
@export var sound_effect: AudioStream
## 音量
@export var volume_db: float = 0.0
## 音调
@export var pitch_scale: float = 1.0
## 总线
@export var bus: String = "Master"
@export var position_type: String = "2D"  # "2D" or "3D"

func _perform_action(context: Dictionary) -> STATUS:
    var target = context.get("target")
    if not target:
        return STATUS.FAILURE
        
    var audio_player = _create_audio_player()
    target.add_child(audio_player)
    
    audio_player.stream = sound_effect
    audio_player.volume_db = volume_db
    audio_player.pitch_scale = pitch_scale
    audio_player.bus = bus
    audio_player.play()
    
    await audio_player.finished
    audio_player.queue_free()
    
    return STATUS.SUCCESS

func _create_audio_player() -> Node:
    return AudioStreamPlayer2D.new() if position_type == "2D" else AudioStreamPlayer3D.new()