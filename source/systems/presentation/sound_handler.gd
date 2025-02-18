extends PresentationHandler
class_name SoundHandler

var _active_players: Dictionary = {}

func play(owner: Node, config: Dictionary) -> void:
    var sound_path = config.get("sound", "")
    if sound_path.is_empty():
        GASLogger.error("SoundHandler: sound path is empty")
        return
        
    # 获取或创建音频播放器
    var player = _get_audio_player(owner)
    if not player:
        return
        
    # 加载音频
    var stream = load(sound_path)
    if not stream:
        GASLogger.error("SoundHandler: failed to load sound: {0}".format([sound_path]))
        return
        
    # 设置音频属性
    player.stream = stream
    player.volume_db = config.get("volume", 0.0)
    player.pitch_scale = config.get("pitch", 1.0)
    player.bus = config.get("bus", "Master")
    
    # 播放音频
    player.play()
    
    # 自动清理
    if config.get("one_shot", true):
        player.finished.connect(func(): player.queue_free())

func stop(owner: Node) -> void:
    if _active_players.has(owner):
        var player = _active_players[owner]
        if is_instance_valid(player):
            player.stop()
            player.queue_free()
        _active_players.erase(owner)

func _get_audio_player(owner: Node) -> AudioStreamPlayer2D:
    var player = AudioStreamPlayer2D.new()
    owner.add_child(player)
    _active_players[owner] = player
    return player