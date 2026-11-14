extends Node




const SAMPLE_RATE: = 44100
const VOICE_COUNT: = 16



const WORLD_VOICE_COUNT: = 8



const WORLD_NEAR_DISTANCE: = 7.0
const WORLD_FALLOFF_DB: = 9.0

var _players: Array[AudioStreamPlayer] = []
var _next_voice: = 0
var _world_players: Array[AudioStreamPlayer3D] = []
var _next_world_voice: = 0



var _reload_voice: AudioStreamPlayer
var _inspect_voice: AudioStreamPlayer
var _bolt_voice: AudioStreamPlayer


var _bot_reload_voice: AudioStreamPlayer3D
var _bot_bolt_voice: AudioStreamPlayer3D


var _bolt_token: = 0


var _bot_bolt_token: = 0

var _shots: Array[AudioStreamWAV] = []
var _hits: Array[AudioStreamWAV] = []
var _headshots: Array[AudioStreamWAV] = []
var _steps: Array[AudioStreamWAV] = []
var _knives: Array[AudioStreamWAV] = []




var _bank_mutex: = Mutex.new()
var _bank_ready: = false
var _bank: Dictionary = {}
var _synth_task: = -1

var _miss: AudioStreamWAV
var _ui: AudioStreamWAV
var _start: AudioStreamWAV
var _finish: AudioStreamWAV
var _tick: AudioStreamWAV
var _jump: AudioStreamWAV
var _land: AudioStreamWAV
var _reload: AudioStreamWAV
var _empty: AudioStreamWAV
var _bolt: AudioStreamWAV
var _draw: AudioStreamWAV
var _scope: AudioStreamWAV
var _flourish: AudioStreamWAV
var _butterfly_open: AudioStreamWAV
var _victory: AudioStreamWAV
var _defeat: AudioStreamWAV


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_voices()
	_synth_task = WorkerThreadPool.add_task(_synthesize_bank, false, "HEADSHOT audio")


func _process(_delta: float) -> void :
	if _synth_task < 0:
		return
	var bank: Dictionary = {}
	_bank_mutex.lock()
	if _bank_ready:
		_bank_ready = false


		bank = _bank
		_bank = {}
	_bank_mutex.unlock()
	if bank.is_empty():
		return

	WorkerThreadPool.wait_for_task_completion(_synth_task)
	_synth_task = -1
	_apply_bank(bank)

	set_process(false)


func _exit_tree() -> void :

	if _synth_task >= 0:
		WorkerThreadPool.wait_for_task_completion(_synth_task)
		_synth_task = -1




func _synthesize_bank() -> void :
	var bank: = {
		"shots": [_build_shot(1137), _build_shot(8841), _build_shot(5527)], 
		"hits": [_build_hit(0.0), _build_hit(0.06), _build_hit(-0.04)], 
		"headshots": [_build_headshot(0.0), _build_headshot(0.05)], 
		"steps": [
			_build_step(8123, 1.0), 
			_build_step(3391, 0.93), 
			_build_step(6611, 1.06), 
			_build_step(9477, 0.88), 
			_build_step(5501, 1.02), 
		], 
		"knives": [_build_knife(0.0), _build_knife(0.08)], 
		"miss": _build_miss(), 
		"ui": _build_ui(), 
		"start": _build_start(), 
		"finish": _build_finish(), 
		"tick": _build_tick(), 
		"jump": _build_jump(), 
		"land": _build_land(), 
		"reload": _build_reload(), 
		"empty": _build_empty(), 
		"bolt": _build_bolt(), 
		"draw": _build_knife_draw(), 
		"scope": _build_scope(), 
		"flourish": _build_knife_flourish(), 
		"butterfly": _build_butterfly_open(), 
		"victory": _build_victory(), 
		"defeat": _build_defeat(), 
	}
	_bank_mutex.lock()
	_bank = bank
	_bank_ready = true
	_bank_mutex.unlock()


func _apply_bank(bank: Dictionary) -> void :
	_shots.assign(bank.get("shots", []))
	_hits.assign(bank.get("hits", []))
	_headshots.assign(bank.get("headshots", []))
	_steps.assign(bank.get("steps", []))
	_knives.assign(bank.get("knives", []))
	_miss = bank.get("miss")
	_ui = bank.get("ui")
	_start = bank.get("start")
	_finish = bank.get("finish")
	_tick = bank.get("tick")
	_jump = bank.get("jump")
	_land = bank.get("land")
	_reload = bank.get("reload")
	_empty = bank.get("empty")
	_bolt = bank.get("bolt")
	_draw = bank.get("draw")
	_scope = bank.get("scope")
	_flourish = bank.get("flourish")
	_butterfly_open = bank.get("butterfly")
	_victory = bank.get("victory")
	_defeat = bank.get("defeat")
	_warm_voices()





func _warm_voices() -> void :
	if _hits.is_empty():
		return
	var stream: AudioStreamWAV = _hits[0]
	var warmed: Array[AudioStreamPlayer] = []
	for player in _players:
		player.stream = stream
		player.volume_db = -80.0
		player.play()
		warmed.append(player)
	await get_tree().process_frame
	await get_tree().process_frame


	for player in warmed:
		if player.stream == stream and is_equal_approx(player.volume_db, -80.0):
			player.stop()
			player.volume_db = 0.0


func _make_world_voice() -> AudioStreamPlayer3D:
	var world: = AudioStreamPlayer3D.new()
	world.bus = "Master"





	world.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	world.max_distance = 0.0
	world.max_db = 0.0

	world.attenuation_filter_db = -6.0
	world.attenuation_filter_cutoff_hz = 4500.0
	add_child(world)
	return world


func _create_voices() -> void :
	for i in VOICE_COUNT:
		var player: = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players.append(player)



	for i in WORLD_VOICE_COUNT:
		_world_players.append(_make_world_voice())
	_bot_reload_voice = _make_world_voice()
	_bot_bolt_voice = _make_world_voice()

	_reload_voice = AudioStreamPlayer.new()
	_reload_voice.bus = "Master"
	add_child(_reload_voice)
	_inspect_voice = AudioStreamPlayer.new()
	_inspect_voice.bus = "Master"
	add_child(_inspect_voice)
	_bolt_voice = AudioStreamPlayer.new()
	_bolt_voice.bus = "Master"
	add_child(_bolt_voice)


func play_shot() -> void :
	_play_random(_shots, -7.5, 0.96, 1.04)


func play_hit() -> void :
	_play_random(_hits, -10.0, 0.97, 1.05)


func play_headshot() -> void :
	_play_random(_headshots, -9.0, 0.98, 1.04)


func play_miss() -> void :
	_play(_miss, -24.0, randf_range(0.9, 1.1))


func play_ui() -> void :
	_play(_ui, -13.0, 1.0)


func play_click() -> void :
	_play(_ui, -11.0, randf_range(0.97, 1.04))


func play_start() -> void :
	_play(_start, -10.0, 1.0)


func play_finish() -> void :
	_play(_finish, -10.0, 1.0)


func play_victory() -> void :
	_play(_victory, -8.0, 1.0)


func play_defeat() -> void :
	_play(_defeat, -7.0, 1.0)





func play_bot_shot(position: Vector3) -> void :
	if _shots.is_empty():
		return
	_play_world(_shots[randi() % _shots.size()], -4.0, 
		randf_range(0.86, 0.96), position)




func play_bot_bolt(position: Vector3, delay: = 0.0) -> void :
	_bot_bolt_token += 1
	var token: = _bot_bolt_token
	if delay > 0.0:
		await get_tree().create_timer(delay, false).timeout
		if token != _bot_bolt_token:
			return
	_play_voice_at(_bot_bolt_voice, _bolt, -3.5, 
		randf_range(0.98, 1.03), position)


func play_bot_reload(position: Vector3) -> void :

	_bot_bolt_token += 1
	if _bot_bolt_voice != null:
		_bot_bolt_voice.stop()
	_play_voice_at(_bot_reload_voice, _reload, -2.5, 1.0, position)


func play_tick() -> void :
	_play(_tick, -17.0, 1.0)


func play_step() -> void :
	if _steps.is_empty():
		return

	_play(_steps[randi() % _steps.size()], randf_range(-18.5, -15.5), 
		randf_range(0.94, 1.06))


func play_jump() -> void :
	_play(_jump, -16.0, randf_range(0.96, 1.04))


func play_land() -> void :
	_play(_land, -13.0, randf_range(0.94, 1.06))





func play_bot_step(position: Vector3, intensity: = 1.0) -> void :
	if _steps.is_empty():
		return
	var volume: = lerpf(-12.0, -6.0, clampf(intensity, 0.0, 1.0))
	_play_world(_steps[randi() % _steps.size()], volume, 
		randf_range(0.92, 1.05), position)


func play_bot_jump(position: Vector3) -> void :
	_play_world(_jump, -7.5, randf_range(0.94, 1.02), position)


func play_bot_land(position: Vector3, intensity: = 1.0) -> void :
	var volume: = lerpf(-9.5, -4.0, clampf(intensity, 0.0, 1.0))
	_play_world(_land, volume, randf_range(0.92, 1.04), position)




func play_bot_scope(position: Vector3, scoped: = true) -> void :
	if _scope == null:
		return
	if scoped:
		_play_world(_scope, -5.0, randf_range(0.98, 1.02), position)
	else:
		_play_world(_scope, -8.0, randf_range(0.86, 0.9), position)


func play_reload() -> void :

	_bolt_token += 1
	if _bolt_voice != null:
		_bolt_voice.stop()
	_play_long(_reload_voice, _reload, -12.0, 1.0)


func play_empty() -> void :
	_play(_empty, -12.0, 1.0)






func play_bolt(delay: = 0.0) -> void :
	_bolt_token += 1
	var token: = _bolt_token
	if delay > 0.0:
		await get_tree().create_timer(delay, false).timeout
		if token != _bolt_token:
			return
	_play_long(_bolt_voice, _bolt, -14.0, randf_range(0.98, 1.03))


func play_knife() -> void :
	_play_random(_knives, -10.0, 0.96, 1.06)


func play_knife_draw() -> void :
	_play_long(_inspect_voice, _draw, -15.0, randf_range(0.98, 1.03))


func play_knife_flourish() -> void :
	_play_long(_inspect_voice, _flourish, -17.0, randf_range(0.97, 1.03))



func play_butterfly_open() -> void :
	_play(_butterfly_open, -11.0, randf_range(0.97, 1.03))




func stop_weapon_sounds() -> void :
	_bolt_token += 1
	if _reload_voice != null:
		_reload_voice.stop()
	if _inspect_voice != null:
		_inspect_voice.stop()
	if _bolt_voice != null:
		_bolt_voice.stop()




func stop_bot_weapon_sounds() -> void :
	_bot_bolt_token += 1
	if _bot_reload_voice != null:
		_bot_reload_voice.stop()
	if _bot_bolt_voice != null:
		_bot_bolt_voice.stop()


func stop_reload() -> void :
	if _reload_voice != null:
		_reload_voice.stop()


func stop_knife_flourish() -> void :
	if _inspect_voice != null:
		_inspect_voice.stop()


func play_scope_in() -> void :
	_play(_scope, -15.0, randf_range(0.98, 1.02))


func play_scope_out() -> void :
	_play(_scope, -18.0, randf_range(0.86, 0.9))




func _play_random(streams: Array[AudioStreamWAV], volume_db: float, 
		pitch_low: float, pitch_high: float) -> void :
	if streams.is_empty():
		return
	_play(streams[randi() % streams.size()], volume_db, randf_range(pitch_low, pitch_high))


func _play(stream: AudioStreamWAV, volume_db: float, pitch: float) -> void :
	if _players.is_empty() or stream == null:
		return
	var player: = _players[_next_voice]
	_next_voice = (_next_voice + 1) % _players.size()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.play()


func _play_long(voice: AudioStreamPlayer, stream: AudioStreamWAV, 
		volume_db: float, pitch: float) -> void :
	if voice == null or stream == null:
		return
	voice.stream = stream
	voice.volume_db = volume_db
	voice.pitch_scale = pitch
	voice.play()





func _play_world(stream: AudioStreamWAV, volume_db: float, pitch: float, 
		position: Vector3) -> void :
	if _world_players.is_empty() or stream == null:
		return
	var player: = _world_players[_next_world_voice]
	_next_world_voice = (_next_world_voice + 1) % _world_players.size()
	_play_voice_at(player, stream, volume_db, pitch, position)




func _play_voice_at(voice: AudioStreamPlayer3D, stream: AudioStreamWAV, 
		volume_db: float, pitch: float, position: Vector3) -> void :
	if voice == null or stream == null:
		return
	voice.global_position = position
	voice.stream = stream
	voice.volume_db = volume_db + _world_position_gain(position)
	voice.pitch_scale = pitch
	voice.play()





func _world_position_gain(position: Vector3) -> float:
	var distance: = position.distance_to(_listener_position())
	if distance <= WORLD_NEAR_DISTANCE:
		return 0.0
	var falloff: = 20.0 * log(distance / WORLD_NEAR_DISTANCE) / log(10.0)
	return - minf(falloff, WORLD_FALLOFF_DB)




func _listener_position() -> Vector3:
	var viewport: = get_viewport()
	if viewport == null:
		return Vector3.ZERO
	var listener: = viewport.get_audio_listener_3d()
	if listener != null and listener.is_inside_tree():
		return listener.get_global_transform().origin
	var camera: = viewport.get_camera_3d()
	if camera != null:
		return camera.global_position
	return Vector3.ZERO




func _buffer(duration: float) -> PackedFloat32Array:
	var samples: = PackedFloat32Array()
	samples.resize(maxi(int(SAMPLE_RATE * duration), 1))
	return samples


func _to_wav(samples: PackedFloat32Array, peak: = 0.92) -> AudioStreamWAV:
	var max_abs: = 0.0001
	for i in samples.size():
		max_abs = maxf(max_abs, absf(samples[i]))
	var gain: = peak / max_abs
	var bytes: = PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():

		var value: = samples[i] * gain
		value = value if absf(value) < 0.8 else signf(value) * (0.8 + 0.2 * tanh((absf(value) - 0.8) * 5.0))
		bytes.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 32767.0))
	var wav: = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = bytes
	return wav



func _add_click(buf: PackedFloat32Array, start: float, gain: float, tone: float, 
		decay: = 70.0) -> void :
	var start_i: = int(start * SAMPLE_RATE)
	var length: = mini(int(SAMPLE_RATE * 0.085), buf.size() - start_i)
	if length <= 0:
		return
	var rng: = RandomNumberGenerator.new()
	rng.seed = start_i * 37 + int(tone)
	var lp: = 0.0
	for i in length:
		var idx: = start_i + i
		var t: = float(i) / SAMPLE_RATE
		var n: = rng.randf_range(-1.0, 1.0)
		lp += (n - lp) * 0.42
		var high: = n - lp
		var env: = exp( - t * decay)
		var click: = high * env * 0.62
		var ring: = (sin(TAU * tone * t) * 0.42 + sin(TAU * tone * 1.47 * t) * 0.2)\
		* exp( - t * decay * 1.15)
		buf[idx] += (click + ring) * gain



func _add_ring(buf: PackedFloat32Array, start: float, gain: float, tone: float, 
		decay: = 12.0, duration: = 0.45) -> void :
	var start_i: = int(start * SAMPLE_RATE)
	var length: = mini(int(SAMPLE_RATE * duration), buf.size() - start_i)
	if length <= 0:
		return
	for i in length:
		var t: = float(i) / SAMPLE_RATE
		var env: = exp( - t * decay) * minf(1.0, t * 900.0)
		var ring: = sin(TAU * tone * t) * 0.55\
		+ sin(TAU * tone * 1.47 * t) * 0.27\
		+ sin(TAU * tone * 2.09 * t) * 0.14
		buf[start_i + i] += ring * env * gain



func _add_thud(buf: PackedFloat32Array, start: float, gain: float, freq_from: float, 
		freq_to: float, decay: = 18.0) -> void :
	var start_i: = int(start * SAMPLE_RATE)
	var length: = mini(int(SAMPLE_RATE * 0.32), buf.size() - start_i)
	if length <= 0:
		return
	var phase: = 0.0
	for i in length:
		var idx: = start_i + i
		var t: = float(i) / SAMPLE_RATE
		var k: = minf(t / 0.18, 1.0)
		var freq: = lerpf(freq_from, freq_to, k)
		phase += TAU * freq / SAMPLE_RATE
		var env: = exp( - t * decay) * minf(1.0, t * 900.0)
		buf[idx] += sin(phase) * env * gain



func _add_noise(buf: PackedFloat32Array, start: float, gain: float, cutoff: float, 
		decay: float, duration: = 0.16) -> void :
	var start_i: = int(start * SAMPLE_RATE)
	var length: = mini(int(SAMPLE_RATE * duration), buf.size() - start_i)
	if length <= 0:
		return
	var rng: = RandomNumberGenerator.new()
	rng.seed = start_i * 53 + int(cutoff)
	var lp: = 0.0
	var a: = 1.0 - exp( - TAU * cutoff / SAMPLE_RATE)
	for i in length:
		var idx: = start_i + i
		var t: = float(i) / SAMPLE_RATE
		var n: = rng.randf_range(-1.0, 1.0)
		lp += (n - lp) * a
		buf[idx] += lp * exp( - t * decay) * minf(1.0, t * 500.0) * gain



func _add_sweep(buf: PackedFloat32Array, start: float, gain: float, from_freq: float, 
		to_freq: float, duration: float, attack: = 0.25) -> void :
	var start_i: = int(start * SAMPLE_RATE)
	var length: = mini(int(SAMPLE_RATE * duration), buf.size() - start_i)
	if length <= 0:
		return
	var rng: = RandomNumberGenerator.new()
	rng.seed = start_i * 71 + int(from_freq)
	var low: = 0.0
	for i in length:
		var idx: = start_i + i
		var k: = float(i) / float(length)
		var cutoff: = lerpf(from_freq, to_freq, k)
		var a: = 1.0 - exp( - TAU * cutoff / SAMPLE_RATE)
		var n: = rng.randf_range(-1.0, 1.0)
		low += (n - low) * a
		var shape: = pow(sin(clampf(k / maxf(attack, 0.01), 0.0, 1.0) * PI * 0.5), 1.4)\
		if k < attack else pow(1.0 - (k - attack) / maxf(1.0 - attack, 0.01), 1.3)
		buf[idx] += low * shape * gain




func _build_shot(seed_value: int) -> AudioStreamWAV:
	var duration: = 1.35
	var samples: = _buffer(duration)
	var count: = samples.size()
	var rng: = RandomNumberGenerator.new()
	rng.seed = seed_value

	var a_high: = 1.0 - exp( - TAU * 2100.0 / SAMPLE_RATE)
	var a_mid: = 1.0 - exp( - TAU * 900.0 / SAMPLE_RATE)
	var a_low: = 1.0 - exp( - TAU * 150.0 / SAMPLE_RATE)
	var a_tail: = 1.0 - exp( - TAU * 380.0 / SAMPLE_RATE)
	var lp_high: = 0.0
	var lp_mid: = 0.0
	var lp_low: = 0.0
	var lp_tail: = 0.0
	var body_phase: = 0.0
	var sub_phase: = 0.0

	for i in count:
		var t: = float(i) / SAMPLE_RATE
		var n: = rng.randf_range(-1.0, 1.0)

		lp_high += (n - lp_high) * a_high
		lp_mid += (n - lp_mid) * a_mid
		lp_low += (n - lp_low) * a_low
		lp_tail += (n - lp_tail) * a_tail
		var high: = n - lp_high
		var band: = lp_mid - lp_low


		var crack: = high * exp( - t * 195.0) * 1.3
		var snap: = n * exp( - t * 900.0) * 0.85

		var body_freq: = 168.0 * exp( - t * 8.4) + 44.0
		body_phase += TAU * body_freq / SAMPLE_RATE
		sub_phase += TAU * (74.0 * exp( - t * 3.0) + 30.0) / SAMPLE_RATE
		var body: = sin(body_phase) * exp( - t * 9.8) * 0.95\
		+ sin(sub_phase) * exp( - t * 4.8) * 0.42

		var mid: = band * exp( - t * 30.0) * 1.15

		var tail: = lp_tail * exp( - t * 2.9) * 0.22

		var value: = crack + snap + body + mid + tail

		samples[i] = tanh(value * 1.45) * 0.86


	var delays: = [0.082, 0.148, 0.235, 0.36]
	var gains: = [0.2, 0.13, 0.085, 0.055]
	for d in delays.size():
		var offset: = int(float(delays[d]) * SAMPLE_RATE)
		var gain: float = gains[d]
		var lp: = 0.0
		var a: = 1.0 - exp( - TAU * 1400.0 / SAMPLE_RATE)
		for i in range(offset, count):
			lp += (samples[i - offset] - lp) * a
			samples[i] += lp * gain
	return _to_wav(samples, 0.94)


func _build_hit(shift: float) -> AudioStreamWAV:
	var samples: = _buffer(0.19)
	var rng: = RandomNumberGenerator.new()
	rng.seed = 7321
	var lp: = 0.0
	var a: = 1.0 - exp( - TAU * 1900.0 / SAMPLE_RATE)
	var phase: = 0.0
	for i in samples.size():
		var t: = float(i) / SAMPLE_RATE
		var n: = rng.randf_range(-1.0, 1.0)
		lp += (n - lp) * a
		var high: = n - lp
		phase += TAU * (132.0 * exp( - t * 24.0) + 56.0) / SAMPLE_RATE
		var thump: = sin(phase) * exp( - t * 40.0) * 0.8
		var slap: = high * exp( - t * 260.0) * 0.42
		var flesh: = lp * exp( - t * 62.0) * 0.9
		samples[i] = (thump + slap + flesh) * (1.0 + shift)
	return _to_wav(samples, 0.78)


func _build_headshot(shift: float) -> AudioStreamWAV:
	var samples: = _buffer(0.44)
	var rng: = RandomNumberGenerator.new()
	rng.seed = 4491
	var phase: = 0.0
	var lp: = 0.0
	var a: = 1.0 - exp( - TAU * 2600.0 / SAMPLE_RATE)
	for i in samples.size():
		var t: = float(i) / SAMPLE_RATE
		var n: = rng.randf_range(-1.0, 1.0)
		lp += (n - lp) * a
		var high: = n - lp
		phase += TAU * (170.0 * exp( - t * 26.0) + 62.0) / SAMPLE_RATE
		var thump: = sin(phase) * exp( - t * 34.0) * 0.72
		var crack: = high * exp( - t * 240.0) * 0.48

		var ping: = (sin(TAU * 1620.0 * t) * 0.26 + sin(TAU * 2380.0 * t) * 0.14)\
		* exp( - t * 17.0)
		samples[i] = (thump + crack + ping) * (1.0 + shift)
	return _to_wav(samples, 0.82)


func _build_miss() -> AudioStreamWAV:
	var samples: = _buffer(0.16)
	var rng: = RandomNumberGenerator.new()
	rng.seed = 404
	var low: = 0.0
	var smooth: = 0.0
	for i in samples.size():
		var k: = float(i) / float(samples.size())
		var t: = float(i) / SAMPLE_RATE
		var cutoff: = lerpf(3400.0, 420.0, k)
		var a: = 1.0 - exp( - TAU * cutoff / SAMPLE_RATE)
		var n: = rng.randf_range(-1.0, 1.0)
		low += (n - low) * a
		smooth = lerpf(smooth, low, 0.1)
		var env: = sin(pow(k, 0.55) * PI)
		samples[i] = smooth * env * 0.55
	return _to_wav(samples, 0.55)


func _build_empty() -> AudioStreamWAV:
	var samples: = _buffer(0.1)
	_add_click(samples, 0.0, 0.75, 2600.0, 130.0)
	_add_click(samples, 0.018, 0.35, 1500.0, 180.0)
	_add_noise(samples, 0.0, 0.35, 4200.0, 120.0, 0.08)
	return _to_wav(samples, 0.72)






func _build_bolt() -> AudioStreamWAV:



	var samples: = _buffer(1.0)

	_add_noise(samples, 0.11, 0.1, 900.0, 34.0, 0.11)

	_add_click(samples, 0.2, 0.58, 2450.0, 90.0)
	_add_noise(samples, 0.2, 0.22, 4800.0, 110.0, 0.06)

	_add_sweep(samples, 0.2, 0.28, 3400.0, 1100.0, 0.16, 0.1)
	_add_click(samples, 0.36, 0.24, 1750.0, 120.0)
	_add_ring(samples, 0.36, 0.06, 1480.0, 20.0, 0.2)

	_add_sweep(samples, 0.46, 0.24, 1100.0, 2800.0, 0.18, 0.18)
	_add_thud(samples, 0.64, 0.32, 145.0, 75.0, 34.0)
	_add_click(samples, 0.64, 0.72, 1380.0, 52.0)
	_add_noise(samples, 0.64, 0.22, 2600.0, 46.0, 0.07)
	_add_ring(samples, 0.64, 0.08, 900.0, 14.0, 0.18)

	_add_noise(samples, 0.72, 0.08, 1000.0, 26.0, 0.11)
	return _to_wav(samples, 0.8)



func _build_scope() -> AudioStreamWAV:
	var samples: = _buffer(0.14)
	_add_click(samples, 0.0, 0.42, 2300.0, 110.0)
	_add_noise(samples, 0.0, 0.24, 5200.0, 70.0, 0.05)
	_add_thud(samples, 0.0, 0.16, 240.0, 110.0, 55.0)
	return _to_wav(samples, 0.46)


func _build_reload() -> AudioStreamWAV:
	var samples: = _buffer(2.55)

	_add_thud(samples, 0.0, 0.26, 210.0, 95.0, 34.0)
	_add_noise(samples, 0.0, 0.18, 1500.0, 55.0, 0.1)
	_add_click(samples, 0.055, 0.58, 3250.0, 85.0)
	_add_noise(samples, 0.06, 0.22, 5200.0, 90.0, 0.06)


	_add_click(samples, 0.16, 0.42, 2050.0, 100.0)
	_add_sweep(samples, 0.2, 0.24, 2800.0, 900.0, 0.26, 0.08)
	_add_click(samples, 0.34, 0.28, 1650.0, 120.0)
	_add_click(samples, 0.43, 0.2, 2350.0, 150.0)


	_add_sweep(samples, 0.86, 0.18, 1100.0, 2600.0, 0.18, 0.18)
	_add_thud(samples, 1.06, 0.55, 175.0, 70.0, 26.0)
	_add_click(samples, 1.07, 0.78, 1520.0, 52.0)
	_add_click(samples, 1.08, 0.36, 2680.0, 80.0)
	_add_ring(samples, 1.07, 0.09, 1080.0, 16.0, 0.34)
	_add_noise(samples, 1.1, 0.24, 3000.0, 40.0, 0.12)


	_add_thud(samples, 1.24, 0.18, 135.0, 90.0, 55.0)
	_add_noise(samples, 1.24, 0.1, 1200.0, 26.0, 0.16)


	_add_click(samples, 1.56, 0.72, 1780.0, 50.0)
	_add_noise(samples, 1.56, 0.2, 3400.0, 60.0, 0.08)
	_add_sweep(samples, 1.7, 0.3, 3200.0, 1200.0, 0.24, 0.08)
	_add_ring(samples, 1.72, 0.05, 1450.0, 22.0, 0.22)
	_add_thud(samples, 1.98, 0.42, 150.0, 70.0, 30.0)
	_add_click(samples, 1.99, 0.92, 1320.0, 44.0)
	_add_noise(samples, 2.0, 0.3, 2600.0, 44.0, 0.1)
	_add_ring(samples, 1.99, 0.12, 860.0, 10.0, 0.5)
	_add_click(samples, 2.16, 0.62, 1900.0, 70.0)
	_add_click(samples, 2.22, 0.3, 2900.0, 110.0)


	_add_click(samples, 2.36, 0.28, 2250.0, 120.0)
	_add_noise(samples, 2.3, 0.08, 1400.0, 16.0, 0.2)
	return _to_wav(samples, 0.84)


func _build_knife(shift: float) -> AudioStreamWAV:
	var samples: = _buffer(0.3)
	var rng: = RandomNumberGenerator.new()
	rng.seed = 606 + int(shift * 1000.0)
	var low: = 0.0
	var low_cloth: = 0.0
	for i in samples.size():
		var k: = float(i) / float(samples.size())
		var t: = float(i) / SAMPLE_RATE
		var cutoff: = lerpf(620.0, 4400.0, pow(sin(k * PI), 0.8))
		var a: = 1.0 - exp( - TAU * cutoff / SAMPLE_RATE)
		var a_cloth: = 1.0 - exp( - TAU * 520.0 / SAMPLE_RATE)
		var n: = rng.randf_range(-1.0, 1.0)
		low += (n - low) * a
		low_cloth += (n - low_cloth) * a_cloth
		var high: = n - low
		var env: = sin(pow(k, 0.55) * PI)
		samples[i] += (low * 0.5 + high * 0.26) * env
		samples[i] += low_cloth * env * 0.18

	for i in samples.size():
		var t: = float(i) / SAMPLE_RATE
		samples[i] += (sin(TAU * 2450.0 * t) * 0.055 + sin(TAU * 3610.0 * t) * 0.03)\
		* exp( - t * 22.0) * (1.0 + shift)
	return _to_wav(samples, 0.72)


func _build_knife_draw() -> AudioStreamWAV:
	var samples: = _buffer(0.52)

	_add_sweep(samples, 0.0, 0.3, 700.0, 3600.0, 0.24, 0.22)
	_add_click(samples, 0.035, 0.34, 2900.0, 70.0)
	for i in samples.size():
		var t: = float(i) / SAMPLE_RATE
		var local: = t - 0.09
		if local > 0.0:
			samples[i] += (sin(TAU * 2860.0 * local) * 0.075\
			+ sin(TAU * 4260.0 * local) * 0.035) * exp( - local * 12.0)

	_add_noise(samples, 0.28, 0.16, 1500.0, 30.0, 0.14)
	_add_thud(samples, 0.29, 0.1, 120.0, 70.0, 55.0)
	return _to_wav(samples, 0.66)



func _build_butterfly_open() -> AudioStreamWAV:
	var samples: = _buffer(0.62)
	_add_click(samples, 0.0, 0.42, 2350.0, 95.0)
	_add_noise(samples, 0.0, 0.14, 4200.0, 80.0, 0.05)
	_add_sweep(samples, 0.02, 0.26, 900.0, 3600.0, 0.24, 0.08)

	_add_click(samples, 0.26, 0.58, 2880.0, 55.0)
	_add_click(samples, 0.275, 0.3, 1980.0, 90.0)
	_add_ring(samples, 0.26, 0.1, 2450.0, 18.0, 0.26)
	_add_noise(samples, 0.26, 0.16, 5200.0, 50.0, 0.05)
	return _to_wav(samples, 0.62)





func _build_knife_flourish() -> AudioStreamWAV:
	var samples: = _buffer(3.2)

	_add_sweep(samples, 0.02, 0.24, 600.0, 3600.0, 0.44, 0.06)
	_add_noise(samples, 0.08, 0.1, 5200.0, 16.0, 0.3)
	_add_click(samples, 0.6, 0.24, 2950.0, 55.0)
	_add_ring(samples, 0.64, 0.14, 2600.0, 7.0, 0.7)

	_add_click(samples, 1.16, 0.24, 1700.0, 130.0)
	_add_noise(samples, 1.16, 0.1, 3100.0, 60.0, 0.1)

	_add_sweep(samples, 1.24, 0.52, 3200.0, 700.0, 0.34, 0.06)

	_add_sweep(samples, 1.74, 0.26, 800.0, 4200.0, 0.34, 0.06)
	_add_click(samples, 2.28, 0.44, 2900.0, 55.0)
	_add_ring(samples, 2.28, 0.12, 2550.0, 12.0, 0.55)

	_add_sweep(samples, 2.44, 0.34, 3800.0, 800.0, 0.34, 0.06)
	_add_thud(samples, 2.96, 0.16, 190.0, 80.0, 34.0)
	_add_noise(samples, 2.96, 0.08, 1800.0, 32.0, 0.12)
	_add_click(samples, 2.98, 0.22, 2400.0, 90.0)
	return _to_wav(samples, 0.6)




func _build_step(seed_value: int, weight: float) -> AudioStreamWAV:


	var samples: = _buffer(0.34)
	var rng: = RandomNumberGenerator.new()
	rng.seed = seed_value

	var heel_at: = 0.004 + rng.randf() * 0.004
	var toe_at: = heel_at + 0.062 + rng.randf() * 0.024
	var heel_freq: = 88.0 + rng.randf() * 18.0
	var toe_freq: = 112.0 + rng.randf() * 26.0

	var hardness: = clampf(2.0 - weight, 0.85, 1.15)


	_add_noise(samples, heel_at, 0.5 * hardness, 4200.0, 125.0, 0.075)

	_add_thud(samples, heel_at, 0.6 * weight, heel_freq, 48.0, 42.0)
	_add_thud(samples, heel_at + 0.002, 0.09 * weight, 152.0, 92.0, 62.0)

	_add_noise(samples, heel_at + 0.005, 0.17 * hardness, 900.0, 24.0, 0.2)

	_add_thud(samples, toe_at, 0.22 * weight, toe_freq, 58.0, 62.0)
	_add_noise(samples, toe_at, 0.2 * hardness, 3100.0, 95.0, 0.055)

	_add_noise(samples, 0.012, 0.055 * hardness, 2400.0, 13.0, 0.15)


	var dry: = samples.duplicate()
	var taps: = [[0.021, 0.13], [0.043, 0.075], [0.071, 0.045], [0.104, 0.024]]
	for tap in taps:
		var delay: = int(float(tap[0]) * SAMPLE_RATE)
		var tap_gain: = float(tap[1])
		for i in range(delay, samples.size()):
			samples[i] += dry[i - delay] * tap_gain

	return _to_wav(samples, 0.62)


func _build_jump() -> AudioStreamWAV:
	var samples: = _buffer(0.22)
	_add_sweep(samples, 0.0, 0.22, 380.0, 1100.0, 0.14, 0.35)
	_add_noise(samples, 0.0, 0.14, 1300.0, 30.0, 0.12)
	_add_thud(samples, 0.0, 0.24, 130.0, 85.0, 40.0)
	return _to_wav(samples, 0.6)


func _build_land() -> AudioStreamWAV:
	var samples: = _buffer(0.28)
	var rng: = RandomNumberGenerator.new()
	rng.seed = 9182
	var lp: = 0.0
	var a: = 1.0 - exp( - TAU * 700.0 / SAMPLE_RATE)
	var phase: = 0.0
	for i in samples.size():
		var t: = float(i) / SAMPLE_RATE
		var n: = rng.randf_range(-1.0, 1.0)
		lp += (n - lp) * a
		phase += TAU * (80.0 * exp( - t * 16.0) + 36.0) / SAMPLE_RATE
		var thud: = sin(phase) * exp( - t * 34.0) * 0.7
		var grit: = (n - lp) * exp( - t * 70.0) * 0.22
		var scuff: = lp * exp( - t * 26.0) * 0.48
		samples[i] = thud + grit + scuff
	return _to_wav(samples, 0.74)


func _build_ui() -> AudioStreamWAV:
	var samples: = _buffer(0.075)

	_add_click(samples, 0.0, 0.58, 2050.0, 155.0)
	_add_noise(samples, 0.0, 0.2, 5200.0, 200.0, 0.045)
	for i in samples.size():
		var t: = float(i) / SAMPLE_RATE
		samples[i] += sin(TAU * 780.0 * t) * exp( - t * 150.0) * 0.14
	return _to_wav(samples, 0.62)


func _build_tick() -> AudioStreamWAV:
	var samples: = _buffer(0.06)
	_add_click(samples, 0.0, 0.38, 2100.0, 150.0)
	return _to_wav(samples, 0.55)


func _build_start() -> AudioStreamWAV:
	var samples: = _buffer(0.95)
	var phase: = 0.0
	for i in samples.size():
		var t: = float(i) / SAMPLE_RATE
		var k: = clampf(t / 0.95, 0.0, 1.0)
		var freq: = lerpf(160.0, 520.0, pow(k, 1.6))
		phase += TAU * freq / SAMPLE_RATE
		var env: = minf(1.0, t * 9.0) * exp( - t * 2.6)
		samples[i] = sin(phase) * env * 0.3 + sin(phase * 2.0) * env * 0.1
	_add_thud(samples, 0.02, 0.55, 110.0, 48.0, 8.0)
	_add_sweep(samples, 0.1, 0.22, 500.0, 2600.0, 0.7, 0.15)
	return _to_wav(samples, 0.82)


func _build_finish() -> AudioStreamWAV:
	var samples: = _buffer(1.35)
	var notes: = [523.25, 659.25, 783.99, 1046.5, 1318.51]
	for n in notes.size():
		var start: = n * 0.095
		var start_i: = int(start * SAMPLE_RATE)
		for i in range(start_i, samples.size()):
			var local: = float(i - start_i) / SAMPLE_RATE
			samples[i] += sin(TAU * notes[n] * local) * exp( - local * 4.5) * 0.14
	_add_click(samples, 0.0, 0.18, 1800.0, 90.0)
	return _to_wav(samples, 0.8)



func _build_victory() -> AudioStreamWAV:
	var samples: = _buffer(2.25)
	var notes: = [523.25, 659.25, 783.99, 1046.5, 1318.51]
	var starts: = [0.0, 0.11, 0.22, 0.34, 0.48]
	for n in notes.size():
		var start_i: = int(float(starts[n]) * SAMPLE_RATE)
		for i in range(start_i, samples.size()):
			var local: = float(i - start_i) / SAMPLE_RATE
			var env: = exp( - local * 2.7) * minf(1.0, local * 70.0)
			samples[i] += sin(TAU * notes[n] * local) * env * 0.15
			samples[i] += sin(TAU * notes[n] * 2.0 * local) * env * 0.045
	_add_thud(samples, 0.0, 0.34, 132.0, 58.0, 9.0)
	_add_ring(samples, 0.02, 0.1, 1046.5, 3.4, 2.0)
	_add_sweep(samples, 0.05, 0.09, 700.0, 3600.0, 1.1, 0.22)
	return _to_wav(samples, 0.86)



func _build_defeat() -> AudioStreamWAV:
	var samples: = _buffer(2.55)
	var notes: = [392.0, 311.13, 261.63, 196.0]
	var starts: = [0.02, 0.28, 0.56, 0.92]
	for n in notes.size():
		var start_i: = int(float(starts[n]) * SAMPLE_RATE)
		for i in range(start_i, samples.size()):
			var local: = float(i - start_i) / SAMPLE_RATE
			var env: = exp( - local * 2.2) * minf(1.0, local * 55.0)
			samples[i] += sin(TAU * notes[n] * local) * env * 0.17
			samples[i] += sin(TAU * notes[n] * 0.5 * local) * env * 0.08
	_add_thud(samples, 0.0, 0.62, 96.0, 34.0, 5.2)
	_add_thud(samples, 0.75, 0.34, 78.0, 28.0, 5.8)
	_add_noise(samples, 0.0, 0.2, 900.0, 3.2, 1.5)
	_add_sweep(samples, 0.1, 0.15, 1900.0, 260.0, 1.9, 0.14)
	return _to_wav(samples, 0.84)
