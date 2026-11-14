extends Control









var icon: = "fire"
var tint: = Color(1.0, 1.0, 1.0, 0.92)

var soft: = Color(1.0, 1.0, 1.0, 0.4)


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func setup(key: String, color: Color) -> void :
	icon = key
	tint = color
	soft = Color(color.r, color.g, color.b, 0.4)
	queue_redraw()


func set_icon(key: String) -> void :
	if icon == key:
		return
	icon = key
	queue_redraw()




func set_tint(color: Color) -> void :
	if tint == color:
		return
	tint = color
	soft = Color(color.r, color.g, color.b, 0.4)
	queue_redraw()


func _draw() -> void :
	var box: = minf(size.x, size.y)
	if box <= 1.0:
		return
	var center: = size * 0.5
	var half: = box * 0.5
	var weight: = maxf(1.5, half * 0.12)
	match icon:
		"fire":
			_fire(center, half, weight)
		"jump":
			_jump(center, half, weight)
		"crouch":
			_crouch(center, half, weight)
		"aim":
			_aim(center, half, weight)
		"reload":
			_reload(center, half, weight)
		"inspect":
			_inspect(center, half, weight)
		"left_hand":
			_left_hand(center, half, weight)
		"scoreboard":
			_scoreboard(center, half, weight)
		"mannequin":
			_mannequin(center, half, weight)
		"spawn":
			_mannequin(center, half, weight)
		"melee":
			_knife(center, half, weight)
		"rifle":
			_rifle(center, half, weight)
		"stick":
			_stick_marks(center, half, weight)
		"pause":
			_pause(center, half)






func _fire(center: Vector2, half: float, weight: float) -> void :
	draw_set_transform(center, deg_to_rad(-32.0), Vector2.ONE * half)


	var lw: = weight / half

	draw_rect(Rect2(-0.72, -0.16, 0.3, 0.32), soft)
	draw_line(Vector2(-0.96, -0.36), Vector2(-0.6, -0.36), soft, lw, true)
	draw_line(Vector2(-0.96, 0.36), Vector2(-0.6, 0.36), soft, lw, true)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-0.42, -0.18), Vector2(0.2, -0.18), Vector2(0.6, 0.0), 
		Vector2(0.2, 0.18), Vector2(-0.42, 0.18), 
	]), tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)



func _jump(center: Vector2, half: float, weight: float) -> void :
	draw_polyline(PackedVector2Array([
		center + Vector2(-0.42, -0.02) * half, 
		center + Vector2(0.0, -0.48) * half, 
		center + Vector2(0.42, -0.02) * half, 
	]), tint, weight, true)
	draw_line(center + Vector2(0.0, -0.4) * half, 
		center + Vector2(0.0, 0.34) * half, tint, weight, true)
	draw_line(center + Vector2(-0.56, 0.58) * half, 
		center + Vector2(0.56, 0.58) * half, soft, weight, true)



func _crouch(center: Vector2, half: float, weight: float) -> void :
	draw_polyline(PackedVector2Array([
		center + Vector2(-0.44, -0.4) * half, 
		center + Vector2(0.0, -0.08) * half, 
		center + Vector2(0.44, -0.4) * half, 
	]), tint, weight, true)
	draw_polyline(PackedVector2Array([
		center + Vector2(-0.44, -0.02) * half, 
		center + Vector2(0.0, 0.3) * half, 
		center + Vector2(0.44, -0.02) * half, 
	]), soft, weight, true)
	draw_line(center + Vector2(-0.56, 0.6) * half, 
		center + Vector2(0.56, 0.6) * half, tint, weight, true)



func _aim(center: Vector2, half: float, weight: float) -> void :
	draw_arc(center, 0.48 * half, 0.0, TAU, 40, tint, weight, true)
	for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		draw_line(center + direction * 0.62 * half, 
			center + direction * 0.94 * half, tint, weight, true)
	draw_circle(center, 0.09 * half, tint)



func _reload(center: Vector2, half: float, weight: float) -> void :
	var start: = deg_to_rad(-62.0)
	var finish: = deg_to_rad(232.0)
	draw_arc(center, 0.5 * half, start, finish, 44, tint, weight, true)
	var angle: = finish
	var tip: = center + Vector2(cos(angle), sin(angle)) * 0.5 * half
	var radial: = Vector2(cos(angle), sin(angle))
	var tangent: = Vector2( - sin(angle), cos(angle))
	draw_colored_polygon(PackedVector2Array([
		tip + tangent * 0.2 * half, 
		tip + radial * 0.22 * half, 
		tip - tangent * 0.2 * half, 
	]), tint)

	draw_rect(Rect2(center + Vector2(-0.11, -0.24) * half, 
		Vector2(0.22, 0.42) * half), soft)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-0.11, -0.24) * half, 
		center + Vector2(0.0, -0.36) * half, 
		center + Vector2(0.11, -0.24) * half, 
	]), soft)



func _inspect(center: Vector2, half: float, weight: float) -> void :
	var upper: = PackedVector2Array()
	var lower: = PackedVector2Array()
	for i in 25:
		var t: = float(i) / 24.0
		var x: = lerpf(-0.78, 0.78, t)
		upper.append(center + Vector2(x, -0.42 * sin(PI * t)) * half)
		lower.append(center + Vector2(x, 0.3 * sin(PI * t)) * half)
	draw_polyline(upper, tint, weight, true)
	draw_polyline(lower, tint, weight, true)
	draw_arc(center, 0.24 * half, 0.0, TAU, 28, tint, weight, true)
	draw_circle(center, 0.09 * half, tint)






func _left_hand(center: Vector2, half: float, _weight: float) -> void :

	draw_set_transform(center + Vector2(0.05, 0.0) * half, deg_to_rad(8.0), 
		Vector2.ONE * half)

	draw_line(Vector2(-0.22, 0.08), Vector2(-0.57, -0.08), tint, 0.16, true)

	var fingers: = [
		[Vector2(-0.21, -0.08), Vector2(-0.25, -0.68), 0.125], 
		[Vector2(-0.03, -0.08), Vector2(-0.05, -0.84), 0.135], 
		[Vector2(0.15, -0.08), Vector2(0.17, -0.74), 0.125], 
		[Vector2(0.31, -0.06), Vector2(0.34, -0.56), 0.11], 
	]
	for finger in fingers:
		draw_line(finger[0], finger[1], tint, finger[2], true)

	_round_box(Rect2(-0.25, 0.3, 0.5, 0.32), 0.1, soft)

	_round_box(Rect2(-0.32, -0.22, 0.66, 0.58), 0.17, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)



func _scoreboard(center: Vector2, half: float, weight: float) -> void :
	draw_rect(Rect2(center + Vector2(-0.64, -0.58) * half, 
		Vector2(1.28, 1.16) * half), tint, false, weight, true)
	draw_rect(Rect2(center + Vector2(-0.64, -0.58) * half, 
		Vector2(1.28, 0.26) * half), soft)
	for i in 3:
		var y: = -0.1 + 0.26 * float(i)
		draw_circle(center + Vector2(-0.42, y) * half, 0.07 * half, tint)
		draw_line(center + Vector2(-0.24, y) * half, 
			center + Vector2(0.42, y) * half, soft, weight * 0.85, true)



func _mannequin(center: Vector2, half: float, weight: float) -> void :
	draw_circle(center + Vector2(0.0, -0.62) * half, 0.2 * half, tint)
	_round_box(Rect2(center + Vector2(-0.25, -0.34) * half, 
		Vector2(0.5, 0.62) * half), 0.1 * half, tint)

	draw_line(center + Vector2(-0.24, -0.2) * half, 
		center + Vector2(-0.74, -0.2) * half, tint, weight, true)
	draw_line(center + Vector2(0.24, -0.2) * half, 
		center + Vector2(0.74, -0.2) * half, tint, weight, true)

	draw_line(center + Vector2(-0.13, 0.26) * half, 
		center + Vector2(-0.17, 0.7) * half, soft, weight, true)
	draw_line(center + Vector2(0.13, 0.26) * half, 
		center + Vector2(0.17, 0.7) * half, soft, weight, true)
	draw_line(center + Vector2(-0.38, 0.8) * half, 
		center + Vector2(0.38, 0.8) * half, soft, weight, true)



func _knife(center: Vector2, half: float, weight: float) -> void :
	draw_set_transform(center, deg_to_rad(34.0), Vector2.ONE * half)
	var lw: = weight / half
	draw_colored_polygon(PackedVector2Array([
		Vector2(-0.17, -0.18), Vector2(0.04, -0.96), Vector2(0.2, -0.56), 
		Vector2(0.15, -0.18), 
	]), tint)
	draw_rect(Rect2(-0.11, -0.18, 0.22, 0.74), soft)
	draw_line(Vector2(-0.3, -0.18), Vector2(0.3, -0.18), tint, lw, true)
	for i in 2:
		draw_circle(Vector2(0.0, 0.1 + 0.22 * float(i)), 0.045, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)



func _rifle(center: Vector2, half: float, weight: float) -> void :
	draw_set_transform(center, deg_to_rad(-6.0), Vector2.ONE * half)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-0.96, 0.04), Vector2(-0.72, -0.16), Vector2(-0.44, -0.16), 
		Vector2(-0.44, 0.12), Vector2(-0.78, 0.26), 
	]), soft)

	draw_rect(Rect2(-0.64, -0.14, 0.98, 0.22), tint)
	draw_rect(Rect2(0.34, -0.06, 0.64, 0.09), tint)
	draw_rect(Rect2(-0.24, -0.3, 0.42, 0.14), tint)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-0.06, 0.08), Vector2(0.16, 0.08), Vector2(0.24, 0.4), 
		Vector2(0.0, 0.36), 
	]), tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)



func _stick_marks(center: Vector2, half: float, weight: float) -> void :


	draw_circle(center, 0.26 * half, soft)
	for i in 4:
		var angle: = PI * 0.5 * float(i)
		var direction: = Vector2(cos(angle), sin(angle))
		var across: = Vector2( - direction.y, direction.x)
		draw_polyline(PackedVector2Array([
			center + (direction * 0.52 + across * 0.17) * half, 
			center + direction * 0.72 * half, 
			center + (direction * 0.52 - across * 0.17) * half, 
		]), tint, weight, true)



func _pause(center: Vector2, half: float) -> void :
	var bar: = Rect2(center + Vector2(-0.3, -0.42) * half, 
		Vector2(0.19, 0.84) * half)
	draw_rect(bar, tint)
	draw_rect(Rect2(center + Vector2(0.11, -0.42) * half, 
		Vector2(0.19, 0.84) * half), tint)







func _round_box(rect: Rect2, radius: float, color: Color) -> void :
	var r: = clampf(radius, 0.0, minf(rect.size.x, rect.size.y) * 0.5)
	if r <= 0.01:
		draw_rect(rect, color)
		return
	var points: = PackedVector2Array()
	var corners: = [
		[Vector2(rect.end.x - r, rect.position.y + r), - PI * 0.5, 0.0], 
		[Vector2(rect.end.x - r, rect.end.y - r), 0.0, PI * 0.5], 
		[Vector2(rect.position.x + r, rect.end.y - r), PI * 0.5, PI], 
		[Vector2(rect.position.x + r, rect.position.y + r), PI, PI * 1.5], 
	]
	for corner in corners:
		var pivot: Vector2 = corner[0]
		for i in 7:
			var angle: = lerpf(float(corner[1]), float(corner[2]), 
				float(i) / 6.0)
			points.append(pivot + Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, color)
