extends Node




signal settings_changed
signal display_changed
signal mobile_layout_changed
signal hud_layout_changed



signal render_scale_changed(value: float)

signal gyro_calibration_requested

const WeaponData = preload("res://scripts/weapon_data.gd")
const MapData = preload("res://scripts/map_data.gd")
const ConfigCode = preload("res://scripts/config_code.gd")
const CountryData = preload("res://scripts/country_data.gd")
const BotNames = preload("res://scripts/bot_names.gd")
const PlayerSkinData = preload("res://scripts/player_skin_data.gd")

const CONFIG_PATH: = "user://headshot_settings.cfg"


const SESSION_MARKER: = "user://session_active.marker"

const LEGACY_CONFIG_FILE: = "offlix_settings.cfg"
const LEGACY_USER_DIR: = "OFFLIX"

const PRIMARY_ID: = "awp"
const PRIMARY_SKIN: = "default"
const PISTOL_ID: = "deagle"
const PISTOL_SKIN: = "chrome"
const MELEE_SKIN: = "combat"

const SENS_MIN: = 0.2
const SENS_MAX: = 3.0


const GYRO_SENS_MIN: = 0.25
const GYRO_SENS_MAX: = 3.0
const GYRO_SENS_DEFAULT: = 1.0
const MANNEQUIN_MIN: = 1
const MANNEQUIN_MAX: = 12
const FOV_MIN: = 60.0
const FOV_MAX: = 120.0
const MAP_DEFAULT: = "yard"



const RATING_START: = 1000
const RATING_MIN: = 100
const RATING_RECENT_MAX: = 10


const ABANDON_PENALTY: = 40
const RATING_LEVELS: = [
	{"level": 1, "name": "НОВИЧОК", "min": 0}, 
	{"level": 2, "name": "ЛЮБИТЕЛЬ", "min": 1200}, 
	{"level": 3, "name": "БОЕЦ", "min": 1450}, 
	{"level": 4, "name": "ОПЫТНЫЙ", "min": 1700}, 
	{"level": 5, "name": "ВЕТЕРАН", "min": 1950}, 
	{"level": 6, "name": "ЭЛИТА", "min": 2200}, 
	{"level": 7, "name": "МАСТЕР", "min": 2450}, 
	{"level": 8, "name": "ГРОССМЕЙСТЕР", "min": 2700}, 
	{"level": 9, "name": "ЛЕГЕНДА", "min": 2850}, 
	{"level": 10, "name": "HEADSHOT", "min": 3000}, 
]


const RATING_WIDGET_STYLES: = [
	"МИНИМАЛЬНЫЙ", "КЛАССИКА", "ШИРОКИЙ", "ПРОГРЕСС", "CS", 
]
const RENDER_SCALE_MIN: = 0.5
const BRIGHTNESS_MIN: = 0.7
const BRIGHTNESS_MAX: = 1.4

const DEFAULT_OWNED: = [
	"awp|default", "knife|combat",
	"ak47|classic", "m4a1|steel",
	"deagle|chrome", 
]

# Ножи, которые больше не выдаются сразу — их можно достать из кейсов и рынка.
const LOCKED_START_ITEMS: = [
	"knife|butterfly", "knife|forest", "knife|lava",
	"knife|bayonet", "knife|karambit", "knife|skeleton", "knife|dagger",
	"knife|nomad",
]

const DEFAULT_BINDS: = {
	"move_forward": KEY_W, 
	"move_back": KEY_S, 
	"move_left": KEY_A, 
	"move_right": KEY_D, 
	"jump": KEY_SPACE, 
	"crouch": KEY_CTRL, 
	"reload": KEY_R, 
	"inspect": KEY_F, 
	"slot_primary": KEY_1, 
	"slot_secondary": KEY_2, 
	"slot_melee": KEY_3, 
	"spawn_mannequin": KEY_M, 
	"scoreboard": KEY_TAB, 

	"toggle_left_hand": 0, 
}

const BIND_ORDER: = [
	["move_forward", "ВПЕРЁД"], 
	["move_back", "НАЗАД"], 
	["move_left", "ВЛЕВО"], 
	["move_right", "ВПРАВО"], 
	["jump", "ПРЫЖОК / БАННИХОП"], 
	["crouch", "ПРИСЕСТЬ"], 
	["reload", "ПЕРЕЗАРЯДКА"], 
	["inspect", "ОСМОТР ОРУЖИЯ"], 
	["slot_primary", "СЛОТ ОРУЖИЯ"], 
	["slot_secondary", "СЛОТ ПИСТОЛЕТ"], 
	["slot_melee", "СЛОТ НОЖ"], 
	["spawn_mannequin", "ЗАСПАВНИТЬ МАНЕКЕН"], 
	["scoreboard", "ТАБЛО СЕССИИ"], 
	["toggle_left_hand", "ЛЕВАЯ РУКА"], 
]

const CROSSHAIR_PRESETS: = [
	Color(0.32, 1.0, 0.48, 1.0), 
	Color(0.35, 0.9, 1.0, 1.0), 
	Color(1.0, 0.96, 0.9, 1.0), 
	Color(0.95, 0.58, 0.2, 1.0), 
	Color(1.0, 0.32, 0.34, 1.0), 
	Color(0.72, 0.48, 1.0, 1.0), 
	Color(0.1, 0.1, 0.1, 1.0), 
	Color(0.0, 0.0, 0.0, 1.0), 
]

const HUD_PRESETS: = [
	Color(0.886, 0.651, 0.239, 1.0), 
	Color(0.32, 1.0, 0.56, 1.0), 
	Color(0.38, 0.76, 1.0, 1.0), 
	Color(0.8, 0.45, 1.0, 1.0), 
	Color(1.0, 0.38, 0.34, 1.0), 
	Color(0.95, 0.96, 0.98, 1.0), 
]

const SKY_PRESETS: = [
	Color(0.33, 0.5, 0.68, 1.0), 
	Color(0.075, 0.105, 0.18, 1.0), 
	Color(0.66, 0.36, 0.42, 1.0), 
	Color(0.31, 0.47, 0.43, 1.0), 
	Color(0.78, 0.7, 0.52, 1.0), 
	Color(0.18, 0.185, 0.21, 1.0), 
]

const ARM_PRESETS: = [
	Color(0.175, 0.19, 0.215, 1.0), 
	Color(0.095, 0.1, 0.112, 1.0), 
	Color(0.36, 0.305, 0.22, 1.0), 
	Color(0.175, 0.255, 0.205, 1.0), 
	Color(0.31, 0.12, 0.12, 1.0), 
	Color(0.52, 0.54, 0.57, 1.0), 
]

const GLOVE_PRESETS: = [
	Color(0.3, 0.315, 0.335, 1.0), 
	Color(0.11, 0.112, 0.12, 1.0), 
	Color(0.44, 0.345, 0.235, 1.0), 
	Color(0.2, 0.3, 0.24, 1.0), 
	Color(0.36, 0.15, 0.14, 1.0), 
	Color(0.76, 0.77, 0.79, 1.0), 
]



const MANNEQUIN_PRESETS: = [
	Color(0.95, 0.45, 0.08, 1.0), 
	Color(0.94, 0.22, 0.24, 1.0), 
	Color(0.34, 0.86, 0.42, 1.0), 
	Color(0.3, 0.68, 1.0, 1.0), 
	Color(0.78, 0.42, 1.0, 1.0), 
	Color(0.96, 0.92, 0.86, 1.0), 
]



const VM_OFFSET_MIN: = -0.2
const VM_OFFSET_MAX: = 0.2
const VM_DEPTH_MIN: = -0.25
const VM_DEPTH_MAX: = 0.2
const VM_ROTATION_MIN: = -45.0
const VM_ROTATION_MAX: = 45.0
const VM_SCALE_MIN: = 0.7
const VM_SCALE_MAX: = 1.5
const VM_SWAY_MIN: = 0.0
const VM_SWAY_MAX: = 2.0
const DEFAULT_VM_SCALE: = 1.0
const DEFAULT_VM_SWAY: = 1.0

const DEFAULT_HUD_ACCENT: = Color(0.886, 0.651, 0.239, 1.0)
const DEFAULT_MANNEQUIN_COLOR: = Color(0.95, 0.45, 0.08, 1.0)
const DEFAULT_SKY_TOP: = Color(0.33, 0.5, 0.68, 1.0)
const DEFAULT_SKY_HORIZON: = Color(0.74, 0.82, 0.9, 1.0)
const DEFAULT_ARM_SLEEVE: = Color(0.175, 0.19, 0.215, 1.0)
const DEFAULT_ARM_GLOVE: = Color(0.3, 0.315, 0.335, 1.0)




const WORLD_TINT_PRESETS: = [
	Color(0.96, 0.74, 0.34, 1.0), 
	Color(0.52, 0.96, 0.78, 1.0), 
	Color(0.48, 0.74, 1.0, 1.0), 
	Color(0.74, 0.58, 1.0, 1.0), 
	Color(1.0, 0.55, 0.62, 1.0), 
	Color(0.92, 0.94, 0.9, 1.0), 
]
const DEFAULT_WORLD_TINT_COLOR: = Color(0.96, 0.74, 0.34, 1.0)




const WEAPON_TINT_PRESETS: = [
	Color(0.9, 0.7, 0.3, 1.0), 
	Color(0.88, 0.2, 0.24, 1.0), 
	Color(0.24, 0.62, 1.0, 1.0), 
	Color(0.28, 0.86, 0.48, 1.0), 
	Color(0.78, 0.38, 1.0, 1.0), 
	Color(0.93, 0.94, 0.96, 1.0), 
]
const KNIFE_TINT_PRESETS: = [
	Color(0.86, 0.18, 0.22, 1.0), 
	Color(0.9, 0.7, 0.3, 1.0), 
	Color(0.24, 0.62, 1.0, 1.0), 
	Color(0.28, 0.86, 0.48, 1.0), 
	Color(0.78, 0.38, 1.0, 1.0), 
	Color(0.93, 0.94, 0.96, 1.0), 
]
const DEFAULT_WEAPON_TINT: = Color(0.9, 0.7, 0.3, 1.0)
const DEFAULT_KNIFE_TINT: = Color(0.86, 0.18, 0.22, 1.0)

const AVATARS: = [
	"res://assets/avatars/avatar_01.svg", 
	"res://assets/avatars/avatar_02.svg", 
	"res://assets/avatars/avatar_03.svg", 
	"res://assets/avatars/avatar_04.svg", 
	"res://assets/avatars/avatar_05.svg", 
	"res://assets/avatars/avatar_06.svg", 
	"res://assets/avatars/avatar_07.svg", 
	"res://assets/avatars/avatar_08.svg", 
]



const STRETCH_MIN: = 0.0
const STRETCH_MAX: = 2.0
const STRETCH_DEFAULT: = 0.0

const MSAA_LABELS: = ["ВЫКЛ", "2× MSAA", "4× MSAA"]
const EFFECTS_LABELS: = ["НИЗКОЕ", "СРЕДНЕЕ", "ВЫСОКОЕ"]
const DISTANCE_LABELS: = ["120 М", "180 М", "240 М", "350 М"]
const DISTANCE_VALUES: = [120.0, 180.0, 240.0, 350.0]
const FPS_LABELS: = ["БЕЗ ЛИМИТА", "60 FPS", "90 FPS", "120 FPS", "144 FPS", "240 FPS"]
const FPS_VALUES: = [0, 60, 90, 120, 144, 240]




const ADAPTIVE_MIN_SCALE: = 0.7
const ADAPTIVE_STEP_DOWN: = 0.08
const ADAPTIVE_STEP_UP: = 0.05
const ADAPTIVE_INTERVAL: = 0.75
const ADAPTIVE_LOW_RATIO: = 0.9
const ADAPTIVE_HIGH_RATIO: = 0.97





const STREAM_INTERVAL: = 0.5
const STREAM_LOW_RATIO: = 0.94
const STREAM_HITCH_FACTOR: = 2.4
const STREAM_FPS_CAP: = 60
const BASE_PHYSICS_TICKS: = 120

var nickname: = "PLAYER"
var avatar_index: = 0


var country: = "RU"

var mouse_sensitivity: = 1.0


var gyro_enabled: = false
var gyro_sensitivity: = GYRO_SENS_DEFAULT
var master_volume: = 0.8
var mannequin_count: = 6

var mannequin_color: = DEFAULT_MANNEQUIN_COLOR
var mannequin_rainbow: = false
var fov: = 90.0

var session_timer: = true


var show_fps: = false
var show_input_overlay: = false

var map_id: = MAP_DEFAULT
var game_mode: = "dm"

var crosshair_color: = Color(0.32, 1.0, 0.48, 1.0)
var crosshair_gap: = 5.0
var crosshair_length: = 7.0
var crosshair_thickness: = 2.0
var crosshair_dot: = true
var crosshair_outline: = true
var crosshair_dynamic: = true

var scope_transparent: = false

var screen_stretch: = STRETCH_DEFAULT
var fullscreen: = true

var render_scale: = 1.0


var msaa_level: = 0
var effects_quality: = 2
var draw_distance: = 240.0
var fps_limit: = 0
var vsync: = true
var brightness: = 1.08
var fog_enabled: = true

var adaptive_resolution: = true


var stream_mode: = false



var tap_crouch_aim: = false

var hud_accent: = DEFAULT_HUD_ACCENT
var sky_top: = DEFAULT_SKY_TOP
var sky_horizon: = DEFAULT_SKY_HORIZON
var arm_sleeve: = DEFAULT_ARM_SLEEVE
var arm_glove: = DEFAULT_ARM_GLOVE


var arm_sharp_split: = false

var world_tint_enabled: = false
var world_tint_color: = DEFAULT_WORLD_TINT_COLOR

var weapon_tint_enabled: = false
var weapon_tint: = DEFAULT_WEAPON_TINT
var knife_tint_enabled: = false
var knife_tint: = DEFAULT_KNIFE_TINT



var vm_offset: = Vector3.ZERO
var vm_rotation: = Vector3.ZERO
var vm_scale: = DEFAULT_VM_SCALE

var vm_sway: = DEFAULT_VM_SWAY

var left_hand: = false

var weapon_id: = PRIMARY_ID
var weapon_skin: = PRIMARY_SKIN
var pistol_id: = PISTOL_ID
var pistol_skin: = PISTOL_SKIN
var knife_skin: = MELEE_SKIN

var owned_items: Array[String] = []
var owned_player_skins: Array[String] = [PlayerSkinData.DEFAULT_ID]
var player_skin: = PlayerSkinData.DEFAULT_ID
var keybinds: Dictionary = {}

var total_shots: = 0
var total_hits: = 0
var total_kills: = 0
var total_headshots: = 0
var best_speed: = 0.0

var coins: = 2500

signal coins_changed

func add_coins(delta: int) -> void :
	coins = maxi(coins + delta, 0)
	queue_save_settings()
	coins_changed.emit()


func spend_coins(cost: int) -> bool:
	if coins < cost:
		return false
	coins -= cost
	queue_save_settings()
	coins_changed.emit()
	return true


var rating_elo: = RATING_START
var rating_wins: = 0
var rating_losses: = 0
var rating_streak: = 0
var rating_best: = RATING_START
var rating_matches: = 0


var rating_best_streak: = 0
var rating_shots: = 0
var rating_hits: = 0
var rating_headshots: = 0
var rating_damage: = 0


var show_rating_widget: = false


var rating_widget_nickname: = true
var rating_widget_level: = true
var rating_widget_elo: = true
var rating_widget_form: = true
var rating_widget_record: = true


var rating_widget_style: = 0
var last_rating_delta: = 0

var recent_results: Array = []


var pending_leave_notice: = ""





var duel_rival_elo: = 0
var duel_rival_name: = ""


var _rival_last_sign: = 0

var _bot_names: = BotNames.new()


const MOBILE_WIDGETS: = ["stick", "fire", "jump", "reload", "melee", "aim", 
	"crouch", "inspect", "left_hand", "scoreboard", "spawn"]
const MOBILE_LAYOUT_DEFAULT: = {
	"stick": {"x": 0.15, "y": 0.74, "size": 1.0, "alpha": 1.0}, 
	"fire": {"x": 0.865, "y": 0.655, "size": 1.0, "alpha": 1.0}, 
	"jump": {"x": 0.735, "y": 0.775, "size": 0.82, "alpha": 1.0}, 
	"aim": {"x": 0.935, "y": 0.775, "size": 0.78, "alpha": 1.0}, 
	"reload": {"x": 0.955, "y": 0.645, "size": 0.68, "alpha": 1.0}, 
	"melee": {"x": 0.775, "y": 0.645, "size": 0.68, "alpha": 1.0}, 



	"crouch": {"x": 0.76, "y": 0.505, "size": 0.64, "alpha": 1.0}, 
	"inspect": {"x": 0.865, "y": 0.505, "size": 0.62, "alpha": 1.0}, 
	"left_hand": {"x": 0.655, "y": 0.505, "size": 0.56, "alpha": 1.0}, 
	"scoreboard": {"x": 0.965, "y": 0.495, "size": 0.56, "alpha": 1.0}, 


	"spawn": {"x": 0.085, "y": 0.49, "size": 0.58, "alpha": 1.0}, 
}
const MOBILE_PRESETS: = ["СТАНДАРТ", "ЛЕВША", "КОМПАКТ"]
const MOBILE_SIZE_MIN: = 0.6
const MOBILE_SIZE_MAX: = 1.7

const MOBILE_ALPHA_MIN: = 0.15
const MOBILE_ALPHA_MAX: = 1.0


const MOBILE_SLOT_COUNT: = 3

var mobile_layout: Dictionary = MOBILE_LAYOUT_DEFAULT.duplicate(true)
var mobile_stick_size: = 1.0
var mobile_button_size: = 1.0

var mobile_layout_slots: Array = []
var mobile_slot: = 0

var mobile_editor_open: = false



var safe_mode: = false



var _session_safe_only: = false

var last_session_crashed: = false




const HUD_WIDGETS: = ["session", "streamer", "killfeed", "killzone", 
	"weapons", "strafe", "fps", "input_overlay", "hint"]
const HUD_SCALE_MIN: = 0.35
const HUD_SCALE_MAX: = 2.5
var hud_layout: Dictionary = {}

var hud_editor_open: = false

var _save_pending: = false
var _save_timer: = 0.0
var _mobile_checked: = false
var _mobile_platform: = false



var _adaptive_scale: = 1.0
var _adaptive_time: = 0.0
var _adaptive_frames: = 0
var _adaptive_cooldown: = 0.0


var _adaptive_frame_max: = 0.0


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	_check_session_marker()
	load_settings()





	if last_session_crashed:
		_apply_safe_mode(false)
		_session_safe_only = true
	_mark_session_start()



	_apply_physics_rate()
	apply_keybinds()
	apply_volume()



	_update_process_state()
	call_deferred("apply_display")
	call_deferred("apply_graphics")


func _check_session_marker() -> void :
	last_session_crashed = FileAccess.file_exists(SESSION_MARKER)


func _mark_session_start() -> void :
	var file: = FileAccess.open(SESSION_MARKER, FileAccess.WRITE)
	if file != null:
		file.store_string("1")
		file.close()


func _clear_session_marker() -> void :
	var path: = ProjectSettings.globalize_path(SESSION_MARKER)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)





func _apply_safe_mode(persist: bool) -> void :
	safe_mode = true
	msaa_level = 0
	effects_quality = 0
	render_scale = 0.75
	adaptive_resolution = true
	fog_enabled = false
	draw_distance = minf(draw_distance, 180.0)
	stream_mode = false
	_adaptive_scale = render_scale
	_adaptive_time = 0.0
	_adaptive_frames = 0
	_adaptive_frame_max = 0.0
	_adaptive_cooldown = 0.0
	if persist:
		save_settings()


func set_safe_mode(value: bool) -> void :

	_session_safe_only = false
	if value:
		_apply_safe_mode(false)
	else:
		safe_mode = false



		render_scale = 1.0
		effects_quality = 2
		fog_enabled = true
		draw_distance = maxf(draw_distance, 240.0)
		_adaptive_scale = render_scale
	apply_graphics()
	save_settings()
	settings_changed.emit()




func _migrate_config() -> void :
	if FileAccess.file_exists(CONFIG_PATH):
		return
	var near_path: = "user://" + LEGACY_CONFIG_FILE
	if FileAccess.file_exists(near_path):
		_copy_config(near_path, ProjectSettings.globalize_path(CONFIG_PATH))
		return
	var user_dir: = OS.get_user_data_dir().get_base_dir().path_join(LEGACY_USER_DIR)
	var old_path: = user_dir.path_join(LEGACY_CONFIG_FILE)
	if FileAccess.file_exists(old_path):
		_copy_config(old_path, ProjectSettings.globalize_path(CONFIG_PATH))


func _copy_config(from_path: String, to_path: String) -> void :
	var source: = FileAccess.open(from_path, FileAccess.READ)
	if source == null:
		return
	var bytes: = source.get_buffer(source.get_length())
	source.close()
	var target: = FileAccess.open(to_path, FileAccess.WRITE)
	if target == null:
		return
	target.store_buffer(bytes)
	target.close()


func load_settings() -> void :
	_migrate_config()
	var config: = ConfigFile.new()
	var loaded: = config.load(CONFIG_PATH) == OK

	keybinds = DEFAULT_BINDS.duplicate()
	owned_items.clear()
	owned_player_skins.clear()

	if loaded:
		nickname = str(config.get_value("profile", "nickname", "PLAYER")).strip_edges().substr(0, 16)
		if nickname.is_empty():
			nickname = "PLAYER"
		avatar_index = clampi(int(config.get_value("profile", "avatar", 0)), 0, AVATARS.size() - 1)
		country = CountryData.code_at(CountryData.index_of(
			str(config.get_value("profile", "country", "RU"))))

		mouse_sensitivity = clampf(
			float(config.get_value("input", "sensitivity", 1.0)), SENS_MIN, SENS_MAX
		)
		fov = clampf(float(config.get_value("input", "fov", 90.0)), FOV_MIN, FOV_MAX)
		tap_crouch_aim = bool(config.get_value("input", "tap_crouch_aim", false))
		gyro_enabled = bool(config.get_value("input", "gyro_enabled", false))
		gyro_sensitivity = clampf(
			float(config.get_value("input", "gyro_sensitivity", GYRO_SENS_DEFAULT)), 
			GYRO_SENS_MIN, GYRO_SENS_MAX)
		master_volume = clampf(float(config.get_value("audio", "volume", 0.8)), 0.0, 1.0)
		mannequin_count = clampi(int(config.get_value("game", "mannequins", 6)), 
			MANNEQUIN_MIN, MANNEQUIN_MAX)
		mannequin_color = _read_color(config, "game", "mannequin_color", 
			DEFAULT_MANNEQUIN_COLOR)
		mannequin_rainbow = bool(config.get_value("game", "mannequin_rainbow", false))
		session_timer = bool(config.get_value("game", "session_timer", true))
		show_fps = bool(config.get_value("hud", "show_fps", false))
		show_input_overlay = bool(config.get_value("hud", "show_input_overlay", false))
		map_id = str(config.get_value("game", "map", MAP_DEFAULT))
		if not MapData.has_map(map_id):
			map_id = MAP_DEFAULT

		game_mode = str(config.get_value("game", "mode", "dm"))
		if game_mode != "tdm":
			game_mode = "dm"

		total_shots = int(config.get_value("stats", "shots", 0))
		coins = maxi(int(config.get_value("economy", "coins", 2500)), 0)
		total_hits = int(config.get_value("stats", "hits", 0))
		total_kills = int(config.get_value("stats", "kills", 0))
		total_headshots = int(config.get_value("stats", "headshots", 0))
		best_speed = float(config.get_value("stats", "best_speed", 0.0))

		rating_elo = clampi(int(config.get_value("rating", "elo", RATING_START)), 
			RATING_MIN, 99999)
		rating_wins = maxi(int(config.get_value("rating", "wins", 0)), 0)
		rating_losses = maxi(int(config.get_value("rating", "losses", 0)), 0)
		rating_streak = maxi(int(config.get_value("rating", "streak", 0)), 0)
		rating_best = clampi(int(config.get_value("rating", "best", rating_elo)), 
			RATING_START, 99999)
		rating_matches = maxi(int(config.get_value("rating", "matches", 
			rating_wins + rating_losses)), 0)
		rating_best_streak = maxi(int(config.get_value("rating", 
			"best_streak", rating_streak)), 0)
		rating_shots = maxi(int(config.get_value("rating", "shots", 0)), 0)
		rating_hits = clampi(int(config.get_value("rating", "hits", 0)), 0, 
			rating_shots)
		rating_headshots = clampi(int(config.get_value("rating", "headshots", 0)), 
			0, rating_hits)
		rating_damage = maxi(int(config.get_value("rating", "damage", 0)), 0)
		show_rating_widget = bool(config.get_value("rating", 
			"widget_opt_in", config.get_value("rating", 
				"streamer_widget_opt_in", false)))
		rating_widget_nickname = bool(config.get_value("rating", 
			"widget_nickname", true))
		rating_widget_level = bool(config.get_value("rating", 
			"widget_level", true))
		rating_widget_elo = bool(config.get_value("rating", 
			"widget_elo", true))
		rating_widget_form = bool(config.get_value("rating", 
			"widget_form", true))
		rating_widget_record = bool(config.get_value("rating", 
			"widget_record", true))
		rating_widget_style = clampi(int(config.get_value("rating", 
			"widget_style", 0)), 0, RATING_WIDGET_STYLES.size() - 1)
		last_rating_delta = int(config.get_value("rating", "last_delta", 0))
		recent_results = _sanitize_recent_results(
			config.get_value("rating", "recent", []))
		pending_leave_notice = str(config.get_value("rating", "leave_notice", ""))

		_read_crosshair(config)

		if config.has_section_key("display", "screen_stretch"):
			screen_stretch = clampf(float(config.get_value("display", "screen_stretch", 
				STRETCH_DEFAULT)), STRETCH_MIN, STRETCH_MAX)
		else:
			screen_stretch = 1.0 if int(config.get_value("display", "aspect_mode", 0)) == 2 else 0.0
		fullscreen = bool(config.get_value("display", "fullscreen", true))



		if not config.has_section_key("display", "tuning_version"):
			fullscreen = true
		if is_mobile():
			fullscreen = true

		render_scale = clampf(float(config.get_value("graphics", "render_scale", 1.0)), 
			RENDER_SCALE_MIN, 1.0)
		msaa_level = clampi(int(config.get_value("graphics", "msaa", 0)), 0, 2)


		if not config.has_section_key("graphics", "tuning_version") and msaa_level == 1:
			msaa_level = 0


		var default_effects: = 1 if is_mobile() else 2
		effects_quality = clampi(
			int(config.get_value("graphics", "effects", default_effects)), 0, 2)
		draw_distance = clampf(float(config.get_value("graphics", "draw_distance", 240.0)), 
			100.0, 500.0)
		fps_limit = clampi(int(config.get_value("graphics", "fps_limit", 0)), 0, 360)
		vsync = bool(config.get_value("graphics", "vsync", true))
		brightness = clampf(float(config.get_value("graphics", "brightness", 1.08)), 
			BRIGHTNESS_MIN, BRIGHTNESS_MAX)
		fog_enabled = bool(config.get_value("graphics", "fog", true))
		adaptive_resolution = bool(config.get_value("graphics", "adaptive", true))
		stream_mode = bool(config.get_value("graphics", "stream_mode", false))
		safe_mode = bool(config.get_value("graphics", "safe_mode", false))
		_adaptive_scale = render_scale




		if safe_mode and not bool(config.get_value("graphics", "safe_restored", false)):
			if render_scale <= 0.751 and effects_quality == 0 and not fog_enabled:
				render_scale = 1.0
				effects_quality = 2
				fog_enabled = true
				draw_distance = maxf(draw_distance, 240.0)
				_adaptive_scale = render_scale
				safe_mode = false
				queue_save_settings()

		_read_colors(config)

		_load_viewmodel(config)

		weapon_id = str(config.get_value("loadout", "weapon", PRIMARY_ID))
		weapon_skin = str(config.get_value("loadout", "skin", PRIMARY_SKIN))
		pistol_id = str(config.get_value("loadout", "pistol", PISTOL_ID))
		pistol_skin = str(config.get_value("loadout", "pistol_skin", PISTOL_SKIN))
		knife_skin = str(config.get_value("loadout", "knife_skin", MELEE_SKIN))

		var owned_value: Variant = config.get_value("inventory", "owned", PackedStringArray())
		if owned_value is PackedStringArray:
			for entry in owned_value:
				owned_items.append(str(entry))
		elif owned_value is Array:
			for entry in owned_value:
				owned_items.append(str(entry))

		var skins_value: Variant = config.get_value("skins", "owned", PackedStringArray())
		if skins_value is PackedStringArray:
			for entry in skins_value:
				owned_player_skins.append(str(entry))
		elif skins_value is Array:
			for entry in skins_value:
				owned_player_skins.append(str(entry))
		player_skin = str(config.get_value("skins", "equipped", PlayerSkinData.DEFAULT_ID))

		var binds_value: Variant = config.get_value("keys", "binds", {})
		if binds_value is Dictionary:
			for action in binds_value:
				var action_name: = str(action)
				if keybinds.has(action_name):
					var code: = int(binds_value[action])

					if code != 0:
						keybinds[action_name] = code

	for entry in DEFAULT_OWNED:
		var key: = str(entry)
		if not owned_items.has(key):
			owned_items.append(key)

	# Ножи из LOCKED_START_ITEMS больше не выдаются бесплатно — только кейсы/рынок.
	for legacy_key in LOCKED_START_ITEMS:
		owned_items.erase(str(legacy_key))

	if not owned_player_skins.has(PlayerSkinData.DEFAULT_ID):
		owned_player_skins.append(PlayerSkinData.DEFAULT_ID)
	_validate_player_skin()

	_validate_loadout()
	apply_volume()
	_load_mobile(config)
	_load_hud_layout(config)




func queue_save_settings(delay: = 0.4) -> void :
	_save_pending = true
	_save_timer = maxf(_save_timer, delay)
	_update_process_state()




func _update_process_state() -> void :
	var wanted: = _save_pending or adaptive_resolution or stream_mode
	if is_processing() != wanted:
		set_process(wanted)


func _process(delta: float) -> void :
	if _save_pending:
		_save_timer -= delta
		if _save_timer <= 0.0:
			save_settings()
	_update_adaptive_resolution(delta)
	_update_process_state()





func _update_adaptive_resolution(delta: float) -> void :
	if not (adaptive_resolution or stream_mode):
		return
	var interval: = STREAM_INTERVAL if stream_mode else ADAPTIVE_INTERVAL
	_adaptive_time += delta
	_adaptive_frames += 1
	_adaptive_frame_max = maxf(_adaptive_frame_max, delta)
	if _adaptive_cooldown > 0.0:
		_adaptive_cooldown = maxf(0.0, _adaptive_cooldown - delta)
	if _adaptive_time < interval:
		return
	var frames: = _adaptive_frames
	var fps: = float(frames) / maxf(_adaptive_time, 0.001)
	var worst: = _adaptive_frame_max
	_adaptive_time = 0.0
	_adaptive_frames = 0
	_adaptive_frame_max = 0.0


	if get_tree().paused or get_tree().get_first_node_in_group("player") == null:
		return
	var target: = _adaptive_target_fps()
	var low_ratio: = STREAM_LOW_RATIO if stream_mode else ADAPTIVE_LOW_RATIO
	var next: = _adaptive_scale



	var hitch: = stream_mode and frames >= 20\
	and worst > STREAM_HITCH_FACTOR / maxf(target, 1.0)
	if fps < target * low_ratio or (hitch and _adaptive_cooldown <= 0.0):
		next = maxf(ADAPTIVE_MIN_SCALE, _adaptive_scale - ADAPTIVE_STEP_DOWN)

		_adaptive_cooldown = 1.5 if stream_mode else 3.0
	elif fps >= target * ADAPTIVE_HIGH_RATIO and _adaptive_cooldown <= 0.0:
		next = minf(render_scale, _adaptive_scale + ADAPTIVE_STEP_UP)


		_adaptive_cooldown = 1.0 if stream_mode else 0.0
	if absf(next - _adaptive_scale) < 0.001:
		return
	_adaptive_scale = next
	_apply_render_scale()



func _adaptive_target_fps() -> float:
	if fps_limit > 0:
		return minf(float(fps_limit), 60.0)
	return 60.0


func _apply_render_scale() -> void :
	var viewport: = get_viewport()
	if viewport == null:
		return
	var applied: = get_effective_render_scale()
	if is_equal_approx(viewport.scaling_3d_scale, applied):
		return
	viewport.scaling_3d_scale = applied
	render_scale_changed.emit(applied)



func get_effective_render_scale() -> float:
	return _adaptive_scale if (adaptive_resolution or stream_mode) else render_scale


func _exit_tree() -> void :

	if _save_pending:
		save_settings()

	_clear_session_marker()


func _notification(what: int) -> void :



	if what == NOTIFICATION_APPLICATION_FOCUS_OUT\
	or what == NOTIFICATION_APPLICATION_PAUSED\
	or what == NOTIFICATION_WM_CLOSE_REQUEST:



		save_settings()



		_clear_session_marker()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN\
	or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_mark_session_start()












func is_mobile_platform() -> bool:
	if OS.has_feature("mobile") or OS.get_name() == "Android":
		return true
	if OS.get_name() == "iOS":
		return true
	return OS.get_cmdline_user_args().has("--mobile-preview")





func is_touch_device() -> bool:
	var os_name: = OS.get_name()
	return OS.has_feature("mobile") or os_name == "Android" or os_name == "iOS"


func is_mobile() -> bool:
	if not _mobile_checked:
		_mobile_checked = true
		_mobile_platform = _detect_mobile()
	return _mobile_platform


func _detect_mobile() -> bool:
	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		return true
	var os_name: = OS.get_name()
	if os_name == "Android" or os_name == "iOS":
		return true
	return OS.get_cmdline_user_args().has("--mobile-preview")


func _load_mobile(config: ConfigFile) -> void :
	mobile_stick_size = clampf(float(config.get_value("mobile", "stick_size", 1.0)), 
		MOBILE_SIZE_MIN, MOBILE_SIZE_MAX)
	mobile_button_size = clampf(float(config.get_value("mobile", "button_size", 1.0)), 
		MOBILE_SIZE_MIN, MOBILE_SIZE_MAX)
	mobile_slot = clampi(int(config.get_value("mobile", "slot", 0)), 
		0, MOBILE_SLOT_COUNT - 1)
	mobile_layout_slots = _sanitize_mobile_slots(
		config.get_value("mobile", "layout_slots", []))
	if mobile_layout_slots.is_empty():


		var legacy: = _sanitize_mobile_layout(
			config.get_value("mobile", "layout", {}))
		mobile_layout_slots = [
			{"layout": legacy, "stick": mobile_stick_size, 
				"button": mobile_button_size}, 
			_default_mobile_slot(1), 
			_default_mobile_slot(2), 
		]
	while mobile_layout_slots.size() < MOBILE_SLOT_COUNT:
		mobile_layout_slots.append(_default_mobile_slot(mobile_layout_slots.size()))
	_migrate_mobile_scale()
	mobile_slot = clampi(mobile_slot, 0, mobile_layout_slots.size() - 1)
	_apply_active_mobile_slot()





func _migrate_mobile_scale() -> void :
	for slot in mobile_layout_slots:
		if not (slot is Dictionary):
			continue
		var values: Dictionary = slot
		var stick: = clampf(float(values.get("stick", 1.0)), 
			MOBILE_SIZE_MIN, MOBILE_SIZE_MAX)
		var button: = clampf(float(values.get("button", 1.0)), 
			MOBILE_SIZE_MIN, MOBILE_SIZE_MAX)
		if absf(stick - 1.0) < 0.001 and absf(button - 1.0) < 0.001:
			continue
		var layout: Dictionary = values.get("layout", {})
		for key in MOBILE_WIDGETS:
			if not layout.has(key):
				continue
			var entry: Dictionary = layout[key]
			var factor: = stick if key == "stick" else button
			entry["size"] = clampf(float(entry.get("size", 1.0)) * factor, 
				MOBILE_SIZE_MIN, MOBILE_SIZE_MAX)
		values["stick"] = 1.0
		values["button"] = 1.0




func _sanitize_mobile_slots(raw: Variant) -> Array:
	var slots: Array = []
	if raw is Array:
		for entry in raw:
			var values: Variant = entry
			if values is Dictionary and (values as Dictionary).get("layout") is Dictionary:
				var source: Dictionary = values
				slots.append({
					"layout": _sanitize_mobile_layout(source.get("layout", {})), 
					"stick": clampf(float(source.get("stick", 1.0)), 
						MOBILE_SIZE_MIN, MOBILE_SIZE_MAX), 
					"button": clampf(float(source.get("button", 1.0)), 
						MOBILE_SIZE_MIN, MOBILE_SIZE_MAX), 
				})
			else:
				slots.append(_default_mobile_slot(slots.size()))
			if slots.size() >= MOBILE_SLOT_COUNT:
				break
	return slots


func _default_mobile_slot(index: int) -> Dictionary:
	return {
		"layout": _preset_layout(index), 
		"stick": 1.0, 
		"button": 1.0, 
	}




func _preset_layout(index: int) -> Dictionary:
	var layout: Dictionary = MOBILE_LAYOUT_DEFAULT.duplicate(true)
	match clampi(index, 0, MOBILE_PRESETS.size() - 1):
		1:

			for key in MOBILE_WIDGETS:
				layout[key]["x"] = 1.0 - float(layout[key]["x"])
		2:

			for key in MOBILE_WIDGETS:
				layout[key]["size"] = float(layout[key]["size"]) * 0.82
				layout[key]["y"] = clampf(float(layout[key]["y"]) * 1.02, 0.05, 0.95)
	return _sanitize_mobile_layout(layout)


func _apply_active_mobile_slot() -> void :
	if mobile_layout_slots.is_empty():
		mobile_layout_slots = [
			_default_mobile_slot(0), _default_mobile_slot(1), 
			_default_mobile_slot(2), 
		]
	mobile_slot = clampi(mobile_slot, 0, mobile_layout_slots.size() - 1)
	var slot: Dictionary = mobile_layout_slots[mobile_slot]
	mobile_layout = (slot["layout"] as Dictionary).duplicate(true)
	mobile_stick_size = clampf(float(slot.get("stick", 1.0)), 
		MOBILE_SIZE_MIN, MOBILE_SIZE_MAX)
	mobile_button_size = clampf(float(slot.get("button", 1.0)), 
		MOBILE_SIZE_MIN, MOBILE_SIZE_MAX)


func _store_active_mobile_slot() -> void :
	while mobile_layout_slots.size() < MOBILE_SLOT_COUNT:
		mobile_layout_slots.append(_default_mobile_slot(mobile_layout_slots.size()))
	if mobile_layout_slots.is_empty():
		return
	mobile_slot = clampi(mobile_slot, 0, mobile_layout_slots.size() - 1)
	mobile_layout_slots[mobile_slot] = {
		"layout": _sanitize_mobile_layout(mobile_layout), 
		"stick": clampf(mobile_stick_size, MOBILE_SIZE_MIN, MOBILE_SIZE_MAX), 
		"button": clampf(mobile_button_size, MOBILE_SIZE_MIN, MOBILE_SIZE_MAX), 
	}




func get_mobile_slots_copy() -> Array:
	_store_active_mobile_slot()
	return mobile_layout_slots.duplicate(true)


func select_mobile_slot(index: int) -> void :
	index = clampi(index, 0, MOBILE_SLOT_COUNT - 1)
	if index == mobile_slot:
		return
	_store_active_mobile_slot()
	mobile_slot = index
	_apply_active_mobile_slot()
	save_settings()
	mobile_layout_changed.emit()




func set_mobile_slots(slots: Array, active: int) -> void :
	var clean: = _sanitize_mobile_slots(slots)
	while clean.size() < MOBILE_SLOT_COUNT:
		clean.append(_default_mobile_slot(clean.size()))
	mobile_layout_slots = clean
	mobile_slot = clampi(active, 0, mobile_layout_slots.size() - 1)
	_apply_active_mobile_slot()
	save_settings()
	mobile_layout_changed.emit()



func _sanitize_mobile_layout(raw: Variant) -> Dictionary:
	var layout: Dictionary = MOBILE_LAYOUT_DEFAULT.duplicate(true)
	if not (raw is Dictionary):
		return layout
	var source: Dictionary = raw
	for key in MOBILE_WIDGETS:
		if not source.has(key):
			continue
		var entry: Variant = source[key]
		if not (entry is Dictionary):
			continue
		var values: Dictionary = entry
		var target: Dictionary = layout[key]
		target["x"] = clampf(float(values.get("x", target["x"])), 0.02, 0.98)
		target["y"] = clampf(float(values.get("y", target["y"])), 0.05, 0.95)
		target["size"] = clampf(float(values.get("size", target["size"])), 
			MOBILE_SIZE_MIN, MOBILE_SIZE_MAX)
		target["alpha"] = clampf(float(values.get("alpha", target.get("alpha", 1.0))), 
			MOBILE_ALPHA_MIN, MOBILE_ALPHA_MAX)
	return layout


func mobile_entry(key: String) -> Dictionary:
	var entry: Variant = mobile_layout.get(key)
	if entry is Dictionary:
		return entry
	return (MOBILE_LAYOUT_DEFAULT[key] as Dictionary).duplicate()




func mobile_widget_alpha(key: String) -> float:
	return clampf(float(mobile_entry(key).get("alpha", 1.0)), 
		MOBILE_ALPHA_MIN, MOBILE_ALPHA_MAX)


func mobile_widget_rect(key: String, viewport_size: Vector2, base_size: float) -> Rect2:


	var entry: = mobile_entry(key)
	var factor: = mobile_stick_size if key == "stick" else mobile_button_size
	var scale: = minf(viewport_size.x, viewport_size.y) / 720.0
	var size: = base_size * float(entry.get("size", 1.0)) * factor * scale
	var center: = Vector2(float(entry.get("x", 0.5)) * viewport_size.x, 
		float(entry.get("y", 0.5)) * viewport_size.y)
	return Rect2(center - Vector2(size, size) * 0.5, Vector2(size, size))


func set_mobile_layout(layout: Dictionary) -> void :
	mobile_layout = _sanitize_mobile_layout(layout)
	_store_active_mobile_slot()
	save_settings()
	mobile_layout_changed.emit()


func set_mobile_preset(index: int) -> void :
	set_mobile_layout(_preset_layout(index))




func make_mobile_preset(index: int) -> Dictionary:
	return _preset_layout(index)


func set_mobile_stick_size(value: float) -> void :
	mobile_stick_size = clampf(value, MOBILE_SIZE_MIN, MOBILE_SIZE_MAX)
	_store_active_mobile_slot()
	queue_save_settings()
	mobile_layout_changed.emit()


func set_mobile_button_size(value: float) -> void :
	mobile_button_size = clampf(value, MOBILE_SIZE_MIN, MOBILE_SIZE_MAX)
	_store_active_mobile_slot()
	queue_save_settings()
	mobile_layout_changed.emit()


func reset_mobile_layout() -> void :
	mobile_stick_size = 1.0
	mobile_button_size = 1.0
	set_mobile_layout(MOBILE_LAYOUT_DEFAULT)




func _load_hud_layout(config: ConfigFile) -> void :
	hud_layout = _sanitize_hud_layout(config.get_value("hud", "layout", {}))


func _sanitize_hud_layout(raw: Variant) -> Dictionary:
	var layout: Dictionary = {}
	if not (raw is Dictionary):
		return layout
	var source: Dictionary = raw
	for key in HUD_WIDGETS:
		var value: Variant = source.get(key)
		if not (value is Dictionary):
			continue
		var entry: Dictionary = value
		layout[key] = {
			"x": clampf(float(entry.get("x", 0.5)), 0.0, 1.0), 
			"y": clampf(float(entry.get("y", 0.5)), 0.0, 1.0), 
			"scale": clampf(float(entry.get("scale", 1.0)), 
				HUD_SCALE_MIN, HUD_SCALE_MAX), 
		}
	return layout


func set_hud_layout(layout: Dictionary) -> void :
	hud_layout = _sanitize_hud_layout(layout)
	save_settings()
	hud_layout_changed.emit()


func reset_hud_layout() -> void :
	hud_layout = {}
	save_settings()
	hud_layout_changed.emit()


func save_settings() -> void :
	_save_pending = false
	_save_timer = 0.0
	_make_config().save(CONFIG_PATH)
	_update_process_state()




func _make_config() -> ConfigFile:
	_store_active_mobile_slot()
	var config: = ConfigFile.new()
	config.set_value("profile", "nickname", nickname)
	config.set_value("profile", "avatar", avatar_index)
	config.set_value("profile", "country", country)
	config.set_value("input", "sensitivity", mouse_sensitivity)
	config.set_value("input", "fov", fov)
	config.set_value("input", "tap_crouch_aim", tap_crouch_aim)
	config.set_value("input", "gyro_enabled", gyro_enabled)
	config.set_value("input", "gyro_sensitivity", gyro_sensitivity)
	config.set_value("audio", "volume", master_volume)
	config.set_value("game", "mannequins", mannequin_count)
	config.set_value("game", "mannequin_color", mannequin_color)
	config.set_value("game", "mannequin_rainbow", mannequin_rainbow)
	config.set_value("game", "session_timer", session_timer)
	config.set_value("hud", "show_fps", show_fps)
	config.set_value("hud", "show_input_overlay", show_input_overlay)
	config.set_value("game", "map", map_id)
	config.set_value("game", "mode", game_mode)
	config.set_value("stats", "shots", total_shots)
	config.set_value("stats", "hits", total_hits)
	config.set_value("stats", "kills", total_kills)
	config.set_value("stats", "headshots", total_headshots)
	config.set_value("stats", "best_speed", best_speed)
	config.set_value("rating", "elo", rating_elo)
	config.set_value("rating", "wins", rating_wins)
	config.set_value("rating", "losses", rating_losses)
	config.set_value("rating", "streak", rating_streak)
	config.set_value("rating", "best", rating_best)
	config.set_value("rating", "matches", rating_matches)
	config.set_value("rating", "best_streak", rating_best_streak)
	config.set_value("rating", "shots", rating_shots)
	config.set_value("rating", "hits", rating_hits)
	config.set_value("rating", "headshots", rating_headshots)
	config.set_value("rating", "damage", rating_damage)
	config.set_value("rating", "widget_opt_in", show_rating_widget)
	config.set_value("rating", "widget_nickname", rating_widget_nickname)
	config.set_value("rating", "widget_level", rating_widget_level)
	config.set_value("rating", "widget_elo", rating_widget_elo)
	config.set_value("rating", "widget_form", rating_widget_form)
	config.set_value("rating", "widget_record", rating_widget_record)
	config.set_value("rating", "widget_style", rating_widget_style)
	config.set_value("rating", "last_delta", last_rating_delta)
	config.set_value("rating", "recent", recent_results)
	config.set_value("rating", "leave_notice", pending_leave_notice)
	config.set_value("crosshair", "color", crosshair_color)
	config.set_value("crosshair", "gap", crosshair_gap)
	config.set_value("crosshair", "length", crosshair_length)
	config.set_value("crosshair", "thickness", crosshair_thickness)
	config.set_value("crosshair", "dot", crosshair_dot)
	config.set_value("crosshair", "outline", crosshair_outline)
	config.set_value("crosshair", "dynamic", crosshair_dynamic)
	config.set_value("crosshair", "scope_transparent", scope_transparent)
	config.set_value("display", "screen_stretch", screen_stretch)
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("display", "tuning_version", 1)
	config.set_value("graphics", "render_scale", render_scale)
	config.set_value("graphics", "msaa", msaa_level)
	config.set_value("graphics", "tuning_version", 2)
	config.set_value("graphics", "effects", effects_quality)
	config.set_value("graphics", "draw_distance", draw_distance)
	config.set_value("graphics", "fps_limit", fps_limit)
	config.set_value("graphics", "vsync", vsync)
	config.set_value("graphics", "brightness", brightness)
	config.set_value("graphics", "fog", fog_enabled)
	config.set_value("graphics", "adaptive", adaptive_resolution)
	config.set_value("graphics", "stream_mode", stream_mode)
	config.set_value("graphics", "safe_mode", safe_mode)




	config.set_value("graphics", "safe_restored", not _session_safe_only)
	config.set_value("custom", "hud_accent", hud_accent)
	config.set_value("custom", "sky_top", sky_top)
	config.set_value("custom", "sky_horizon", sky_horizon)
	config.set_value("custom", "arm_sleeve", arm_sleeve)
	config.set_value("custom", "arm_glove", arm_glove)
	config.set_value("custom", "arm_sharp_split", arm_sharp_split)
	config.set_value("custom", "world_tint_enabled", world_tint_enabled)
	config.set_value("custom", "world_tint_color", world_tint_color)
	config.set_value("custom", "weapon_tint_enabled", weapon_tint_enabled)
	config.set_value("custom", "weapon_tint", weapon_tint)
	config.set_value("custom", "knife_tint_enabled", knife_tint_enabled)
	config.set_value("custom", "knife_tint", knife_tint)
	config.set_value("viewmodel", "offset", vm_offset)
	config.set_value("viewmodel", "rotation", vm_rotation)
	config.set_value("viewmodel", "scale", vm_scale)
	config.set_value("viewmodel", "sway", vm_sway)
	config.set_value("viewmodel", "left_hand", left_hand)
	config.set_value("loadout", "weapon", weapon_id)
	config.set_value("loadout", "skin", weapon_skin)
	config.set_value("loadout", "pistol", pistol_id)
	config.set_value("loadout", "pistol_skin", pistol_skin)
	config.set_value("loadout", "knife_skin", knife_skin)
	config.set_value("inventory", "owned", PackedStringArray(owned_items))
	config.set_value("skins", "owned", PackedStringArray(owned_player_skins))
	config.set_value("skins", "equipped", player_skin)
	config.set_value("economy", "coins", coins)
	config.set_value("keys", "binds", keybinds)
	config.set_value("mobile", "layout_slots", mobile_layout_slots)
	config.set_value("mobile", "slot", mobile_slot)


	config.set_value("mobile", "layout", mobile_layout)
	config.set_value("mobile", "stick_size", mobile_stick_size)
	config.set_value("mobile", "button_size", mobile_button_size)
	config.set_value("hud", "layout", hud_layout)
	return config









func get_crosshair_code() -> String:
	var flags: = (1 if crosshair_dot else 0)\
	| (2 if crosshair_outline else 0)\
	| (4 if crosshair_dynamic else 0)\
	| (8 if scope_transparent else 0)
	var payload: = "%s|%s|%s|%s|%d" % [
		_code_color(crosshair_color), 
		_code_num(crosshair_gap), 
		_code_num(crosshair_length), 
		_code_num(crosshair_thickness), 
		flags, 
	]
	return ConfigCode.encode(ConfigCode.KIND_CROSSHAIR, payload)


func apply_crosshair_code(code: String) -> bool:
	var decoded: = ConfigCode.decode(code, ConfigCode.KIND_CROSSHAIR)
	if not decoded["ok"]:
		return false
	if int(decoded["version"]) >= ConfigCode.SHORT_VERSION:
		if not _apply_crosshair_payload(str(decoded["text"])):
			return false
	else:
		var config: = ConfigFile.new()
		if config.parse(decoded["text"]) != OK:
			return false
		_read_crosshair(config)
	save_settings()
	settings_changed.emit()
	return true


func _apply_crosshair_payload(text: String) -> bool:
	var parts: = text.split("|", true)
	if parts.size() < 5 or not parts[4].is_valid_int():
		return false
	var color: = _code_parse_color(parts[0])
	if not _code_valid_color(color):
		return false
	var gap: = _code_parse_num(parts[1])
	var length: = _code_parse_num(parts[2])
	var thickness: = _code_parse_num(parts[3])
	if is_nan(gap) or is_nan(length) or is_nan(thickness):
		return false
	var flags: = int(parts[4])
	crosshair_color = color
	crosshair_gap = clampf(gap, 0.0, 18.0)
	crosshair_length = clampf(length, 0.0, 18.0)
	crosshair_thickness = clampf(thickness, 1.0, 6.0)
	crosshair_dot = (flags & 1) != 0
	crosshair_outline = (flags & 2) != 0
	crosshair_dynamic = (flags & 4) != 0
	scope_transparent = (flags & 8) != 0
	return true


func get_colors_code() -> String:
	var payload: = "|".join([
		_code_color(hud_accent), 
		_code_color(sky_top), 
		_code_color(sky_horizon), 
		_code_color(arm_sleeve), 
		_code_color(arm_glove), 
		_code_color(world_tint_color), 
	])
	return ConfigCode.encode(ConfigCode.KIND_COLORS, payload)


func apply_colors_code(code: String) -> bool:
	var decoded: = ConfigCode.decode(code, ConfigCode.KIND_COLORS)
	if not decoded["ok"]:
		return false
	if int(decoded["version"]) >= ConfigCode.SHORT_VERSION:
		if not _apply_colors_payload(str(decoded["text"])):
			return false
	else:
		var config: = ConfigFile.new()
		if config.parse(decoded["text"]) != OK:
			return false
		_read_colors(config)
	save_settings()
	settings_changed.emit()
	return true


func _apply_colors_payload(text: String) -> bool:
	var parts: = text.split("|", true)
	if parts.size() < 5:
		return false
	var colors: Array[Color] = []
	for part in parts:
		var color: = _code_parse_color(part)
		if not _code_valid_color(color):
			return false
		colors.append(color)
	hud_accent = colors[0]
	sky_top = colors[1]
	sky_horizon = colors[2]
	arm_sleeve = colors[3]
	arm_glove = colors[4]

	if colors.size() >= 6:
		world_tint_color = colors[5]
	return true


func get_hands_code() -> String:
	var payload: = "%s|%s|%s|%s|%d" % [
		_code_vec3(vm_offset), 
		_code_vec3(vm_rotation), 
		_code_num(vm_scale), 
		_code_num(vm_sway), 
		int(left_hand), 
	]
	return ConfigCode.encode(ConfigCode.KIND_HANDS, payload)


func apply_hands_code(code: String) -> bool:
	var decoded: = ConfigCode.decode(code, ConfigCode.KIND_HANDS)
	if not decoded["ok"]:
		return false
	if int(decoded["version"]) >= ConfigCode.SHORT_VERSION:
		if not _apply_hands_payload(str(decoded["text"])):
			return false
	else:
		var config: = ConfigFile.new()
		if config.parse(decoded["text"]) != OK:
			return false
		_load_viewmodel(config)
	save_settings()
	settings_changed.emit()
	return true


func _apply_hands_payload(text: String) -> bool:
	var parts: = text.split("|", true)
	if parts.size() < 5 or not parts[4].is_valid_int():
		return false
	var offset: = _code_parse_vec3(parts[0])
	var rotation: = _code_parse_vec3(parts[1])
	var scale: = _code_parse_num(parts[2])
	var sway: = _code_parse_num(parts[3])
	if is_nan(offset.x) or is_nan(rotation.x)\
	or is_nan(scale) or is_nan(sway):
		return false
	vm_offset = Vector3(
		clampf(offset.x, VM_OFFSET_MIN, VM_OFFSET_MAX), 
		clampf(offset.y, VM_OFFSET_MIN, VM_OFFSET_MAX), 
		clampf(offset.z, VM_DEPTH_MIN, VM_DEPTH_MAX))
	vm_rotation = Vector3(
		clampf(rotation.x, VM_ROTATION_MIN, VM_ROTATION_MAX), 
		clampf(rotation.y, VM_ROTATION_MIN, VM_ROTATION_MAX), 
		clampf(rotation.z, VM_ROTATION_MIN, VM_ROTATION_MAX))
	vm_scale = clampf(scale, VM_SCALE_MIN, VM_SCALE_MAX)
	vm_sway = clampf(sway, VM_SWAY_MIN, VM_SWAY_MAX)
	left_hand = int(parts[4]) != 0
	return true


func get_mobile_code() -> String:
	_store_active_mobile_slot()
	var parts: Array[String] = [str(mobile_slot)]
	for slot in mobile_layout_slots:
		var layout: Dictionary = slot.get("layout", {})
		var widgets: Array[String] = []
		for key in MOBILE_WIDGETS:
			var entry: Dictionary = layout.get(key, MOBILE_LAYOUT_DEFAULT[key])
			widgets.append("%s,%s,%s,%s" % [
				_code_num(float(entry.get("x", 0.5))), 
				_code_num(float(entry.get("y", 0.5))), 
				_code_num(float(entry.get("size", 1.0))), 
				_code_num(float(entry.get("alpha", 1.0))), 
			])
		widgets.append("%s,%s" % [
			_code_num(float(slot.get("stick", 1.0))), 
			_code_num(float(slot.get("button", 1.0))), 
		])
		parts.append(";".join(widgets))
	return ConfigCode.encode(ConfigCode.KIND_UI, "|".join(parts))


func apply_mobile_code(code: String) -> bool:
	var decoded: = ConfigCode.decode(code, ConfigCode.KIND_UI)
	if not decoded["ok"]:
		return false
	if int(decoded["version"]) >= ConfigCode.SHORT_VERSION:
		return _apply_mobile_payload(str(decoded["text"]))
	var config: = ConfigFile.new()
	if config.parse(decoded["text"]) != OK:
		return false
	_load_mobile(config)
	save_settings()
	mobile_layout_changed.emit()
	return true


func _apply_mobile_payload(text: String) -> bool:
	var parts: = text.split("|", true)
	if parts.size() != MOBILE_SLOT_COUNT + 1 or not parts[0].is_valid_int():
		return false
	var slots: Array = []
	for index in range(1, parts.size()):
		var entries: = parts[index].split(";", true)
		if entries.size() != MOBILE_WIDGETS.size() + 1:
			return false
		var layout: = {}
		for i in MOBILE_WIDGETS.size():
			var values: = _code_parse_floats(entries[i], 4)
			if values.is_empty():
				return false
			layout[MOBILE_WIDGETS[i]] = {
				"x": values[0], 
				"y": values[1], 
				"size": values[2], 
				"alpha": values[3], 
			}
		var legacy: = _code_parse_floats(entries[MOBILE_WIDGETS.size()], 2)
		if legacy.is_empty():
			return false
		slots.append({
			"layout": layout, 
			"stick": legacy[0], 
			"button": legacy[1], 
		})
	set_mobile_slots(slots, int(parts[0]))
	return true





func _code_color(color: Color) -> String:
	return "%s,%s,%s,%s" % [
		_code_float32_num(color.r), _code_float32_num(color.g), 
		_code_float32_num(color.b), _code_float32_num(color.a), 
	]


func _code_vec3(value: Vector3) -> String:
	return "%s,%s,%s" % [
		_code_float32_num(value.x), _code_float32_num(value.y), 
		_code_float32_num(value.z), 
	]





func _code_float32_num(value: float) -> String:
	var target: = PackedFloat32Array([value])[0]
	for digits in range(1, 12):
		var text: = String.num(value, digits)
		var parsed: = PackedFloat32Array([float(text)])[0]
		if parsed == target:
			return _trim_whole(text)
	return _trim_whole(str(value))


func _trim_whole(text: String) -> String:
	if text.ends_with(".0"):
		return text.substr(0, text.length() - 2)
	return text


func _code_num(value: float) -> String:
	return _trim_whole(str(value))


func _code_parse_num(text: String) -> float:
	var cleaned: = text.strip_edges()
	if not cleaned.is_valid_float():
		return NAN
	var value: = float(cleaned)
	return value if is_finite(value) else NAN


func _code_parse_floats(text: String, expected: int) -> PackedFloat64Array:
	var parts: = text.split(",", true)
	if parts.size() != expected:
		return PackedFloat64Array()
	var values: = PackedFloat64Array()
	for part in parts:
		var value: = _code_parse_num(part)
		if is_nan(value):
			return PackedFloat64Array()
		values.append(value)
	return values


func _code_parse_color(text: String) -> Color:
	var values: = _code_parse_floats(text, 4)
	if values.is_empty():
		return Color(-1.0, -1.0, -1.0, -1.0)
	return Color(values[0], values[1], values[2], values[3])


func _code_parse_vec3(text: String) -> Vector3:
	var values: = _code_parse_floats(text, 3)
	if values.is_empty():
		return Vector3(NAN, NAN, NAN)
	return Vector3(values[0], values[1], values[2])


func _code_valid_color(color: Color) -> bool:
	return is_finite(color.r) and is_finite(color.g)\
	and is_finite(color.b) and is_finite(color.a)\
	and color.r >= 0.0 and color.g >= 0.0\
	and color.b >= 0.0 and color.a >= 0.0


func _validate_loadout() -> void :



	if not _has_skin(weapon_id, weapon_skin)\
	or not owns_item(weapon_id, weapon_skin):
		weapon_id = PRIMARY_ID
		weapon_skin = PRIMARY_SKIN
	if not _is_pistol(pistol_id)\
	or not _has_skin(pistol_id, pistol_skin)\
	or not owns_item(pistol_id, pistol_skin):
		pistol_id = PISTOL_ID
		pistol_skin = PISTOL_SKIN
	if not _has_skin("knife", knife_skin) or not owns_item("knife", knife_skin):
		knife_skin = MELEE_SKIN


func _is_pistol(weapon_id: String) -> bool:
	return str(WeaponData.get_weapon(weapon_id).get("type", "")) == "pistol"


func is_pistol(weapon_id: String) -> bool:
	return _is_pistol(weapon_id)


func _has_skin(weapon_id: String, skin_id: String) -> bool:
	var weapon: = WeaponData.get_weapon(weapon_id)
	var skins: Dictionary = weapon.get("skins", {})
	return skins.has(skin_id)


func _read_color(config: ConfigFile, section: String, key: String, fallback: Color) -> Color:
	var value: Variant = config.get_value(section, key, fallback)
	if value is Color:
		return value
	return fallback




func _read_crosshair(config: ConfigFile) -> void :
	crosshair_color = _read_color(config, "crosshair", "color", crosshair_color)
	crosshair_gap = clampf(float(config.get_value("crosshair", "gap", crosshair_gap)), 
		0.0, 18.0)
	crosshair_length = clampf(float(config.get_value("crosshair", "length", 
		crosshair_length)), 0.0, 18.0)
	crosshair_thickness = clampf(float(config.get_value("crosshair", "thickness", 
		crosshair_thickness)), 1.0, 6.0)
	crosshair_dot = bool(config.get_value("crosshair", "dot", crosshair_dot))
	crosshair_outline = bool(config.get_value("crosshair", "outline", crosshair_outline))
	crosshair_dynamic = bool(config.get_value("crosshair", "dynamic", crosshair_dynamic))
	scope_transparent = bool(config.get_value("crosshair", "scope_transparent", 
		scope_transparent))


func _read_colors(config: ConfigFile) -> void :
	hud_accent = _read_color(config, "custom", "hud_accent", hud_accent)
	sky_top = _read_color(config, "custom", "sky_top", sky_top)
	sky_horizon = _read_color(config, "custom", "sky_horizon", sky_horizon)
	arm_sleeve = _read_color(config, "custom", "arm_sleeve", arm_sleeve)
	arm_glove = _read_color(config, "custom", "arm_glove", arm_glove)
	arm_sharp_split = bool(config.get_value("custom", "arm_sharp_split", false))
	world_tint_enabled = bool(config.get_value("custom", "world_tint_enabled", false))
	world_tint_color = _read_color(config, "custom", "world_tint_color", 
		DEFAULT_WORLD_TINT_COLOR)
	weapon_tint_enabled = bool(config.get_value("custom", "weapon_tint_enabled", false))
	weapon_tint = _read_color(config, "custom", "weapon_tint", DEFAULT_WEAPON_TINT)
	knife_tint_enabled = bool(config.get_value("custom", "knife_tint_enabled", false))
	knife_tint = _read_color(config, "custom", "knife_tint", DEFAULT_KNIFE_TINT)







func _load_viewmodel(config: ConfigFile) -> void :
	var offset_value: Variant = config.get_value("viewmodel", "offset", Vector3.ZERO)
	if offset_value is Vector3:
		vm_offset = Vector3(
			clampf(offset_value.x, VM_OFFSET_MIN, VM_OFFSET_MAX), 
			clampf(offset_value.y, VM_OFFSET_MIN, VM_OFFSET_MAX), 
			clampf(offset_value.z, VM_DEPTH_MIN, VM_DEPTH_MAX))
	var rotation_value: Variant = config.get_value("viewmodel", "rotation", Vector3.ZERO)
	if rotation_value is Vector3:
		vm_rotation = Vector3(
			clampf(rotation_value.x, VM_ROTATION_MIN, VM_ROTATION_MAX), 
			clampf(rotation_value.y, VM_ROTATION_MIN, VM_ROTATION_MAX), 
			clampf(rotation_value.z, VM_ROTATION_MIN, VM_ROTATION_MAX))
	vm_scale = clampf(float(config.get_value("viewmodel", "scale", DEFAULT_VM_SCALE)), 
		VM_SCALE_MIN, VM_SCALE_MAX)
	vm_sway = clampf(float(config.get_value("viewmodel", "sway", DEFAULT_VM_SWAY)), 
		VM_SWAY_MIN, VM_SWAY_MAX)
	left_hand = bool(config.get_value("viewmodel", "left_hand", false))


func set_vm_offset(value: Vector3) -> void :
	vm_offset = Vector3(
		clampf(value.x, VM_OFFSET_MIN, VM_OFFSET_MAX), 
		clampf(value.y, VM_OFFSET_MIN, VM_OFFSET_MAX), 
		clampf(value.z, VM_DEPTH_MIN, VM_DEPTH_MAX))
	queue_save_settings()
	settings_changed.emit()


func set_vm_rotation(value: Vector3) -> void :
	vm_rotation = Vector3(
		clampf(value.x, VM_ROTATION_MIN, VM_ROTATION_MAX), 
		clampf(value.y, VM_ROTATION_MIN, VM_ROTATION_MAX), 
		clampf(value.z, VM_ROTATION_MIN, VM_ROTATION_MAX))
	queue_save_settings()
	settings_changed.emit()


func set_vm_scale(value: float) -> void :
	vm_scale = clampf(value, VM_SCALE_MIN, VM_SCALE_MAX)
	queue_save_settings()
	settings_changed.emit()


func set_vm_sway(value: float) -> void :
	vm_sway = clampf(value, VM_SWAY_MIN, VM_SWAY_MAX)
	queue_save_settings()
	settings_changed.emit()




func set_left_hand(value: bool) -> void :
	if left_hand == value:
		return
	left_hand = value
	queue_save_settings()
	settings_changed.emit()


func reset_viewmodel() -> void :
	vm_offset = Vector3.ZERO
	vm_rotation = Vector3.ZERO
	vm_scale = DEFAULT_VM_SCALE
	vm_sway = DEFAULT_VM_SWAY
	left_hand = false
	queue_save_settings()
	settings_changed.emit()




func owns_item(weapon_id: String, skin_id: String) -> bool:
	return owned_items.has("%s|%s" % [weapon_id, skin_id])


func owns_player_skin(skin_id: String) -> bool:
	return owned_player_skins.has(skin_id)


func buy_player_skin(skin_id: String) -> bool:
	if not PlayerSkinData.has_skin(skin_id):
		return false
	if owns_player_skin(skin_id):
		return false
	var skin: Dictionary = PlayerSkinData.get_skin(skin_id)
	var price: = int(skin.get("price", 0))
	if price > 0 and not spend_coins(price):
		return false
	owned_player_skins.append(skin_id)
	queue_save_settings()
	settings_changed.emit()
	return true


func equip_player_skin(skin_id: String) -> bool:
	if not owns_player_skin(skin_id):
		return false
	player_skin = skin_id
	queue_save_settings()
	settings_changed.emit()
	return true


func _validate_player_skin() -> void :
	if not PlayerSkinData.has_skin(player_skin) \
	or not owned_player_skins.has(player_skin):
		player_skin = PlayerSkinData.DEFAULT_ID



func grant_item(weapon_id: String, skin_id: String) -> bool:
	if owns_item(weapon_id, skin_id):
		return false
	owned_items.append("%s|%s" % [weapon_id, skin_id])
	return true


func owned_count() -> int:
	return owned_items.size()


func set_keybind(action: String, keycode: int) -> void :
	if not DEFAULT_BINDS.has(action):
		return

	if keycode == 0:
		return

	for other in keybinds:
		if str(other) != action and int(keybinds[other]) == keycode:
			keybinds[other] = DEFAULT_BINDS[other]
	keybinds[action] = keycode
	apply_keybinds()
	save_settings()
	settings_changed.emit()


func reset_keybinds() -> void :
	keybinds = DEFAULT_BINDS.duplicate()
	apply_keybinds()
	save_settings()
	settings_changed.emit()





func apply_keybinds() -> void :
	for action in keybinds:
		var action_name: = str(action)
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		InputMap.action_erase_events(action_name)
		var code: = int(keybinds[action])
		if code < 0:
			var mouse_event: = InputEventMouseButton.new()
			mouse_event.button_index = - code
			InputMap.action_add_event(action_name, mouse_event)
		elif code > 0:
			var event: = InputEventKey.new()
			event.physical_keycode = code
			InputMap.action_add_event(action_name, event)


		Input.action_release(action_name)


func get_key_label(action: String) -> String:
	if not keybinds.has(action):
		return "—"
	var code: = int(keybinds[action])
	if code < 0:
		match - code:
			MOUSE_BUTTON_LEFT:
				return "ЛКМ"
			MOUSE_BUTTON_RIGHT:
				return "ПКМ"
			MOUSE_BUTTON_MIDDLE:
				return "СКМ"
			MOUSE_BUTTON_WHEEL_UP:
				return "КОЛЕСО ВВЕРХ"
			MOUSE_BUTTON_WHEEL_DOWN:
				return "КОЛЕСО ВНИЗ"
			MOUSE_BUTTON_XBUTTON1:
				return "БОКОВАЯ 1"
			MOUSE_BUTTON_XBUTTON2:
				return "БОКОВАЯ 2"
		return "МЫШЬ %d" % - code
	if code == 0:
		return "—"
	if code == KEY_SPACE:
		return "ПРОБЕЛ"
	if code == KEY_TAB:
		return "TAB"
	if code == KEY_SHIFT:
		return "SHIFT"
	return OS.get_keycode_string(code)





func get_key_label_compact(action: String) -> String:
	match get_key_label(action):
		"ЛКМ":
			return "LMB"
		"ПКМ":
			return "RMB"
		"СКМ":
			return "MMB"
		"КОЛЕСО ВВЕРХ":
			return "WHEEL ↑"
		"КОЛЕСО ВНИЗ":
			return "WHEEL ↓"
		"БОКОВАЯ 1":
			return "M4"
		"БОКОВАЯ 2":
			return "M5"
		"ПРОБЕЛ":
			return "SPACE"
	return get_key_label(action)




func is_wheel_bind(action: String) -> bool:
	if not keybinds.has(action):
		return false
	var code: = int(keybinds[action])
	return code == - MOUSE_BUTTON_WHEEL_UP or code == - MOUSE_BUTTON_WHEEL_DOWN




func record_shot(is_hit: bool, headshot: bool, kill: bool) -> void :
	total_shots += 1
	if is_hit:
		total_hits += 1
	if headshot:
		total_headshots += 1
	if kill:
		total_kills += 1


func record_melee(kill: bool, headshot: bool) -> void :
	if kill:
		total_kills += 1
	if headshot:
		total_headshots += 1


func record_speed(speed: float) -> void :
	if speed > best_speed:
		best_speed = speed


func get_accuracy() -> float:
	if total_shots <= 0:
		return 0.0
	return float(total_hits) / float(total_shots) * 100.0


func reset_stats() -> void :
	total_shots = 0
	total_hits = 0
	total_kills = 0
	total_headshots = 0
	best_speed = 0.0
	save_settings()
	settings_changed.emit()


func set_profile(new_nickname: String, new_avatar: int) -> void :
	nickname = new_nickname.strip_edges().substr(0, 16)
	if nickname.is_empty():
		nickname = "PLAYER"
	avatar_index = clampi(new_avatar, 0, AVATARS.size() - 1)
	save_settings()
	settings_changed.emit()


func set_country(code: String) -> void :
	country = CountryData.code_at(CountryData.index_of(code))
	save_settings()
	settings_changed.emit()


func get_country_name() -> String:
	return CountryData.name_at(CountryData.index_of(country))






func rating_level_for(elo: int) -> int:
	var level: = 1
	for entry in RATING_LEVELS:
		if elo >= int(entry["min"]):
			level = int(entry["level"])
		else:
			break
	return level


func rating_level() -> int:
	return rating_level_for(rating_elo)





func duel_rival_spread() -> int:
	var distance: = absi(rating_elo - RATING_START)
	return 70 + int(float(distance) * 0.06)








func pick_duel_rival() -> Dictionary:
	var spread: = duel_rival_spread()
	var sign: = 1 if randf() < 0.5 else -1
	if _rival_last_sign != 0 and randf() < 0.62:
		sign = - _rival_last_sign




	var bias: = 0
	if rating_elo > 3000:
		if randf() < 0.68:
			sign = 1
		bias = int(float(rating_elo - 3000) * 0.04)
	var offset: = sign * randi_range(12, spread) + bias
	var rival: = clampi(rating_elo + offset, RATING_MIN, 99999)
	_rival_last_sign = 1 if rival >= rating_elo else -1
	duel_rival_elo = rival
	duel_rival_name = _bot_names.random_nick()
	return {
		"elo": rival, 
		"name": duel_rival_name, 
		"level": rating_level_for(rival), 
	}




func duel_rival_rating() -> int:
	return duel_rival_elo if duel_rival_elo > 0 else rating_elo


func duel_rival_level() -> int:
	return rating_level_for(duel_rival_rating())


func duel_rival_display_name() -> String:
	return duel_rival_name if not duel_rival_name.is_empty() else "БОТ"


func rating_level_name() -> String:
	var level: = rating_level()
	for entry in RATING_LEVELS:
		if int(entry["level"]) == level:
			return str(entry["name"])
	return "НОВИЧОК"



func rating_level_bounds() -> Dictionary:
	var index: = clampi(rating_level() - 1, 0, RATING_LEVELS.size() - 1)
	var low: = int(RATING_LEVELS[index]["min"])
	var high: = 3000
	if index + 1 < RATING_LEVELS.size():
		high = int(RATING_LEVELS[index + 1]["min"])
	return {"low": low, "high": high}



func rating_level_progress() -> float:
	if rating_level() >= 10:
		return 1.0
	var bounds: = rating_level_bounds()
	var span: = maxf(float(int(bounds["high"]) - int(bounds["low"])), 1.0)
	return clampf((float(rating_elo) - float(bounds["low"])) / span, 0.0, 1.0)


func rating_winrate() -> float:
	if rating_matches <= 0:
		return 0.0
	return float(rating_wins) / float(rating_matches) * 100.0



func rating_accuracy() -> float:
	if rating_shots <= 0:
		return 0.0
	return float(rating_hits) / float(rating_shots) * 100.0




func rating_headshot_rate() -> float:
	if rating_hits <= 0:
		return 0.0
	return float(rating_headshots) / float(rating_hits) * 100.0




func rating_avg_damage() -> float:
	if rating_matches <= 0:
		return 0.0
	return float(rating_damage) / float(rating_matches)




func _sanitize_recent_results(raw: Variant) -> Array:
	var clean: Array = []
	if raw is Array:
		for value in raw:
			if value is bool:
				clean.append(value)
			elif value is int or value is float:
				clean.append(float(value) > 0.5)
			if clean.size() >= RATING_RECENT_MAX:
				break
	return clean



func set_show_rating_widget(value: bool) -> void :
	show_rating_widget = value
	save_settings()
	settings_changed.emit()


func set_rating_widget_nickname(value: bool) -> void :
	rating_widget_nickname = value
	save_settings()
	settings_changed.emit()


func set_rating_widget_level(value: bool) -> void :
	rating_widget_level = value
	save_settings()
	settings_changed.emit()


func set_rating_widget_elo(value: bool) -> void :
	rating_widget_elo = value
	save_settings()
	settings_changed.emit()


func set_rating_widget_form(value: bool) -> void :
	rating_widget_form = value
	save_settings()
	settings_changed.emit()


func set_rating_widget_record(value: bool) -> void :
	rating_widget_record = value
	save_settings()
	settings_changed.emit()


func set_rating_widget_style(value: int) -> void :
	rating_widget_style = clampi(value, 0, RATING_WIDGET_STYLES.size() - 1)
	save_settings()
	settings_changed.emit()














func apply_duel_result(won: bool, opponent_elo: = 0, stats: = {}) -> Dictionary:
	var before_level: = rating_level()
	var rounds_won: = maxi(int(stats.get("rounds_won", 0)), 0)
	var rounds_lost: = maxi(int(stats.get("rounds_lost", 0)), 0)
	var shots: = maxi(int(stats.get("shots", 0)), 0)
	var hits: = clampi(int(stats.get("hits", 0)), 0, shots)
	var headshots: = clampi(int(stats.get("headshots", 0)), 0, hits)
	var damage: = maxf(float(stats.get("damage", 0.0)), 0.0)
	var accuracy: = 0.0 if shots <= 0 else float(hits) / float(shots)
	var head_ratio: = 0.0 if hits <= 0 else float(headshots) / float(hits)
	var margin: = rounds_won - rounds_lost
	var rounds_played: = rounds_won + rounds_lost



	var strength_delta: = 0
	if opponent_elo > 0:
		var gap: = clampi(opponent_elo - rating_elo, -2400, 2400)
		strength_delta = clampi(int(round(float(gap) / 20.0)), -10, 10)




	var accuracy_bonus: = int(round(clampf((accuracy - 0.4) / 0.5, 0.0, 1.0) * 6.0))
	var headshot_bonus: = int(round(clampf(head_ratio / 0.6, 0.0, 1.0) * 3.0))
	var damage_bonus: = int(round(clampf(damage / 600.0, 0.0, 1.0) * 2.0))
	var margin_bonus: = int(round(clampf(float(margin) / 5.0, 0.0, 1.0) * 4.0))


	var closeness: = 0
	if rounds_played > 0:
		closeness = int(round(clampf(
			1.0 - float(absi(margin)) / float(rounds_played), 0.0, 1.0) * 4.0))
	var perf_bonus: = mini(12, accuracy_bonus + headshot_bonus
		+ damage_bonus + margin_bonus)

	var delta: = 0
	var base_delta: = 0
	var streak_bonus: = 0
	var mitigation: = 0
	if won:
		rating_wins += 1
		rating_streak += 1
		streak_bonus = mini((rating_streak - 1) * 2, 8)
		base_delta = 20 + streak_bonus
		delta = maxi(4, base_delta + perf_bonus + strength_delta)
	else:
		rating_losses += 1
		rating_streak = 0
		base_delta = -22



		mitigation = mini(7, int(round(accuracy_bonus * 0.35
			+ headshot_bonus * 0.25 + closeness * 0.75)))
		delta = mini(-15, base_delta + mitigation + strength_delta)
	rating_matches += 1
	rating_elo = clampi(rating_elo + delta, RATING_MIN, 99999)
	last_rating_delta = delta
	rating_best = maxi(rating_best, rating_elo)
	rating_best_streak = maxi(rating_best_streak, rating_streak)
	rating_shots += shots
	rating_hits += hits
	rating_headshots += headshots
	rating_damage += int(round(damage))
	recent_results.push_front(won)
	if recent_results.size() > RATING_RECENT_MAX:
		recent_results.resize(RATING_RECENT_MAX)
	save_settings()
	settings_changed.emit()
	return {
		"won": won, 
		"delta": delta, 
		"base_delta": base_delta, 
		"streak_bonus": streak_bonus, 
		"perf_bonus": perf_bonus, 
		"strength_delta": strength_delta, 
		"accuracy_bonus": accuracy_bonus, 
		"headshot_bonus": headshot_bonus, 
		"damage_bonus": damage_bonus, 
		"margin_bonus": margin_bonus, 
		"mitigation": mitigation, 
		"accuracy": accuracy, 
		"shots": shots, 
		"hits": hits, 
		"headshots": headshots, 
		"damage": int(round(damage)), 
		"rounds_won": rounds_won, 
		"rounds_lost": rounds_lost, 
		"opponent_elo": opponent_elo, 
		"elo": rating_elo, 
		"best": rating_best, 
		"wins": rating_wins, 
		"losses": rating_losses, 
		"matches": rating_matches, 
		"streak": rating_streak, 
		"level": rating_level(), 
		"level_name": rating_level_name(), 
		"level_before": before_level, 
		"level_up": rating_level() > before_level, 
		"level_down": rating_level() < before_level, 
	}






func apply_duel_abandon(notify: = true) -> int:
	var before: = rating_elo
	var penalty: = mini(ABANDON_PENALTY, maxi(rating_elo - RATING_MIN, 0))
	rating_elo = clampi(rating_elo - penalty, RATING_MIN, 99999)
	rating_losses += 1
	rating_streak = 0
	rating_matches += 1
	recent_results.push_front(false)
	if recent_results.size() > RATING_RECENT_MAX:
		recent_results.resize(RATING_RECENT_MAX)
	var removed: = before - rating_elo
	last_rating_delta = - removed
	if removed > 0:
		pending_leave_notice = (
			"ВЫ ПОКИНУЛИ РЕЙТИНГОВЫЙ МАТЧ ДО ЕГО ЗАВЕРШЕНИЯ.\n"
			+ "ЗА ВЫХОД С ВАС СНЯТО %d ELO · СЕЙЧАС %d ELO."
		) % [removed, rating_elo]
	else:
		pending_leave_notice = (
			"ВЫ ПОКИНУЛИ РЕЙТИНГОВЫЙ МАТЧ ДО ЕГО ЗАВЕРШЕНИЯ.\n"
			+ "РЕЙТИНГ УЖЕ НА МИНИМУМЕ — ЭЛО НЕ ИЗМЕНИЛОСЬ."
		)
	save_settings()
	if notify:
		settings_changed.emit()
	return - removed




func take_leave_notice() -> String:
	if pending_leave_notice.is_empty():
		return ""
	var text: = pending_leave_notice
	pending_leave_notice = ""
	save_settings()
	return text



func reset_rating() -> void :
	rating_elo = RATING_START
	rating_wins = 0
	rating_losses = 0
	rating_streak = 0
	rating_best = RATING_START
	rating_matches = 0
	rating_best_streak = 0
	rating_shots = 0
	rating_hits = 0
	rating_headshots = 0
	rating_damage = 0
	last_rating_delta = 0
	recent_results.clear()
	pending_leave_notice = ""
	save_settings()
	settings_changed.emit()



func set_mouse_sensitivity(value: float) -> void :
	mouse_sensitivity = clampf(value, SENS_MIN, SENS_MAX)
	queue_save_settings()
	settings_changed.emit()


func set_fov(value: float) -> void :
	fov = clampf(value, FOV_MIN, FOV_MAX)
	queue_save_settings()
	settings_changed.emit()


func set_master_volume(value: float) -> void :
	master_volume = clampf(value, 0.0, 1.0)
	apply_volume()
	queue_save_settings()
	settings_changed.emit()


func set_mannequin_count(value: int) -> void :
	mannequin_count = clampi(value, MANNEQUIN_MIN, MANNEQUIN_MAX)
	queue_save_settings()
	settings_changed.emit()


func set_mannequin_color(value: Color) -> void :
	mannequin_color = value
	save_settings()
	settings_changed.emit()



func set_mannequin_rainbow(value: bool) -> void :
	mannequin_rainbow = value
	save_settings()
	settings_changed.emit()


func set_session_timer(value: bool) -> void :
	session_timer = value
	save_settings()
	settings_changed.emit()



func set_tap_crouch_aim(value: bool) -> void :
	tap_crouch_aim = value
	save_settings()
	settings_changed.emit()




func set_gyro_enabled(value: bool) -> void :
	gyro_enabled = value
	if value:
		gyro_calibration_requested.emit()
	save_settings()
	settings_changed.emit()




func request_gyro_calibration() -> void :
	gyro_calibration_requested.emit()


func set_gyro_sensitivity(value: float) -> void :
	gyro_sensitivity = clampf(value, GYRO_SENS_MIN, GYRO_SENS_MAX)
	queue_save_settings()
	settings_changed.emit()



func set_show_fps(value: bool) -> void :
	show_fps = value
	save_settings()
	settings_changed.emit()



func set_show_input_overlay(value: bool) -> void :
	show_input_overlay = value
	save_settings()
	settings_changed.emit()


func set_crosshair_color(value: Color) -> void :
	crosshair_color = value
	save_settings()
	settings_changed.emit()


func set_crosshair_gap(value: float) -> void :
	crosshair_gap = clampf(value, 0.0, 18.0)
	queue_save_settings()
	settings_changed.emit()


func set_crosshair_length(value: float) -> void :
	crosshair_length = clampf(value, 0.0, 18.0)
	queue_save_settings()
	settings_changed.emit()


func set_crosshair_thickness(value: float) -> void :
	crosshair_thickness = clampf(value, 1.0, 6.0)
	queue_save_settings()
	settings_changed.emit()


func set_crosshair_dot(value: bool) -> void :
	crosshair_dot = value
	save_settings()
	settings_changed.emit()


func set_crosshair_outline(value: bool) -> void :
	crosshair_outline = value
	save_settings()
	settings_changed.emit()


func set_crosshair_dynamic(value: bool) -> void :
	crosshair_dynamic = value
	save_settings()
	settings_changed.emit()



func set_scope_transparent(value: bool) -> void :
	scope_transparent = value
	save_settings()
	settings_changed.emit()




func reset_crosshair() -> void :
	crosshair_color = Color(0.32, 1.0, 0.48, 1.0)
	crosshair_gap = 5.0
	crosshair_length = 7.0
	crosshair_thickness = 2.0
	crosshair_dot = true
	crosshair_outline = true
	crosshair_dynamic = true
	scope_transparent = false
	save_settings()
	settings_changed.emit()


func set_screen_stretch(value: float) -> void :
	screen_stretch = clampf(value, STRETCH_MIN, STRETCH_MAX)
	apply_display()
	queue_save_settings()
	display_changed.emit()


func set_fullscreen(value: bool) -> void :

	fullscreen = value or is_mobile()
	apply_display()
	save_settings()
	display_changed.emit()


func apply_display() -> void :
	var window: = get_window()
	if window == null:
		return
	var want_fullscreen: = fullscreen or is_mobile()
	var target_mode: = Window.MODE_FULLSCREEN if want_fullscreen else Window.MODE_WINDOWED
	if window.mode != target_mode:
		window.mode = target_mode



	var stretch: = clampf(screen_stretch, STRETCH_MIN, STRETCH_MAX)
	var height: = int(round(lerpf(720.0, 960.0, stretch)))
	window.content_scale_size = Vector2i(1280, height)





	window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	if stretch > 0.001:
		window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
	else:

		window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP




func set_render_scale(value: float) -> void :
	render_scale = clampf(value, RENDER_SCALE_MIN, 1.0)
	_adaptive_scale = render_scale
	apply_graphics()
	queue_save_settings()
	settings_changed.emit()


func set_adaptive_resolution(value: bool) -> void :
	adaptive_resolution = value
	_adaptive_scale = render_scale
	_adaptive_time = 0.0
	_adaptive_frames = 0
	_adaptive_frame_max = 0.0
	_adaptive_cooldown = 0.0
	apply_graphics()
	save_settings()
	settings_changed.emit()




func set_stream_mode(value: bool) -> void :
	if stream_mode == value:
		return
	stream_mode = value
	_adaptive_scale = render_scale
	_adaptive_time = 0.0
	_adaptive_frames = 0
	_adaptive_frame_max = 0.0
	_adaptive_cooldown = 0.0
	_apply_physics_rate()
	apply_graphics()
	save_settings()
	settings_changed.emit()




func apply_performance_preset() -> void :
	msaa_level = 0
	effects_quality = 1
	render_scale = 1.0
	adaptive_resolution = true
	_adaptive_scale = 1.0
	_adaptive_time = 0.0
	_adaptive_frames = 0
	_adaptive_frame_max = 0.0
	_adaptive_cooldown = 0.0
	apply_graphics()
	save_settings()
	settings_changed.emit()


func set_msaa_level(value: int) -> void :
	msaa_level = clampi(value, 0, 2)
	apply_graphics()
	save_settings()
	settings_changed.emit()


func set_effects_quality(value: int) -> void :
	effects_quality = clampi(value, 0, 2)
	save_settings()
	settings_changed.emit()


func set_draw_distance(value: float) -> void :
	draw_distance = clampf(value, 100.0, 500.0)
	queue_save_settings()
	settings_changed.emit()


func set_fps_limit(value: int) -> void :
	fps_limit = maxi(0, value)
	apply_graphics()
	save_settings()
	settings_changed.emit()


func set_vsync(value: bool) -> void :
	vsync = value
	apply_graphics()
	save_settings()
	settings_changed.emit()


func set_brightness(value: float) -> void :
	brightness = clampf(value, BRIGHTNESS_MIN, BRIGHTNESS_MAX)
	queue_save_settings()
	settings_changed.emit()


func set_fog_enabled(value: bool) -> void :
	fog_enabled = value
	save_settings()
	settings_changed.emit()


func set_hud_accent(value: Color) -> void :
	hud_accent = value
	save_settings()
	settings_changed.emit()


func set_sky_top(value: Color) -> void :
	sky_top = value
	save_settings()
	settings_changed.emit()


func set_sky_horizon(value: Color) -> void :
	sky_horizon = value
	save_settings()
	settings_changed.emit()


func set_arm_sleeve(value: Color) -> void :
	arm_sleeve = value
	save_settings()
	settings_changed.emit()


func set_arm_glove(value: Color) -> void :
	arm_glove = value
	save_settings()
	settings_changed.emit()


func set_arm_sharp_split(value: bool) -> void :
	arm_sharp_split = value
	save_settings()
	settings_changed.emit()


func set_world_tint_enabled(value: bool) -> void :
	world_tint_enabled = value
	save_settings()
	settings_changed.emit()


func set_world_tint_color(value: Color) -> void :
	world_tint_color = value
	save_settings()
	settings_changed.emit()


func set_weapon_tint_enabled(value: bool) -> void :
	weapon_tint_enabled = value
	save_settings()
	settings_changed.emit()


func set_weapon_tint(value: Color) -> void :
	weapon_tint = value
	save_settings()
	settings_changed.emit()


func set_knife_tint_enabled(value: bool) -> void :
	knife_tint_enabled = value
	save_settings()
	settings_changed.emit()


func set_knife_tint(value: Color) -> void :
	knife_tint = value
	save_settings()
	settings_changed.emit()





func weapon_tint_color() -> Color:
	return weapon_tint if weapon_tint_enabled else Color.TRANSPARENT


func knife_tint_color() -> Color:
	return knife_tint if knife_tint_enabled else Color.TRANSPARENT




func item_tint(weapon_id: String) -> Color:
	return knife_tint_color() if WeaponData.is_melee(weapon_id)\
	else weapon_tint_color()



func reset_colors() -> void :
	hud_accent = DEFAULT_HUD_ACCENT
	sky_top = DEFAULT_SKY_TOP
	sky_horizon = DEFAULT_SKY_HORIZON
	arm_sleeve = DEFAULT_ARM_SLEEVE
	arm_glove = DEFAULT_ARM_GLOVE
	arm_sharp_split = false
	world_tint_enabled = false
	world_tint_color = DEFAULT_WORLD_TINT_COLOR
	weapon_tint_enabled = false
	weapon_tint = DEFAULT_WEAPON_TINT
	knife_tint_enabled = false
	knife_tint = DEFAULT_KNIFE_TINT
	save_settings()
	settings_changed.emit()


func apply_graphics() -> void :
	var viewport: = get_viewport()
	_adaptive_scale = minf(_adaptive_scale, render_scale)
	var applied: = get_effective_render_scale()
	if viewport != null:
		viewport.msaa_3d = msaa_level
		var changed: = not is_equal_approx(viewport.scaling_3d_scale, applied)
		viewport.scaling_3d_scale = applied
		if changed:
			render_scale_changed.emit(applied)
	Engine.max_fps = _effective_fps_limit()
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
		)
	_update_process_state()




func _effective_fps_limit() -> int:
	if stream_mode:
		return mini(fps_limit, STREAM_FPS_CAP) if fps_limit > 0 else STREAM_FPS_CAP
	return fps_limit




func _apply_physics_rate() -> void :
	var target: = 60 if (stream_mode or is_mobile()) else BASE_PHYSICS_TICKS
	if Engine.physics_ticks_per_second != target:
		Engine.physics_ticks_per_second = target


func apply_environment(environment: Environment) -> void :
	if environment == null:
		return



	environment.adjustment_enabled = false
	environment.fog_enabled = fog_enabled
	environment.fog_light_color = sky_horizon.darkened(0.1)
	if environment.sky != null and environment.sky.sky_material is ProceduralSkyMaterial:
		var sky_mat: = environment.sky.sky_material as ProceduralSkyMaterial
		sky_mat.sky_top_color = sky_top
		sky_mat.sky_horizon_color = sky_horizon
		sky_mat.ground_horizon_color = sky_horizon.darkened(0.16)
		sky_mat.ground_bottom_color = sky_top.darkened(0.42)




func set_loadout(new_weapon: String, new_skin: String) -> bool:
	if not owns_item(new_weapon, new_skin):
		return false
	if WeaponData.is_melee(new_weapon):
		knife_skin = new_skin
	elif _is_pistol(new_weapon):
		pistol_id = new_weapon
		pistol_skin = new_skin
	else:
		weapon_id = new_weapon
		weapon_skin = new_skin
	_validate_loadout()
	save_settings()
	settings_changed.emit()
	return true


func is_equipped(item_weapon: String, item_skin: String) -> bool:
	if WeaponData.is_melee(item_weapon):
		return knife_skin == item_skin
	if _is_pistol(item_weapon):
		return pistol_id == item_weapon and pistol_skin == item_skin
	return weapon_id == item_weapon and weapon_skin == item_skin


func get_equipped_label() -> String:
	var primary: = WeaponData.get_item(weapon_id, weapon_skin)
	var pistol: = WeaponData.get_item(pistol_id, pistol_skin)
	var melee: = WeaponData.get_item("knife", knife_skin)
	return "%s  ·  %s  ·  %s" % [primary["full_name"], pistol["full_name"], 
		melee["full_name"]]


func get_avatar_texture() -> Texture2D:
	var path: String = AVATARS[clampi(avatar_index, 0, AVATARS.size() - 1)]
	return load(path) as Texture2D


func apply_volume() -> void :
	var bus: = AudioServer.get_bus_index("Master")
	if bus < 0:
		return
	AudioServer.set_bus_mute(bus, master_volume <= 0.001)
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(master_volume, 0.001)))


func reset_to_defaults() -> void :
	nickname = "PLAYER"
	avatar_index = 0
	country = "RU"
	mouse_sensitivity = 1.0
	master_volume = 0.8
	mannequin_count = 6
	mannequin_color = DEFAULT_MANNEQUIN_COLOR
	mannequin_rainbow = false
	fov = 90.0
	session_timer = true
	show_fps = false
	show_input_overlay = false
	show_rating_widget = false
	rating_widget_nickname = true
	rating_widget_level = true
	rating_widget_elo = true
	rating_widget_form = true
	rating_widget_record = true
	rating_widget_style = 0
	last_rating_delta = 0
	map_id = MAP_DEFAULT
	crosshair_color = Color(0.32, 1.0, 0.48, 1.0)
	crosshair_gap = 5.0
	crosshair_length = 7.0
	crosshair_thickness = 2.0
	crosshair_dot = true
	crosshair_outline = true
	crosshair_dynamic = true
	scope_transparent = false
	screen_stretch = STRETCH_DEFAULT
	fullscreen = true
	render_scale = 1.0
	msaa_level = 0
	effects_quality = 2
	draw_distance = 240.0
	fps_limit = 0
	vsync = true
	brightness = 1.08
	fog_enabled = true
	adaptive_resolution = true
	stream_mode = false
	safe_mode = false
	tap_crouch_aim = false
	gyro_enabled = false
	gyro_sensitivity = GYRO_SENS_DEFAULT
	_adaptive_scale = 1.0
	_adaptive_time = 0.0
	_adaptive_frames = 0
	_adaptive_frame_max = 0.0
	_adaptive_cooldown = 0.0
	hud_accent = DEFAULT_HUD_ACCENT
	sky_top = DEFAULT_SKY_TOP
	sky_horizon = DEFAULT_SKY_HORIZON
	arm_sleeve = DEFAULT_ARM_SLEEVE
	arm_glove = DEFAULT_ARM_GLOVE
	arm_sharp_split = false
	world_tint_enabled = false
	world_tint_color = DEFAULT_WORLD_TINT_COLOR
	weapon_tint_enabled = false
	weapon_tint = DEFAULT_WEAPON_TINT
	knife_tint_enabled = false
	knife_tint = DEFAULT_KNIFE_TINT
	vm_offset = Vector3.ZERO
	vm_rotation = Vector3.ZERO
	vm_scale = DEFAULT_VM_SCALE
	vm_sway = DEFAULT_VM_SWAY
	left_hand = false
	weapon_id = PRIMARY_ID
	weapon_skin = PRIMARY_SKIN
	pistol_id = PISTOL_ID
	pistol_skin = PISTOL_SKIN
	knife_skin = MELEE_SKIN
	keybinds = DEFAULT_BINDS.duplicate()
	mobile_stick_size = 1.0
	mobile_button_size = 1.0
	mobile_slot = 0
	mobile_layout_slots = [
		_default_mobile_slot(0), _default_mobile_slot(1), _default_mobile_slot(2), 
	]
	_apply_active_mobile_slot()
	apply_keybinds()
	apply_volume()
	apply_display()
	_apply_physics_rate()
	apply_graphics()
	save_settings()
	settings_changed.emit()
	mobile_layout_changed.emit()
