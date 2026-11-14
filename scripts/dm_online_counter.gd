extends Node







signal updated(count: int)

const CURVE: = [
	[0.0, 120.0], [1.0, 104.0], [2.0, 88.0], [3.0, 74.0], 
	[4.0, 66.0], [5.0, 62.0], [6.0, 70.0], [7.0, 84.0], 
	[8.0, 101.0], [9.0, 118.0], [10.0, 133.0], [11.0, 146.0], 
	[12.0, 158.0], [13.0, 167.0], [14.0, 174.0], [15.0, 181.0], 
	[16.0, 188.0], [17.0, 194.0], [18.0, 198.0], [19.0, 200.0], 
	[20.0, 196.0], [21.0, 188.0], [22.0, 170.0], [23.0, 144.0], 
	[24.0, 120.0], 
]


const MAX_ONLINE: = 200.0

const WEEKEND_BOOST: = 1.035
const TICK_MIN: = 2.8
const TICK_MAX: = 5.6

const MAX_STEP_RATIO: = 0.01
const JITTER_RATIO: = 0.0024
const DRIFT_LIMIT: = 0.022
const DRIFT_STEP: = 0.0014

var _value: = 0.0
var _last: = -1
var _drift: = 0.0
var _rng: = RandomNumberGenerator.new()
var _timer: Timer


func _ready() -> void :
	_rng.randomize()
	_drift = _rng.randf_range(-0.014, 0.014)
	_value = _baseline_now()
	_last = int(round(_value))
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_tick)
	add_child(_timer)
	_schedule()


func current_count() -> int:
	if _value <= 0.0:
		_value = _baseline_now()
	return int(round(_value))


func _tick() -> void :
	_drift = clampf(_drift + _rng.randf_range( - DRIFT_STEP, DRIFT_STEP), 
		- DRIFT_LIMIT, DRIFT_LIMIT)
	var target: = minf(_baseline_now() * (1.0 + _drift), MAX_ONLINE)
	var max_step: = maxf(1.2, target * MAX_STEP_RATIO)
	var pull: = clampf((target - _value) * 0.08, - max_step, max_step)
	var jitter: = _rng.randf_range(-1.0, 1.0)\
	* maxf(0.7, target * JITTER_RATIO)
	_value = clampf(_value + pull + jitter, 48.0, MAX_ONLINE)
	var shown: = int(round(_value))
	if shown == _last:
		_value += 1.0 if _rng.randf() < 0.5 else -1.0
		shown = int(round(_value))
	if shown != _last:
		_last = shown
		updated.emit(shown)
	_schedule()


func _schedule() -> void :
	_timer.start(_rng.randf_range(TICK_MIN, TICK_MAX))


func _baseline_now() -> float:
	var now: = Time.get_datetime_dict_from_system()
	var hour: = float(now["hour"]) + float(now["minute"]) / 60.0\
	+ float(now["second"]) / 3600.0
	var players: = _curve_at(hour)
	players *= _weekend_factor(int(now["weekday"]), hour)
	players *= _wave_factor()
	return minf(players, MAX_ONLINE)


func _curve_at(hour: float) -> float:
	var h: = clampf(hour, 0.0, 24.0)
	for i in range(CURVE.size() - 1):
		var a: Array = CURVE[i]
		var b: Array = CURVE[i + 1]
		if h <= float(b[0]):
			var span: = maxf(float(b[0]) - float(a[0]), 0.001)
			var t: = (h - float(a[0])) / span
			t = t * t * (3.0 - 2.0 * t)
			return lerpf(float(a[1]), float(b[1]), t)
	return float(CURVE[CURVE.size() - 1][1])


func _weekend_factor(weekday: int, hour: float) -> float:
	if weekday == 0 or weekday == 6:
		return WEEKEND_BOOST
	if weekday == 5 and hour >= 17.0:
		return 1.025
	return 1.0


func _wave_factor() -> float:
	var stamp: = Time.get_unix_time_from_system()
	return 1.0 + 0.026 * sin(stamp / 47.0)\
	+ 0.014 * sin(stamp / 17.0 + 1.3)\
	+ 0.008 * sin(stamp / 6.7 + 0.5)
