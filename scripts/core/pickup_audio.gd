class_name PickupAudio
extends Node
## Plays the capped rising-pitch pickup sound. The tone is a short generated
## placeholder blip (real sounds come with the audio pass); notes follow a
## pentatonic scale, which sounds pleasant at any speed. Uses a small fixed
## pool of players (effect budget: at most 8 identical sounds at once).

var chain: PickupChain
var _players: Array[AudioStreamPlayer] = []
var _next: int = 0
var _clock: float = 0.0


func _ready() -> void:
	chain = PickupChain.from_config()
	var stream: AudioStreamWAV = make_blip(Data.cfg_float("pickups.sound_base_hz"), Data.cfg_float("pickups.sound_length_s"))
	for _i: int in Data.cfg_int("effect_budgets.max_identical_sounds"):
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = Data.cfg_float("pickups.sound_volume_db")
		add_child(player)
		_players.append(player)


func _process(delta: float) -> void:
	_clock += delta


func on_pickup() -> void:
	var step: int = chain.on_pickup(_clock)
	if step < 0 or _players.is_empty():
		return
	var scale: Array = Data.cfg("pickups.scale_semitones")
	var semitones: float = float(scale[clampi(step, 0, scale.size() - 1)])
	var player: AudioStreamPlayer = _players[_next]
	_next = (_next + 1) % _players.size()
	player.pitch_scale = pow(2.0, semitones / 12.0)
	player.play()


## A short sine blip with a quick fade, as 16-bit mono PCM.
static func make_blip(frequency_hz: float, length_s: float) -> AudioStreamWAV:
	var mix_rate: int = 22050
	var count: int = int(mix_rate * length_s)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i: int in count:
		var t: float = float(i) / mix_rate
		var envelope: float = 1.0 - float(i) / count
		var sample: int = int(sin(TAU * frequency_hz * t) * envelope * 0.6 * 32767.0)
		data.encode_s16(i * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = data
	return stream
