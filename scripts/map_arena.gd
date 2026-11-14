extends Node3D
## Свои карты HEADSHOT: генератор раскладок без отскоков от стен.
## Раскладка выбирается в сцене через свойство layout:
##   yard    — «ПОЛЯНА»     (тренировка)
##   mesa    — «КАНЬОН»     (тренировка)
##   lego    — «ЛЕГО»       (тренировка + рейтинг)
##   crusher — «ДРОБИЛКА»   (рейтинг)
##   fort    — «ФОРТ»       (рейтинг)

const MeshKit = preload("res://scripts/mesh_kit.gd")
const FLOOR_SHADER = preload("res://shaders/arena_floor.gdshader")

const HALF: = 28.0
const WALL_HEIGHT: = 10.0

@export_enum("yard", "mesa", "crusher", "fort", "lego") var layout: String = "yard"

var spawn_points: Array[Vector3] = []
var player_start: = Vector3(0.0, 0.05, 16.0)
var bot_start: = Vector3(0.0, 0.05, -12.0)

var _floor_mat: ShaderMaterial
var _wall: StandardMaterial3D
var _platform: StandardMaterial3D
var _box: StandardMaterial3D
var _box_dark: StandardMaterial3D
var _pit: StandardMaterial3D
var _accent: StandardMaterial3D

var _batches: Dictionary = {}


func _ready() -> void :
	_build_materials()
	_apply_layout()
	_build_floor()
	_build_environment_walls()
	_build_lights()
	_build_spawn_points()
	_flush_visuals()


func _build_materials() -> void :
	var palette: = _palette()
	var glossy: = layout == "lego"
	var rough: = 0.32 if glossy else 0.95
	_floor_mat = ShaderMaterial.new()
	_floor_mat.shader = FLOOR_SHADER
	_floor_mat.set_shader_parameter("base_color", palette["floor"])
	_floor_mat.set_shader_parameter("seam_color", palette["seam"])
	_floor_mat.set_shader_parameter("tile_size", palette["tile"])
	_wall = MeshKit.material(palette["wall"], rough, 0.0)
	_platform = MeshKit.material(palette["platform"], rough, 0.0)
	_box = MeshKit.material(palette["box"], rough, 0.0)
	_box_dark = MeshKit.material(palette["box_dark"], rough, 0.0)
	if palette.has("pit"):
		_pit = MeshKit.material(palette["pit"], rough, 0.0)
	else:
		_pit = _box_dark
	_accent = MeshKit.material(palette["accent"], rough, 0.0,
		palette["glow"], 0.32)


func _palette() -> Dictionary:
	match layout:
		"lego":
			return {
				"floor": Color(0.24, 0.55, 0.28, 1.0), 
				"seam": Color(0.16, 0.4, 0.2, 1.0), 
				"tile": 2.0, 
				"wall": Color(0.92, 0.93, 0.95, 1.0), 
				"platform": Color(0.88, 0.89, 0.92, 1.0), 
				"box": Color(0.9, 0.22, 0.18, 1.0), 
				"box_dark": Color(0.95, 0.72, 0.1, 1.0), 
				"pit": Color(0.14, 0.15, 0.18, 1.0), 
				"accent": Color(0.15, 0.55, 0.95, 1.0), 
				"glow": Color(0.2, 0.6, 1.0, 1.0), 
			}
		"mesa":
			return {
				"floor": Color(0.52, 0.42, 0.31, 1.0), 
				"seam": Color(0.37, 0.29, 0.21, 1.0), 
				"tile": 4.0, 
				"wall": Color(0.62, 0.46, 0.32, 1.0), 
				"platform": Color(0.48, 0.36, 0.26, 1.0), 
				"box": Color(0.55, 0.43, 0.3, 1.0), 
				"box_dark": Color(0.38, 0.3, 0.22, 1.0), 
				"accent": Color(0.95, 0.39, 0.14, 1.0), 
				"glow": Color(1.0, 0.44, 0.16, 1.0), 
			}
		"crusher":
			return {
				"floor": Color(0.24, 0.27, 0.3, 1.0), 
				"seam": Color(0.14, 0.16, 0.19, 1.0), 
				"tile": 3.5, 
				"wall": Color(0.3, 0.34, 0.4, 1.0), 
				"platform": Color(0.2, 0.23, 0.28, 1.0), 
				"box": Color(0.34, 0.38, 0.45, 1.0), 
				"box_dark": Color(0.22, 0.25, 0.3, 1.0), 
				"accent": Color(0.2, 0.9, 0.75, 1.0), 
				"glow": Color(0.12, 0.85, 0.72, 1.0), 
			}
		"fort":
			return {
				"floor": Color(0.4, 0.44, 0.47, 1.0), 
				"seam": Color(0.27, 0.31, 0.34, 1.0), 
				"tile": 3.0, 
				"wall": Color(0.58, 0.55, 0.47, 1.0), 
				"platform": Color(0.42, 0.4, 0.34, 1.0), 
				"box": Color(0.5, 0.48, 0.4, 1.0), 
				"box_dark": Color(0.35, 0.33, 0.28, 1.0), 
				"accent": Color(0.9, 0.68, 0.2, 1.0), 
				"glow": Color(1.0, 0.74, 0.25, 1.0), 
			}
		_:
			return {
				"floor": Color(0.36, 0.42, 0.38, 1.0), 
				"seam": Color(0.26, 0.31, 0.27, 1.0), 
				"tile": 3.2, 
				"wall": Color(0.5, 0.53, 0.5, 1.0), 
				"platform": Color(0.38, 0.42, 0.39, 1.0), 
				"box": Color(0.62, 0.5, 0.32, 1.0), 
				"box_dark": Color(0.44, 0.36, 0.23, 1.0), 
				"accent": Color(0.65, 0.95, 0.35, 1.0), 
				"glow": Color(0.6, 0.95, 0.35, 1.0), 
			}


func _apply_layout() -> void :
	match layout:
		"lego":
			_layout_lego()
		"mesa":
			_layout_mesa()
		"crusher":
			_layout_crusher()
		"fort":
			_layout_fort()
		_:
			_layout_yard()


func _layout_yard() -> void :
	player_start = Vector3(0.0, 0.05, 18.0)
	bot_start = Vector3(0.0, 0.05, -14.0)

	# две боковые площадки с прострелами по центру
	_solid(Vector3(14.0, 1.9, 9.0), Vector3(-14.5, 0.95, -15.0), _platform)
	_solid(Vector3(0.4, 1.0, 5.5), Vector3(-20.9, 1.6, -13.5), _platform)
	_solid(Vector3(12.0, 2.7, 8.0), Vector3(14.5, 1.35, -14.0), _platform)
	_solid(Vector3(0.4, 1.1, 5.0), Vector3(20.9, 1.9, -12.0), _platform)

	# рампы наверх без отскоков
	_solid(Vector3(7.0, 0.4, 12.0), Vector3(-7.5, 1.0, 6.0), _platform, 
		Vector3(16.0, 0.0, 0.0))
	_solid(Vector3(7.0, 0.4, 12.0), Vector3(7.5, 1.0, 6.0), _platform, 
		Vector3(16.0, 0.0, 0.0))
	_solid(Vector3(9.0, 0.4, 12.0), Vector3(-11.0, 1.1, -3.0), _platform, 
		Vector3(0.0, 0.0, 16.0))
	_solid(Vector3(9.0, 0.4, 12.0), Vector3(11.0, 1.1, -3.0), _platform, 
		Vector3(0.0, 0.0, -16.0))

	# центральное укрытие и колонны
	_solid(Vector3(1.4, 7.0, 1.4), Vector3(-3.5, 3.5, 1.5), _wall)
	_solid(Vector3(1.4, 7.0, 1.4), Vector3(3.5, 3.5, 1.5), _wall)
	_solid(Vector3(9.6, 0.34, 2.6), Vector3(0.0, 7.14, 1.5), _platform)
	_solid(Vector3(8.0, 2.6, 0.7), Vector3(0.0, 1.3, -4.5), _wall)

	var crates: = [
		[Vector3(-19.5, 0.9, 11.0), 1.8], 
		[Vector3(-17.9, 0.7, 11.6), 1.4], 
		[Vector3(19.5, 0.9, 9.0), 1.8], 
		[Vector3(18.0, 0.7, 9.7), 1.4], 
		[Vector3(-8.0, 0.9, 19.0), 1.8], 
		[Vector3(8.5, 1.0, 19.8), 2.0], 
		[Vector3(20.0, 0.8, -5.0), 1.6], 
		[Vector3(-20.0, 0.8, -7.0), 1.6], 
		[Vector3(0.0, 0.8, 8.0), 1.6], 
	]
	for i in crates.size():
		var spec: Array = crates[i]
		var mat: = _box if i % 2 == 0 else _box_dark
		_solid(Vector3(spec[1], spec[1], spec[1]), spec[0], mat)

	_decor(Vector3(9.6, 0.16, 0.22), Vector3(0.0, 5.6, 2.86), _accent)
	_decor(Vector3(0.22, 0.16, 9.0), Vector3(-20.7, 3.3, -14.0), _accent)
	_decor(Vector3(0.22, 0.16, 9.0), Vector3(20.7, 4.0, -12.0), _accent)


func _layout_mesa() -> void :
	player_start = Vector3(-9.0, 0.05, 20.0)
	bot_start = Vector3(9.0, 0.05, -20.0)

	# каньон: центральный «месa»-мост и две террасы по бокам
	_solid(Vector3(6.5, 3.4, 26.0), Vector3(0.0, 1.7, 0.0), _platform)
	_solid(Vector3(16.0, 2.2, 7.0), Vector3(-16.0, 1.1, -17.0), _platform)
	_solid(Vector3(0.4, 1.2, 6.0), Vector3(-23.4, 1.7, -15.0), _platform)
	_solid(Vector3(16.0, 2.2, 7.0), Vector3(16.0, 1.1, 17.0), _platform)
	_solid(Vector3(0.4, 1.2, 6.0), Vector3(23.4, 1.7, 15.0), _platform)

	# длинные рампы-серпантин
	_solid(Vector3(5.5, 0.4, 13.0), Vector3(-10.5, 1.2, -8.0), _platform, 
		Vector3(17.0, 0.0, 0.0))
	_solid(Vector3(5.5, 0.4, 13.0), Vector3(10.5, 1.2, 8.0), _platform, 
		Vector3(17.0, 0.0, 0.0))
	_solid(Vector3(6.0, 0.4, 13.0), Vector3(-6.0, 1.8, -22.2), _platform, 
		Vector3(19.0, 0.0, 0.0))
	_solid(Vector3(6.0, 0.4, 13.0), Vector3(6.0, 1.8, 22.2), _platform, 
		Vector3(19.0, 0.0, 0.0))

	# скальные блоки-укрытия
	var rocks: = [
		[Vector3(-7.0, 1.35, 3.0), Vector3(1.7, 2.7, 2.4)], 
		[Vector3(7.0, 1.35, -3.0), Vector3(1.7, 2.7, 2.4)], 
		[Vector3(-13.0, 1.6, 9.0), Vector3(2.6, 3.2, 1.8)], 
		[Vector3(13.0, 1.6, -9.0), Vector3(2.6, 3.2, 1.8)], 
		[Vector3(-3.0, 0.8, -12.0), Vector3(1.5, 1.6, 1.5)], 
		[Vector3(3.0, 0.8, 12.0), Vector3(1.5, 1.6, 1.5)], 
		[Vector3(-19.0, 0.9, 4.0), Vector3(1.8, 1.8, 1.8)], 
		[Vector3(19.0, 0.9, -4.0), Vector3(1.8, 1.8, 1.8)], 
	]
	for r in rocks:
		var spec: Array = r
		_solid(spec[1], spec[0], _box_dark if int(spec[1].y * 10.0) % 2 == 1\
			else _box)

	_decor(Vector3(26.5, 0.18, 0.24), Vector3(0.0, 3.5, -0.1), _accent)
	_decor(Vector3(0.24, 0.18, 5.4), Vector3(-23.2, 2.4, -15.0), _accent)
	_decor(Vector3(0.24, 0.18, 5.4), Vector3(23.2, 2.4, 15.0), _accent)


func _layout_crusher() -> void :
	player_start = Vector3(0.0, 0.05, 22.0)
	bot_start = Vector3(0.0, 0.05, -12.0)

	# компактная арена-завод: кольцевая галерея на двух уровнях
	_solid(Vector3(34.0, 2.4, 5.0), Vector3(0.0, 1.2, -19.0), _platform)
	_solid(Vector3(5.0, 2.4, 24.0), Vector3(-21.0, 1.2, -1.0), _platform)
	_solid(Vector3(5.0, 2.4, 24.0), Vector3(21.0, 1.2, -1.0), _platform)

	# угловые проёмы в галерее
	_solid(Vector3(4.5, 1.1, 1.4), Vector3(-14.8, 0.55, -19.0), _wall)
	_solid(Vector3(4.5, 1.1, 1.4), Vector3(14.8, 0.55, -19.0), _wall)
	_solid(Vector3(1.4, 1.1, 6.5), Vector3(-21.0, 0.55, 9.0), _wall)
	_solid(Vector3(1.4, 1.1, 6.5), Vector3(21.0, 0.55, 9.0), _wall)

	# рампы в галерею по углам
	_solid(Vector3(5.5, 0.4, 9.0), Vector3(-16.2, 1.35, -15.4), _platform, 
		Vector3(0.0, 0.0, -19.0))
	_solid(Vector3(5.5, 0.4, 9.0), Vector3(16.2, 1.35, -15.4), _platform, 
		Vector3(0.0, 0.0, 19.0))
	_solid(Vector3(9.0, 0.4, 5.5), Vector3(-16.4, 1.35, 4.9), _platform, 
		Vector3(-19.0, 0.0, 0.0))
	_solid(Vector3(9.0, 0.4, 5.5), Vector3(16.4, 1.35, 4.9), _platform, 
		Vector3(19.0, 0.0, 0.0))

	# центральная «дробилка»: бухты с ящиками
	_solid(Vector3(7.0, 3.6, 7.0), Vector3(0.0, 1.8, 0.0), _wall)
	for side in [-1.0, 1.0]:
		_solid(Vector3(2.0, 1.1, 2.0), Vector3(side * 6.4, 0.55, 6.0), _box)
		_solid(Vector3(2.0, 1.1, 2.0), Vector3(side * 6.4, 0.55, -6.0), _box)
		_solid(Vector3(1.4, 2.2, 1.4), Vector3(side * 11.5, 1.1, 1.0), _box_dark)
		_decor(Vector3(0.16, 0.1, 7.4), Vector3(side * 10.6, 2.3, 0.0), _accent)

	var crates: = [
		[Vector3(-3.0, 0.8, 12.0), 1.6], 
		[Vector3(3.0, 0.8, 12.0), 1.6], 
		[Vector3(0.0, 0.9, 17.0), 1.8], 
		[Vector3(-12.0, 1.9, -10.0), 1.6], 
		[Vector3(12.0, 1.9, -10.0), 1.6], 
	]
	for spec in crates:
		var size: float = spec[1]
		_solid(Vector3(size, size, size), spec[0], _box)

	_decor(Vector3(34.0, 0.16, 0.2), Vector3(0.0, 2.6, -16.42), _accent)
	_decor(Vector3(0.2, 0.16, 24.0), Vector3(-18.42, 2.6, -1.0), _accent)
	_decor(Vector3(0.2, 0.16, 24.0), Vector3(18.42, 2.6, -1.0), _accent)


func _layout_fort() -> void :
	player_start = Vector3(-13.0, 0.05, 13.0)
	bot_start = Vector3(13.0, 0.05, -13.0)

	# форт: центральная цитадель + две равные стороны по диагоналям
	_solid(Vector3(11.0, 3.2, 11.0), Vector3(0.0, 1.6, 0.0), _platform)
	_solid(Vector3(9.0, 1.1, 0.5), Vector3(0.0, 3.7, -5.6), _wall)
	_solid(Vector3(9.0, 1.1, 0.5), Vector3(0.0, 3.7, 5.6), _wall)
	_solid(Vector3(0.5, 1.1, 9.0), Vector3(-5.6, 3.7, 0.0), _wall)
	_solid(Vector3(0.5, 1.1, 9.0), Vector3(5.6, 3.7, 0.0), _wall)

	# рампы в цитадель с двух сторон
	_solid(Vector3(7.0, 0.4, 12.0), Vector3(0.0, 1.4, 12.6), _platform, 
		Vector3(18.0, 0.0, 0.0))
	_solid(Vector3(7.0, 0.4, 12.0), Vector3(0.0, 1.4, -12.6), _platform, 
		Vector3(-18.0, 0.0, 0.0))

	# угловые бастионы
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			_solid(Vector3(7.5, 2.0, 7.5), 
				Vector3(sx * 19.0, 1.0, sz * 19.0), _platform)
			_solid(Vector3(2.2, 2.6, 2.2), 
				Vector3(sx * 19.0, 1.3, sz * 15.4), _box_dark)

	# стены-серпы вокруг центра
	_solid(Vector3(0.8, 4.2, 16.0), Vector3(-8.0, 2.1, 3.0), _wall)
	_solid(Vector3(0.8, 4.2, 16.0), Vector3(8.0, 2.1, -3.0), _wall)
	_solid(Vector3(12.0, 4.2, 0.8), Vector3(-4.0, 2.1, 9.0), _wall)
	_solid(Vector3(12.0, 4.2, 0.8), Vector3(4.0, 2.1, -9.0), _wall)

	var crates: = [
		[Vector3(-13.0, 0.9, -4.0), 1.8], 
		[Vector3(13.0, 0.9, 4.0), 1.8], 
		[Vector3(-4.0, 0.8, -13.0), 1.6], 
		[Vector3(4.0, 0.8, 13.0), 1.6], 
		[Vector3(-23.0, 0.8, 8.0), 1.6], 
		[Vector3(23.0, 0.8, -8.0), 1.6], 
	]
	for spec in crates:
		var size: float = spec[1]
		_solid(Vector3(size, size, size), spec[0], _box)

	_decor(Vector3(11.2, 0.18, 0.7), Vector3(0.0, 3.8, -5.4), _accent)
	_decor(Vector3(0.7, 0.18, 11.2), Vector3(-5.4, 3.8, 0.0), _accent)


func _layout_lego() -> void :
	# AWP LEGO: жёлтая лего-крепость в центре — платформа с ямой,
	# башня с окнами на 4 гранях и широкая рампа; пол из цветных квадрантов.
	player_start = Vector3(0.0, 0.05, 20.0)
	bot_start = Vector3(-18.0, 0.05, -16.0)

	# --- цельная платформа 20x16 (высота 3.4), без ямы ---
	_solid(Vector3(20.0, 3.4, 16.0), Vector3(0.0, 1.7, 0.0), _box_dark)

	# --- башня 3.6x3.6x5.2 на платформе, окна на всех 4 гранях ---
	var tower: = Vector3(-5.5, 0.0, 0.0)
	for face in [
		[Vector3(0.0, 0.0, 1.0), Vector3(1.0, 0.0, 0.0)], 
		[Vector3(0.0, 0.0, -1.0), Vector3(1.0, 0.0, 0.0)], 
		[Vector3(1.0, 0.0, 0.0), Vector3(0.0, 0.0, 1.0)], 
		[Vector3(-1.0, 0.0, 0.0), Vector3(0.0, 0.0, 1.0)], 
	]:
		var normal: Vector3 = face[0]
		var side_dir: Vector3 = face[1]
		var wall_center: = tower + normal * 1.5
		# нижний и верхний поясы стены (окно 1.6x1.8 между ними)
		var band_size: Vector3 = Vector3(3.6, 1.7, 0.6) \
			if normal.z != 0.0 else Vector3(0.6, 1.7, 3.6)
		_solid(band_size, wall_center + Vector3(0.0, 4.25, 0.0), _wall)
		_solid(band_size, wall_center + Vector3(0.0, 6.05, 0.0), _wall)
		# боковые стойки окна
		var post_size: Vector3 = Vector3(1.0, 1.8, 0.6) \
			if normal.z != 0.0 else Vector3(0.6, 1.8, 1.0)
		for post_side in [-1.0, 1.0]:
			_solid(post_size, 
				wall_center + side_dir * 1.3 * post_side 
				+ Vector3(0.0, 4.3, 0.0), _wall)
	# крыша башни
	_solid(Vector3(3.6, 0.3, 3.6), tower + Vector3(0.0, 7.05, 0.0), _box_dark)
	for cx in 3:
		for rz in 3:
			_batch(Vector3(0.5, 0.14, 0.5), 
				tower + Vector3(-0.9 + float(cx) * 0.9, 7.27, 
				-0.9 + float(rz) * 0.9), _box, Vector3.ZERO)

	# --- широкая жёлтая рампа на -x сторону (подъём 3.4) ---
	_solid(Vector3(7.0, 0.4, 5.0), Vector3(-13.3, 1.7, 0.0), _box_dark, 
		Vector3(0.0, 0.0, 27.0))
	# подпорка под высоким краем рампы
	_solid(Vector3(1.2, 2.6, 5.0), Vector3(-10.6, 1.3, 0.0), _box_dark)

	# --- студы на платформе (декор, без коллизии) ---
	for i in 17:
		var px: = -9.6 + float(i) * 1.2
		for j in 13:
			var pz: = -7.2 + float(j) * 1.2
			if px > -7.8 and px < -3.2 and pz > -2.4 and pz < 2.4:
				continue
			_batch(Vector3(0.5, 0.14, 0.5), Vector3(px, 3.47, pz), 
				_box_dark, Vector3.ZERO)

	# --- цветные укрытия-кирпичи на полу ---
	var cover: = [
		[Vector3(-18.0, 1.1, 12.0), Vector3(4.0, 2.2, 3.0), _box], 
		[Vector3(18.0, 1.1, -12.0), Vector3(4.0, 2.2, 3.0), _accent], 
		[Vector3(-9.0, 0.8, 14.0), Vector3(3.0, 1.6, 3.0), _accent], 
		[Vector3(9.0, 0.8, -14.0), Vector3(3.0, 1.6, 3.0), _box], 
		[Vector3(-23.0, 0.8, -8.0), Vector3(3.0, 1.6, 5.0), _box_dark], 
		[Vector3(23.0, 0.8, 8.0), Vector3(3.0, 1.6, 5.0), _box], 
		[Vector3(16.0, 1.1, 12.0), Vector3(4.0, 2.2, 3.0), _box_dark], 
		[Vector3(-16.0, 1.1, -12.0), Vector3(4.0, 2.2, 3.0), _accent], 
	]
	for spec in cover:
		var size: Vector3 = spec[1]
		_brick(size, spec[0], spec[2])


func _brick(size: Vector3, pos: Vector3, mat: Material) -> void :
	# лего-кирпич: блок плюс шипы сверху
	_solid(size, pos, mat)
	var stud_y: = pos.y + size.y * 0.5 + 0.06
	var cols: int = int(size.x / 0.95)
	var rows: int = int(size.z / 0.95)
	if cols < 1 or rows < 1:
		return
	if cols * rows > 90:
		return
	for cx in cols:
		for rz in rows:
			var stud: = Vector3(
				pos.x - size.x * 0.5 + 0.55 + float(cx) * 0.95, 
				stud_y, 
				pos.z - size.z * 0.5 + 0.55 + float(rz) * 0.95)
			_batch(Vector3(0.42, 0.12, 0.42), stud, mat, Vector3.ZERO)


func _solid(size: Vector3, pos: Vector3, mat: Material, 
		rot: = Vector3.ZERO) -> void :
	_collision(size, pos, rot)
	_batch(size, pos, mat, rot)


func _collision(size: Vector3, pos: Vector3, rot: Vector3) -> void :
	var body: = StaticBody3D.new()
	body.position = pos
	body.rotation_degrees = rot
	add_child(body)
	var shape: = BoxShape3D.new()
	shape.size = size
	var col: = CollisionShape3D.new()
	col.shape = shape
	body.add_child(col)


func _decor(size: Vector3, pos: Vector3, mat: Material, 
		rot: = Vector3.ZERO) -> void :
	_batch(size, pos, mat, rot)


func _batch(size: Vector3, pos: Vector3, mat: Material, rot: Vector3) -> void :
	if not _batches.has(mat):
		_batches[mat] = []
	var basis: = Basis.from_euler(rot * (PI / 180.0))
	_batches[mat].append([MeshKit.box_mesh(size), Transform3D(basis, pos)])


func _build_floor() -> void :
	var body: = StaticBody3D.new()
	body.name = "Floor"
	add_child(body)
	var shape: = BoxShape3D.new()
	shape.size = Vector3(HALF * 2.0, 0.6, HALF * 2.0)
	var col: = CollisionShape3D.new()
	col.shape = shape
	col.position = Vector3(0.0, -0.3, 0.0)
	body.add_child(col)
	if layout == "lego":
		# цветные квадранты: красный (x<0), синий (x>0, z>0),
		# зелёный (x>0, z<0) — коллизия общая
		var quads: = [
			[Vector3(-HALF * 0.5, -0.3, 0.0), 
				Vector3(HALF, 0.6, HALF * 2.0), Color(0.85, 0.2, 0.16, 1.0)], 
			[Vector3(HALF * 0.5, -0.3, HALF * 0.5), 
				Vector3(HALF, 0.6, HALF), Color(0.16, 0.52, 0.92, 1.0)], 
			[Vector3(HALF * 0.5, -0.3, -HALF * 0.5), 
				Vector3(HALF, 0.6, HALF), Color(0.24, 0.62, 0.3, 1.0)], 
		]
		for spec in quads:
			var pos: Vector3 = spec[0]
			var size: Vector3 = spec[1]
			var quad: = MeshInstance3D.new()
			quad.mesh = MeshKit.box_mesh(size)
			quad.material_override = _floor_material(spec[2])
			quad.position = pos
			quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			body.add_child(quad)
		return
	var mesh: = MeshInstance3D.new()
	mesh.mesh = MeshKit.box_mesh(shape.size)
	mesh.material_override = _floor_mat
	mesh.position = Vector3(0.0, -0.3, 0.0)
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.add_child(mesh)


func _floor_material(base: Color) -> ShaderMaterial:
	var mat: = ShaderMaterial.new()
	mat.shader = FLOOR_SHADER
	mat.set_shader_parameter("base_color", base)
	var palette: = _palette()
	mat.set_shader_parameter("seam_color", 
		palette["seam"] if not palette.has("pit") else Color(0.12, 0.12, 0.14, 1.0))
	mat.set_shader_parameter("tile_size", palette["tile"])
	return mat


func _build_environment_walls() -> void :
	_solid(Vector3(HALF * 2.0, WALL_HEIGHT, 1.0), 
		Vector3(0.0, WALL_HEIGHT * 0.5, - HALF), _wall)
	_solid(Vector3(HALF * 2.0, WALL_HEIGHT, 1.0), 
		Vector3(0.0, WALL_HEIGHT * 0.5, HALF), _wall)
	_solid(Vector3(1.0, WALL_HEIGHT, HALF * 2.0), 
		Vector3(- HALF, WALL_HEIGHT * 0.5, 0.0), _wall)
	_solid(Vector3(1.0, WALL_HEIGHT, HALF * 2.0), 
		Vector3(HALF, WALL_HEIGHT * 0.5, 0.0), _wall)

	# световые линии по низу стен (декор)
	for side in [-1.0, 1.0]:
		_decor(Vector3(HALF * 2.0, 0.16, 0.06), 
			Vector3(0.0, 0.9, side * (HALF - 0.54)), _accent)
		_decor(Vector3(0.06, 0.16, HALF * 2.0), 
			Vector3(side * (HALF - 0.54), 0.9, 0.0), _accent)


func _build_lights() -> void :
	for spec in [
		[Vector3(-16.0, 7.5, -10.0), 1.5, 26.0], 
		[Vector3(16.0, 7.5, -10.0), 1.5, 26.0], 
		[Vector3(0.0, 8.0, 14.0), 1.2, 28.0], 
		[Vector3(0.0, 8.5, 0.0), 1.1, 22.0], 
	]:
		var light: = OmniLight3D.new()
		light.position = spec[0]
		light.light_color = Color(1.0, 0.88, 0.72, 1.0)
		light.light_energy = spec[1]
		light.omni_range = spec[2]
		light.shadow_enabled = false
		light.add_to_group("arena_decor_lights")
		add_child(light)


func _build_spawn_points() -> void :
	match layout:
		"lego":
			spawn_points = [
				Vector3(0.0, 0.05, 20.0), Vector3(-4.0, 0.05, 22.0), 
				Vector3(4.0, 0.05, 22.0), Vector3(0.0, 0.05, -18.0), 
				Vector3(-6.0, 0.05, -20.0), Vector3(6.0, 0.05, -20.0), 
				Vector3(-5.5, 3.45, 6.0), Vector3(-5.5, 3.45, -6.0), 
				Vector3(8.5, 3.45, 0.0), Vector3(2.0, 3.45, 0.0), 
				Vector3(-20.0, 0.05, 6.0), Vector3(20.0, 0.05, -6.0), 
				Vector3(-16.0, 0.05, 16.0), Vector3(16.0, 0.05, -16.0), 
				Vector3(-20.0, 0.05, -14.0), Vector3(20.0, 0.05, 14.0), 
				Vector3(12.0, 0.05, 10.0), Vector3(-12.0, 0.05, -10.0), 
			]
		"mesa":
			spawn_points = [
				Vector3(-12.0, 0.05, 18.0), Vector3(-8.0, 0.05, 16.0), 
				Vector3(10.0, 0.05, 20.0), Vector3(13.0, 0.05, 17.0), 
				Vector3(0.0, 3.5, 21.0), Vector3(0.0, 1.8, -21.0), 
				Vector3(-13.5, 2.3, -17.0), Vector3(-18.5, 2.3, -18.5), 
				Vector3(17.5, 2.3, 15.5), Vector3(18.5, 2.3, 18.0), 
				Vector3(-19.0, 0.05, 4.0), Vector3(19.0, 0.05, -4.0), 
				Vector3(-6.0, 0.05, -6.0), Vector3(6.0, 0.05, 6.0), 
				Vector3(-23.0, 0.05, 12.0), Vector3(23.0, 0.05, -12.0), 
				Vector3(0.0, 0.05, 10.0), Vector3(0.0, 0.05, -10.0), 
			]
		"crusher":
			spawn_points = [
				Vector3(-21.0, 2.5, -14.0), Vector3(-19.0, 2.5, -17.0), 
				Vector3(19.0, 2.5, -17.0), Vector3(21.0, 2.5, -14.0), 
				Vector3(-21.0, 2.5, 2.0), Vector3(21.0, 2.5, 2.0), 
				Vector3(-16.0, 0.05, 12.0), Vector3(-11.0, 0.05, 14.0), 
				Vector3(16.0, 0.05, 12.0), Vector3(11.0, 0.05, 14.0), 
				Vector3(0.0, 0.05, 8.0), Vector3(-5.0, 0.05, 5.0), 
				Vector3(5.0, 0.05, 5.0), Vector3(-9.0, 0.05, -8.0), 
				Vector3(9.0, 0.05, -8.0), Vector3(0.0, 0.05, 20.0), 
				Vector3(-23.0, 0.05, 20.0), Vector3(23.0, 0.05, 20.0), 
			]
		"fort":
			spawn_points = [
				Vector3(-19.0, 2.1, 19.0), Vector3(-17.0, 2.1, 21.0), 
				Vector3(19.0, 2.1, -19.0), Vector3(17.0, 2.1, -21.0), 
				Vector3(-19.0, 2.1, -19.0), Vector3(19.0, 2.1, 19.0), 
				Vector3(0.0, 3.8, 2.9), Vector3(0.0, 3.8, -2.9), 
				Vector3(-4.9, 3.8, 1.0), Vector3(4.9, 3.8, -1.0), 
				Vector3(-12.0, 0.05, 12.0), Vector3(12.0, 0.05, -12.0), 
				Vector3(-14.0, 0.05, -10.0), Vector3(14.0, 0.05, 10.0), 
				Vector3(-23.0, 0.05, 2.0), Vector3(23.0, 0.05, -2.0), 
				Vector3(-2.0, 0.05, 22.0), Vector3(2.0, 0.05, -22.0), 
			]
		_:
			spawn_points = [
				Vector3(-14.5, 1.95, -15.0), Vector3(-11.5, 1.95, -17.0), 
				Vector3(14.5, 2.75, -14.0), Vector3(17.0, 2.75, -12.0), 
				Vector3(0.0, 0.05, -12.0), Vector3(-6.0, 0.05, 5.0), 
				Vector3(6.0, 0.05, 5.0), Vector3(-20.0, 0.05, 8.0), 
				Vector3(21.0, 0.05, 7.0), Vector3(5.0, 0.05, -21.0), 
				Vector3(-8.0, 0.05, -22.0), Vector3(0.0, 0.05, 20.0), 
				Vector3(21.0, 0.05, 19.0), Vector3(-21.0, 0.05, 21.0), 
				Vector3(-3.0, 0.05, 11.0), Vector3(12.0, 0.05, 17.0), 
				Vector3(-17.0, 0.05, -4.0), Vector3(18.0, 0.05, -4.0), 
			]


func _flush_visuals() -> void :
	for mat in _batches:
		var parts: Array = _batches[mat]
		if parts.is_empty():
			continue
		var inst: = MeshInstance3D.new()
		inst.mesh = MeshKit.merged_boxes(parts)
		inst.material_override = mat
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		inst.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		add_child(inst)
	_batches.clear()
