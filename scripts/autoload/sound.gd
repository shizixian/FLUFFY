extends Node
## Background music + synthesized sound effects (no audio files needed) + haptics.
## Effects are rendered once at startup into small AudioStreamWAV buffers.

const RATE := 44100
const POOL := 10

var _sfx: Dictionary = {}
var _players: Array = []
var _next := 0
var _music: AudioStreamPlayer
var _last_play_ms := {}


func _ready() -> void:
	_ensure_bus("Music")
	_ensure_bus("SFX")
	for i in POOL:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_players.append(p)
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	if ResourceLoader.exists("res://assets/bgm.ogg"):
		var stream = load("res://assets/bgm.ogg")
		if stream is AudioStreamOggVorbis:
			stream.loop = true
		_music.stream = stream
	add_child(_music)
	_build_library()
	apply_settings()


func _exit_tree() -> void:
	for p in _players:
		p.stop()
	_music.stop()


func _ensure_bus(name: String) -> void:
	if AudioServer.get_bus_index(name) == -1:
		AudioServer.add_bus()
		var idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, name)
		AudioServer.set_bus_send(idx, "Master")


func apply_settings() -> void:
	var mi := AudioServer.get_bus_index("Music")
	var si := AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(mi, linear_to_db(maxf(Save.bgm_volume, 0.0001)))
	AudioServer.set_bus_mute(mi, not Save.bgm_enabled or Save.bgm_volume <= 0.001)
	AudioServer.set_bus_volume_db(si, linear_to_db(maxf(Save.sfx_volume, 0.0001)))
	AudioServer.set_bus_mute(si, not Save.sfx_enabled or Save.sfx_volume <= 0.001)
	if Save.bgm_enabled and _music.stream and not _music.playing:
		_music.play()
	elif not Save.bgm_enabled and _music.playing:
		_music.stop()


func play(name: String, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	if not Save.sfx_enabled or not _sfx.has(name):
		return
	# Same sound twice within 25 ms just stacks volume — skip it.
	var now := Time.get_ticks_msec()
	if now - int(_last_play_ms.get(name, -1000)) < 25:
		return
	_last_play_ms[name] = now
	var p: AudioStreamPlayer = _players[_next]
	_next = (_next + 1) % POOL
	p.stream = _sfx[name]
	p.pitch_scale = pitch
	p.volume_db = volume_db
	p.play()


func vibrate(ms: int = 20) -> void:
	if Save.vibrate and OS.has_feature("mobile"):
		Input.vibrate_handheld(ms)


# ------------------------------------------------------------------ synth

## note: [freq_start, freq_end, t0, dur, amp, shape]
## shape: "bell" (sine + soft overtones), "soft" (round square), "tri", "noise"
func _render(notes: Array, length: float) -> AudioStreamWAV:
	var n := int(length * RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	for note in notes:
		var f0: float = note[0]
		var f1: float = note[1]
		var t0: float = note[2]
		var dur: float = note[3]
		var amp: float = note[4]
		var shape: String = note[5] if note.size() > 5 else "bell"
		var start := int(t0 * RATE)
		var count := int(dur * RATE)
		var phase := 0.0
		var attack := minf(0.006, dur * 0.2)
		for k in count:
			var i := start + k
			if i >= n:
				break
			var t := float(k) / RATE
			var u := float(k) / count
			var f := lerpf(f0, f1, u)
			phase += TAU * f / RATE
			var env := minf(t / attack, 1.0) * pow(1.0 - u, 2.2)
			var v := 0.0
			match shape:
				"bell":
					v = sin(phase) + 0.35 * sin(phase * 2.0) * (1.0 - u) + 0.12 * sin(phase * 3.01)
				"soft":
					v = sin(phase) + 0.3 * sin(phase * 3.0) + 0.12 * sin(phase * 5.0)
				"tri":
					v = 2.0 / PI * asin(sin(phase))
				"noise":
					v = rng.randf_range(-1.0, 1.0) * (0.6 + 0.4 * sin(phase))
			buf[i] += v * env * amp
	var bytes := PackedByteArray()
	bytes.resize(n * 2)
	for i in n:
		var s := clampf(buf[i], -1.0, 1.0)
		bytes.encode_s16(i * 2, int(s * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = bytes
	return w


func _build_library() -> void:
	var C5 := 523.25; var E5 := 659.25; var G5 := 783.99
	var C6 := 1046.5; var E6 := 1318.5; var G6 := 1568.0
	_sfx["click"] = _render([[620.0, 520.0, 0.0, 0.05, 0.35, "tri"]], 0.06)
	_sfx["select"] = _render([[700.0, 1080.0, 0.0, 0.09, 0.32, "bell"]], 0.1)
	_sfx["deselect"] = _render([[900.0, 650.0, 0.0, 0.07, 0.22, "bell"]], 0.08)
	_sfx["match"] = _render([
		[C6, C6, 0.0, 0.28, 0.28, "bell"],
		[E6, E6, 0.055, 0.32, 0.26, "bell"],
	], 0.4)
	_sfx["wrong"] = _render([[240.0, 150.0, 0.0, 0.18, 0.38, "soft"]], 0.2)
	_sfx["locked"] = _render([[330.0, 280.0, 0.0, 0.07, 0.3, "soft"]], 0.08)
	_sfx["slot"] = _render([[520.0, 430.0, 0.0, 0.1, 0.34, "tri"], [1040.0, 860.0, 0.0, 0.06, 0.1, "bell"]], 0.12)
	_sfx["undo"] = _render([[980.0, 560.0, 0.0, 0.14, 0.26, "bell"]], 0.16)
	_sfx["hint"] = _render([
		[1760.0, 1760.0, 0.0, 0.14, 0.18, "bell"],
		[2217.0, 2217.0, 0.05, 0.14, 0.16, "bell"],
		[2637.0, 2637.0, 0.10, 0.2, 0.14, "bell"],
	], 0.32)
	var shuffle_notes: Array = []
	for k in 7:
		shuffle_notes.append([2000.0 + k * 150.0, 1800.0, k * 0.045, 0.04, 0.22, "noise"])
	_sfx["shuffle"] = _render(shuffle_notes, 0.4)
	_sfx["deal"] = _render([[1500.0, 1300.0, 0.0, 0.025, 0.12, "bell"]], 0.03)
	_sfx["star"] = _render([[G6, G6, 0.0, 0.35, 0.22, "bell"], [C6 * 2.0, C6 * 2.0, 0.03, 0.3, 0.12, "bell"]], 0.4)
	_sfx["win"] = _render([
		[C5, C5, 0.0, 0.2, 0.26, "bell"],
		[E5, E5, 0.1, 0.2, 0.26, "bell"],
		[G5, G5, 0.2, 0.2, 0.26, "bell"],
		[C6, C6, 0.3, 0.55, 0.3, "bell"],
		[E6, E6, 0.3, 0.55, 0.14, "bell"],
	], 0.9)
	_sfx["fail"] = _render([
		[G5, G5, 0.0, 0.22, 0.24, "soft"],
		[E5, E5, 0.18, 0.22, 0.24, "soft"],
		[C5, C5 * 0.97, 0.36, 0.45, 0.26, "soft"],
	], 0.85)
	_sfx["pop"] = _render([[1800.0, 2400.0, 0.0, 0.05, 0.2, "bell"]], 0.06)
