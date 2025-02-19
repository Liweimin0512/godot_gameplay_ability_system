extends PresentationHandler
class_name SoundHandler

## 音效处理器

var _audio_player : AudioStreamPlayer2D

func set_audio_player(player: AudioStreamPlayer2D) -> void:
	_audio_player = player

func handle_effect(config: Dictionary, context: Dictionary) -> void:
	if not _audio_player:
		GASLogger.error("SoundHandler: audio player is null")
		return

	var sound_config := SoundConfig.from_dict(config)
	var sound_path = sound_config.sound
	if sound_path.is_empty():
		GASLogger.error("SoundHandler: sound path is empty")
		return

	# 加载音频
	var stream = load(sound_path)
	if not stream:
		GASLogger.error("SoundHandler: failed to load sound: {0}".format([sound_path]))
		return
	
	# 设置音频属性
	_audio_player.stream = stream
	_audio_player.volume_db = sound_config.volume
	_audio_player.pitch_scale = sound_config.pitch
	_audio_player.bus = sound_config.bus
	
	# 播放音频
	_audio_player.play()

class SoundConfig:
	var sound: String
	var volume: float
	var pitch: float
	var bus: String

	func _init(sound: String, volume: float, pitch: float, bus: String) -> void:
		self.sound = sound
		self.volume = volume
		self.pitch = pitch
		self.bus = bus

	func to_dict() -> Dictionary:
		return {
			"sound": sound,
			"volume": volume,
			"pitch": pitch,
			"bus": bus,
		}
	
	static func from_dict(config: Dictionary) -> SoundConfig:
		return SoundConfig.new(
			config.get("sound", ""),
			config.get("volume", 0.0),
			config.get("pitch", 1.0),
			config.get("bus", "Master"),
		)
