extends Control





const WeaponData = preload("res://scripts/weapon_data.gd")

var weapon_id: = "awp"
var skin_id: = "default"


func setup(new_weapon: String, new_skin: String) -> void :
	weapon_id = new_weapon
	skin_id = new_skin
	queue_redraw()


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void :
	var skin: = WeaponData.get_skin(weapon_id, skin_id)
	var rarity: = WeaponData.get_rarity(skin)
	var rarity_color: Color = rarity.get("color", Color(0.6, 0.6, 0.6, 1.0))
	var melee: = WeaponData.is_melee(weapon_id)
	var area: = _fit_area(2.3 if melee else 2.65)


	var center: = area.get_center()
	draw_circle(center, minf(area.size.x, area.size.y) * 0.42, 
		Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.1))

	if melee:
		_draw_knife(area, skin, rarity_color)
	else:
		_draw_awp(area, skin, rarity_color)


func _fit_area(aspect: float) -> Rect2:
	var pad: = maxf(4.0, minf(size.x, size.y) * 0.07)
	var avail: = Rect2(Vector2(pad, pad), size - Vector2(pad * 2.0, pad * 2.0))
	if avail.size.x <= 1.0 or avail.size.y <= 1.0:
		return Rect2(Vector2.ZERO, size)
	var ratio: = avail.size.x / avail.size.y
	if ratio > aspect:
		var width: = avail.size.y * aspect
		return Rect2(Vector2(avail.position.x + (avail.size.x - width) * 0.5, 
			avail.position.y), Vector2(width, avail.size.y))
	var height: = avail.size.x / aspect
	return Rect2(Vector2(avail.position.x, 
		avail.position.y + (avail.size.y - height) * 0.5), Vector2(avail.size.x, height))


func _point(area: Rect2, x: float, y: float) -> Vector2:
	return area.position + Vector2(x * area.size.x, y * area.size.y)


func _rect(area: Rect2, x0: float, y0: float, x1: float, y1: float, color: Color) -> void :
	var a: = _point(area, x0, y0)
	var b: = _point(area, x1, y1)
	draw_rect(Rect2(a, b - a), color, true)


func _poly(area: Rect2, points: Array, color: Color) -> void :
	var packed: = PackedVector2Array()
	for entry in points:
		var p: Vector2 = entry
		packed.append(_point(area, p.x, p.y))
	draw_colored_polygon(packed, color)



func _draw_awp(area: Rect2, skin: Dictionary, rarity_color: Color) -> void :
	var body: Color = skin.get("body", Color(0.34, 0.38, 0.42, 1.0))
	var accent: Color = skin.get("accent", Color(0.86, 0.62, 0.25, 1.0))
	var grip: Color = skin.get("grip", Color(0.12, 0.12, 0.13, 1.0))
	var dark: = grip.darkened(0.22)
	var steel: = Color(0.2, 0.22, 0.25, 1.0)
	var light: = body.lightened(0.24)


	_poly(area, [Vector2(0.015, 0.5), Vector2(0.115, 0.455), Vector2(0.245, 0.5), 
		Vector2(0.245, 0.61), Vector2(0.135, 0.66), Vector2(0.015, 0.645)], body)
	_rect(area, 0.055, 0.575, 0.225, 0.65, grip)
	_rect(area, 0.09, 0.462, 0.25, 0.508, dark)

	_rect(area, 0.005, 0.5, 0.04, 0.655, dark)


	_poly(area, [Vector2(0.23, 0.47), Vector2(0.61, 0.455), Vector2(0.61, 0.6), 
		Vector2(0.25, 0.615), Vector2(0.23, 0.56)], body)
	_rect(area, 0.29, 0.47, 0.59, 0.497, light)
	_rect(area, 0.3, 0.545, 0.56, 0.575, accent)
	_rect(area, 0.355, 0.575, 0.47, 0.6, accent.darkened(0.18))


	_poly(area, [Vector2(0.255, 0.585), Vector2(0.335, 0.585), Vector2(0.32, 0.72), 
		Vector2(0.245, 0.715), Vector2(0.235, 0.64)], grip)
	_poly(area, [Vector2(0.3, 0.6), Vector2(0.345, 0.6), Vector2(0.33, 0.66), 
		Vector2(0.295, 0.655)], dark)


	_poly(area, [Vector2(0.4, 0.585), Vector2(0.505, 0.585), Vector2(0.52, 0.7), 
		Vector2(0.43, 0.715), Vector2(0.395, 0.655)], body.darkened(0.1))
	_rect(area, 0.402, 0.61, 0.505, 0.635, accent.darkened(0.2))


	_rect(area, 0.585, 0.505, 0.76, 0.56, body)
	_rect(area, 0.61, 0.49, 0.76, 0.512, accent)
	_rect(area, 0.74, 0.518, 0.94, 0.545, steel)
	_rect(area, 0.94, 0.505, 0.975, 0.558, dark)
	_rect(area, 0.93, 0.5, 0.948, 0.563, accent)


	_rect(area, 0.33, 0.33, 0.56, 0.385, steel)
	_rect(area, 0.315, 0.318, 0.395, 0.398, dark)
	_rect(area, 0.495, 0.318, 0.575, 0.398, dark)
	_rect(area, 0.325, 0.34, 0.568, 0.352, accent)
	_rect(area, 0.41, 0.385, 0.455, 0.455, dark)
	_rect(area, 0.51, 0.385, 0.555, 0.455, dark)


	_poly(area, [Vector2(0.645, 0.56), Vector2(0.67, 0.56), Vector2(0.7, 0.66), 
		Vector2(0.682, 0.665)], dark)
	_poly(area, [Vector2(0.665, 0.56), Vector2(0.69, 0.56), Vector2(0.735, 0.65), 
		Vector2(0.718, 0.658)], dark)
	_rect(area, 0.15, 0.66, 0.3, 0.69, dark)


	_rect(area, 0.235, 0.64, 0.6, 0.652, rarity_color)





func _draw_knife(area: Rect2, skin: Dictionary, rarity_color: Color) -> void :
	var tint: Color = skin.get("tint", Color(1.0, 1.0, 1.0, 1.0))
	var icon: Color = skin.get("icon", tint)
	var steel: = Color(0.78, 0.81, 0.86, 1.0).lerp(icon, 0.42).lightened(0.1)
	var steel_dark: = Color(0.46, 0.5, 0.56, 1.0).lerp(icon, 0.3)
	var handle: = Color(0.155, 0.15, 0.145, 1.0).lerp(icon, 0.28)
	var handle_light: = handle.lightened(0.2)

	match str(skin.get("model", "")):
		"karambit":
			_draw_knife_karambit(area, steel, steel_dark, handle, rarity_color)
		"skeleton":
			_draw_knife_skeleton(area, steel, steel_dark, handle, rarity_color)
		"dagger":
			_draw_knife_dagger(area, steel, steel_dark, handle, handle_light, rarity_color)
		"nomad":
			_draw_knife_nomad(area, steel, steel_dark, handle, handle_light, rarity_color)
		_:
			_draw_knife_straight(area, steel, steel_dark, handle, handle_light, rarity_color)




func _draw_knife_nomad(area: Rect2, steel: Color, steel_dark: Color, 
		handle: Color, handle_light: Color, rarity_color: Color) -> void :


	_poly(area, [Vector2(0.415, 0.4), Vector2(0.855, 0.42), 
		Vector2(0.94, 0.452), Vector2(0.982, 0.548), Vector2(0.928, 0.512), 
		Vector2(0.85, 0.516), Vector2(0.415, 0.548)], steel)
	_poly(area, [Vector2(0.415, 0.4), Vector2(0.855, 0.42), 
		Vector2(0.94, 0.452), Vector2(0.906, 0.468), Vector2(0.845, 0.442), 
		Vector2(0.415, 0.424)], steel.lightened(0.28))
	_poly(area, [Vector2(0.415, 0.518), Vector2(0.85, 0.5), 
		Vector2(0.928, 0.5), Vector2(0.906, 0.53), Vector2(0.415, 0.548)], 
		steel_dark)

	_rect(area, 0.47, 0.458, 0.79, 0.478, steel_dark.darkened(0.18))


	_poly(area, [Vector2(0.385, 0.352), Vector2(0.418, 0.352), 
		Vector2(0.418, 0.604), Vector2(0.385, 0.604), Vector2(0.372, 0.505), 
		Vector2(0.372, 0.452)], handle_light)


	_poly(area, [Vector2(0.128, 0.428), Vector2(0.395, 0.416), 
		Vector2(0.395, 0.578), Vector2(0.14, 0.566), Vector2(0.112, 0.497)], 
		handle)
	_rect(area, 0.16, 0.43, 0.39, 0.452, handle_light)
	for x in [0.196, 0.252, 0.308, 0.358]:
		_rect(area, x, 0.462, x + 0.026, 0.542, handle.lightened(0.06))
	_poly(area, [Vector2(0.086, 0.444), Vector2(0.132, 0.43), 
		Vector2(0.132, 0.568), Vector2(0.086, 0.552)], handle_light)

	_rect(area, 0.15, 0.56, 0.392, 0.578, rarity_color)



func _draw_knife_straight(area: Rect2, steel: Color, steel_dark: Color, 
		handle: Color, handle_light: Color, rarity_color: Color) -> void :

	_poly(area, [Vector2(0.435, 0.395), Vector2(0.905, 0.445), Vector2(0.975, 0.505), 
		Vector2(0.9, 0.515), Vector2(0.435, 0.545)], steel)
	_poly(area, [Vector2(0.435, 0.395), Vector2(0.9, 0.445), Vector2(0.97, 0.5), 
		Vector2(0.9, 0.47), Vector2(0.435, 0.425)], steel.lightened(0.28))
	_poly(area, [Vector2(0.435, 0.505), Vector2(0.9, 0.505), Vector2(0.905, 0.545), 
		Vector2(0.435, 0.545)], steel_dark)

	_rect(area, 0.5, 0.455, 0.82, 0.472, steel_dark.darkened(0.16))


	_poly(area, [Vector2(0.4, 0.35), Vector2(0.438, 0.35), Vector2(0.438, 0.62), 
		Vector2(0.4, 0.62), Vector2(0.385, 0.505), Vector2(0.385, 0.455)], handle_light)


	_poly(area, [Vector2(0.15, 0.435), Vector2(0.4, 0.415), Vector2(0.4, 0.575), 
		Vector2(0.16, 0.56), Vector2(0.13, 0.5)], handle)
	_rect(area, 0.185, 0.435, 0.39, 0.455, handle_light)
	for x in [0.225, 0.29, 0.35]:
		_rect(area, x, 0.455, x + 0.03, 0.545, handle_light.darkened(0.16))

	_poly(area, [Vector2(0.12, 0.45), Vector2(0.165, 0.435), Vector2(0.165, 0.565), 
		Vector2(0.12, 0.55)], handle_light)


	_rect(area, 0.165, 0.555, 0.395, 0.574, rarity_color)



func _draw_knife_karambit(area: Rect2, steel: Color, steel_dark: Color, 
		handle: Color, rarity_color: Color) -> void :

	_poly(area, [Vector2(0.5, 0.435), Vector2(0.7, 0.398), Vector2(0.865, 0.44), 
		Vector2(0.952, 0.545), Vector2(0.968, 0.638), Vector2(0.905, 0.7), 
		Vector2(0.872, 0.628), Vector2(0.866, 0.54), Vector2(0.792, 0.487), 
		Vector2(0.66, 0.468), Vector2(0.5, 0.517)], steel)
	_poly(area, [Vector2(0.5, 0.435), Vector2(0.7, 0.398), Vector2(0.865, 0.44), 
		Vector2(0.93, 0.52), Vector2(0.87, 0.47), Vector2(0.7, 0.437), 
		Vector2(0.5, 0.47)], steel.lightened(0.26))

	_poly(area, [Vector2(0.52, 0.505), Vector2(0.7, 0.462), Vector2(0.862, 0.478), 
		Vector2(0.9, 0.64), Vector2(0.868, 0.56), Vector2(0.79, 0.5), 
		Vector2(0.66, 0.484)], steel_dark)


	_poly(area, [Vector2(0.245, 0.44), Vector2(0.505, 0.425), Vector2(0.505, 0.525), 
		Vector2(0.252, 0.545), Vector2(0.23, 0.5)], handle)
	_rect(area, 0.27, 0.448, 0.495, 0.466, handle.lightened(0.22))
	draw_arc(_point(area, 0.205, 0.5), area.size.y * 0.112, 0.0, TAU, 28, 
		handle.lightened(0.22), maxf(1.5, area.size.y * 0.03), true)
	_rect(area, 0.268, 0.527, 0.5, 0.546, rarity_color)



func _draw_knife_skeleton(area: Rect2, steel: Color, steel_dark: Color, 
		handle: Color, rarity_color: Color) -> void :
	_poly(area, [Vector2(0.43, 0.408), Vector2(0.905, 0.452), Vector2(0.978, 0.508), 
		Vector2(0.898, 0.52), Vector2(0.43, 0.542)], steel)
	_poly(area, [Vector2(0.43, 0.408), Vector2(0.9, 0.452), Vector2(0.972, 0.503), 
		Vector2(0.898, 0.476), Vector2(0.43, 0.44)], steel.lightened(0.26))
	_poly(area, [Vector2(0.43, 0.505), Vector2(0.898, 0.505), Vector2(0.902, 0.542), 
		Vector2(0.43, 0.542)], steel_dark)

	for x in [0.52, 0.635, 0.75]:
		_poly(area, [Vector2(x, 0.446), Vector2(x + 0.066, 0.452), 
			Vector2(x + 0.06, 0.474), Vector2(x + 0.006, 0.468)], 
			steel_dark.darkened(0.35))


	_poly(area, [Vector2(0.145, 0.432), Vector2(0.43, 0.418), Vector2(0.43, 0.552), 
		Vector2(0.158, 0.56), Vector2(0.128, 0.498)], handle)
	_rect(area, 0.18, 0.436, 0.42, 0.456, handle.lightened(0.2))
	for x in [0.222, 0.286, 0.35]:
		_rect(area, x, 0.462, x + 0.028, 0.535, handle.lightened(0.06))
	_rect(area, 0.17, 0.556, 0.42, 0.574, rarity_color)





func _draw_knife_dagger(area: Rect2, steel: Color, steel_dark: Color, 
		handle: Color, handle_light: Color, rarity_color: Color) -> void :
	var center: = area.get_center()
	for i in 2:
		var angle: = deg_to_rad(-20.0 if i == 0 else 20.0)
		var zoom: = 0.88
		var rot: = Transform2D(angle, Vector2.ZERO)
		var offset: = center - rot.basis_xform(center) * zoom
		draw_set_transform(offset, angle, Vector2.ONE * zoom)
		if i == 0:
			_draw_dagger_single(area, steel, steel_dark, handle, handle_light, 
				rarity_color)
		else:
			_draw_dagger_single(area, steel.darkened(0.16), steel_dark.darkened(0.16), 
				handle.darkened(0.12), handle_light.darkened(0.12), rarity_color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_dagger_single(area: Rect2, steel: Color, steel_dark: Color, 
		handle: Color, handle_light: Color, rarity_color: Color) -> void :

	_poly(area, [Vector2(0.33, 0.5), Vector2(0.86, 0.372), Vector2(0.972, 0.5), 
		Vector2(0.86, 0.628)], steel)
	_poly(area, [Vector2(0.33, 0.5), Vector2(0.86, 0.372), Vector2(0.94, 0.5), 
		Vector2(0.86, 0.466)], steel.lightened(0.28))
	_poly(area, [Vector2(0.33, 0.5), Vector2(0.86, 0.628), Vector2(0.94, 0.5), 
		Vector2(0.86, 0.534)], steel_dark)

	_poly(area, [Vector2(0.35, 0.489), Vector2(0.88, 0.489), Vector2(0.88, 0.511), 
		Vector2(0.35, 0.511)], steel_dark.darkened(0.28))


	_rect(area, 0.238, 0.268, 0.33, 0.732, handle)
	_rect(area, 0.238, 0.268, 0.33, 0.3, handle_light)
	_rect(area, 0.238, 0.7, 0.33, 0.732, handle_light.darkened(0.18))
	_rect(area, 0.256, 0.32, 0.312, 0.68, handle.lightened(0.1))
	_rect(area, 0.252, 0.318, 0.268, 0.682, rarity_color)
