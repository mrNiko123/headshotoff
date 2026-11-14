extends Control





const CountryData = preload("res://scripts/country_data.gd")

var country: = "RU"
var _spec: Dictionary = {}


func _ready() -> void :
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spec = CountryData.get_country(country)
	resized.connect(queue_redraw)


func set_country(code: String) -> void :
	country = code
	_spec = CountryData.get_country(code)
	queue_redraw()


func _draw() -> void :
	var w: = size.x
	var h: = size.y
	if w < 1.0 or h < 1.0:
		return
	var rect: = Rect2(Vector2.ZERO, Vector2(w, h))
	var colors: Array = _spec.get("colors", [])
	var weights: Array = _spec.get("weights", [])
	match str(_spec.get("type", "h")):
		"h":
			_draw_stripes(rect, colors, false, weights)
		"v":
			_draw_stripes(rect, colors, true, weights)
		"nordic":
			_draw_nordic(rect, colors)
		"cross":
			_draw_cross(rect, colors)
		"us":
			_draw_us(rect, colors)
		"uk":
			_draw_uk(rect, colors)
		"sun":
			_draw_sun(rect, colors)
		"solid":
			_draw_solid(rect, colors)
		"cn":
			_draw_cn(rect, colors)
		"br":
			_draw_br(rect, colors)
		"ca":
			_draw_ca(rect, colors)
		"tr":
			_draw_tr(rect, colors)
		"in":
			_draw_in(rect, colors)
		"cz":
			_draw_cz(rect, colors)
		"pt":
			_draw_pt(rect, colors)
		"gr":
			_draw_gr(rect, colors)
		"ae":
			_draw_ae(rect, colors)
		"cl":
			_draw_cl(rect, colors)
		"ph":
			_draw_ph(rect, colors)
		"il":
			_draw_il(rect, colors)
		"ar":
			_draw_ar(rect, colors)
		"sunrays":
			_draw_sunrays(rect, colors)
		"crescent":
			_draw_crescent(rect, colors, false)
		"crescent_split":
			_draw_crescent(rect, colors, true)
		"crescent_disc":
			_draw_crescent_disc(rect, colors)
		"hstar":
			_draw_star_stripes(rect, colors, false)
		"vstar":
			_draw_star_stripes(rect, colors, true)
		"tri":
			_draw_tri(rect, colors)
		"diag":
			_draw_diag(rect, colors)
		"serrated":
			_draw_serrated(rect, colors)
		"jm":
			_draw_jm(rect, colors)
		"pa":
			_draw_pa(rect, colors)
		"do":
			_draw_do(rect, colors)
		"uy":
			_draw_uy(rect, colors)
		"ve":
			_draw_ve(rect, colors)
		"cu":
			_draw_cu(rect, colors)
		"za":
			_draw_za(rect, colors)
		"pk":
			_draw_pk(rect, colors)
		"bd":
			_draw_bd(rect, colors)
		"lk":
			_draw_lk(rect, colors)
		"np":
			_draw_np(rect, colors)
		"ir":
			_draw_ir(rect, colors)
		"iq":
			_draw_iq(rect, colors)
		"sy":
			_draw_sy(rect, colors)
		"lb":
			_draw_lb(rect, colors)
		"tj":
			_draw_tj(rect, colors)
		"tm":
			_draw_tm(rect, colors)
		"uz":
			_draw_uz(rect, colors)
		"mn":
			_draw_mn(rect, colors)
		"kh":
			_draw_kh(rect, colors)
		"la":
			_draw_la(rect, colors)
		"tw":
			_draw_tw(rect, colors)
		"hk":
			_draw_hk(rect, colors)
		"sg":
			_draw_sg(rect, colors)
		"kr":
			_draw_kr(rect, colors)
		"my":
			_draw_my(rect, colors)
		"bn":
			_draw_bn(rect, colors)
		"tl":
			_draw_tl(rect, colors)
		"mv":
			_draw_mv(rect, colors)
		"bt":
			_draw_bt(rect, colors)
		"au":
			_draw_uk_stars(rect, colors, "au")
		"nz":
			_draw_uk_stars(rect, colors, "nz")
		"fj":
			_draw_uk_stars(rect, colors, "fj")
		"pg":
			_draw_pg(rect, colors)
		"ws":
			_draw_ws(rect, colors)
		"to":
			_draw_to(rect, colors)
		"vu":
			_draw_vu(rect, colors)
		"bb":
			_draw_bb(rect, colors)
		"bs":
			_draw_bs(rect, colors)
		"bz":
			_draw_bz(rect, colors)
		"ug":
			_draw_ug(rect, colors)
		"zw":
			_draw_zw(rect, colors)
		"zm":
			_draw_zm(rect, colors)
		"mz":
			_draw_mz(rect, colors)
		"ao":
			_draw_ao(rect, colors)
		"na":
			_draw_na(rect, colors)
		"rw":
			_draw_rw(rect, colors)
		"cd":
			_draw_cd(rect, colors)
		"ne":
			_draw_ne(rect, colors)
		"ec":
			_draw_ec(rect, colors)
		"ma":
			_draw_ma(rect, colors)
		"sa":
			_draw_sa(rect, colors)
		"af":
			_draw_af(rect, colors)
		"mk":
			_draw_mk(rect, colors)
		"sc":
			_draw_sc(rect, colors)
		"al":
			_draw_al(rect, colors)
		"ba":
			_draw_ba(rect, colors)
		"me":
			_draw_me(rect, colors)
		"mt":
			_draw_mt(rect, colors)
		"cy":
			_draw_cy(rect, colors)
		"xk":
			_draw_xk(rect, colors)
		_:
			_draw_globe(rect)

	draw_rect(rect.grow(-0.5), Color(0.0, 0.0, 0.0, 0.45), false, 1.0)


func _draw_stripes(rect: Rect2, colors: Array, vertical: bool, 
		weights: Array = []) -> void :
	if colors.is_empty():
		return
	var count: = colors.size()
	var total: = 0.0
	var even: = weights.size() != count
	if even:
		total = float(count)
	else:
		for weight in weights:
			total += maxf(float(weight), 0.001)
	var cursor: = 0.0
	for i in count:
		var share: = 1.0 / float(count) if even else float(weights[i]) / total
		var start: = cursor
		var end: = 1.0 if i == count - 1 else cursor + share
		var color: Color = colors[i]
		if vertical:
			draw_rect(Rect2(rect.position + Vector2(rect.size.x * start, 0.0), 
				Vector2(rect.size.x * (end - start), rect.size.y)), color)
		else:
			draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y * start), 
				Vector2(rect.size.x, rect.size.y * (end - start))), color)
		cursor = end


func _draw_nordic(rect: Rect2, colors: Array) -> void :
	if colors.is_empty():
		return
	var bg: Color = colors[0]
	draw_rect(rect, bg)
	var t: = rect.size.y * 0.22
	var cx: = rect.position.x + rect.size.x * 0.38
	var cy: = rect.position.y + rect.size.y * 0.5
	if colors.size() >= 3:
		var outline: Color = colors[2]
		_nordic_cross(rect, cx, cy, t * 1.85, outline)
	if colors.size() >= 2:
		var cross: Color = colors[1]
		_nordic_cross(rect, cx, cy, t, cross)


func _nordic_cross(rect: Rect2, cx: float, cy: float, thickness: float, 
		color: Color) -> void :
	var half: = thickness * 0.5
	draw_rect(Rect2(cx - half, rect.position.y, thickness, rect.size.y), color)
	draw_rect(Rect2(rect.position.x, cy - half, rect.size.x, thickness), color)


func _draw_cross(rect: Rect2, colors: Array) -> void :
	if colors.is_empty():
		return
	draw_rect(rect, colors[0])
	if colors.size() < 2:
		return
	var span: = minf(rect.size.x, rect.size.y)
	var arm: = span * 0.2
	var length: = span * 0.62
	var center: = rect.position + rect.size * 0.5
	var color: Color = colors[1]
	draw_rect(Rect2(center.x - arm * 0.5, center.y - length * 0.5, 
		arm, length), color)
	draw_rect(Rect2(center.x - length * 0.5, center.y - arm * 0.5, 
		length, arm), color)


func _draw_us(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	var red: Color = colors[0]
	var white: Color = colors[1]
	var blue: Color = colors[2]
	var stripe: = rect.size.y / 13.0
	for i in 13:
		draw_rect(Rect2(rect.position.x, rect.position.y + stripe * i, 
			rect.size.x, stripe + 0.5), red if i % 2 == 0 else white)
	var canton: = Rect2(rect.position, Vector2(rect.size.x * 0.42, 
		rect.size.y * 7.0 / 13.0))
	draw_rect(canton, blue)
	var dot: = maxf(0.45, rect.size.y * 0.03)
	for row in 3:
		for col in 4:
			var p: = canton.position + Vector2(
				canton.size.x * (0.18 + col * 0.22), 
				canton.size.y * (0.2 + row * 0.3))
			draw_circle(p, dot, white)


func _draw_uk(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	var blue: Color = colors[0]
	var white: Color = colors[1]
	var red: Color = colors[2]
	draw_rect(rect, blue)
	var w: = maxf(1.0, rect.size.y * 0.2)
	var rw: = maxf(1.0, rect.size.y * 0.1)
	var p0: = rect.position
	var p1: = rect.position + Vector2(rect.size.x, rect.size.y)
	var p2: = rect.position + Vector2(rect.size.x, 0.0)
	var p3: = rect.position + Vector2(0.0, rect.size.y)
	draw_line(p0, p1, white, w, true)
	draw_line(p2, p3, white, w, true)
	draw_line(p0, p1, red, rw, true)
	draw_line(p2, p3, red, rw, true)
	var cx: = rect.position.x + rect.size.x * 0.5
	var cy: = rect.position.y + rect.size.y * 0.5
	draw_rect(Rect2(cx - w * 0.55, rect.position.y, w * 1.1, rect.size.y), white)
	draw_rect(Rect2(rect.position.x, cy - w * 0.55, rect.size.x, w * 1.1), white)
	draw_rect(Rect2(cx - rw * 0.55, rect.position.y, rw * 1.1, rect.size.y), red)
	draw_rect(Rect2(rect.position.x, cy - rw * 0.55, rect.size.x, rw * 1.1), red)


func _draw_sun(rect: Rect2, colors: Array) -> void :
	if colors.is_empty():
		return
	draw_rect(rect, colors[0])
	if colors.size() >= 2:
		draw_circle(rect.position + rect.size * 0.5, 
			minf(rect.size.x, rect.size.y) * 0.3, colors[1])


func _draw_solid(rect: Rect2, colors: Array) -> void :
	if colors.is_empty():
		return
	draw_rect(rect, colors[0])
	if colors.size() >= 2:
		_star(rect.position + rect.size * 0.5, 
			minf(rect.size.x, rect.size.y) * 0.2, colors[1])


func _draw_cn(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	var gold: Color = colors[1]
	var unit: = minf(rect.size.x, rect.size.y)
	var main: = rect.position + Vector2(rect.size.x * 0.2, rect.size.y * 0.32)
	_star(main, unit * 0.2, gold)
	for offset in [Vector2(0.34, 0.16), Vector2(0.4, 0.3), 
			Vector2(0.38, 0.46), Vector2(0.28, 0.56)]:
		_star(rect.position + Vector2(rect.size.x * offset.x, 
			rect.size.y * offset.y), unit * 0.075, gold)


func _draw_br(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	var c: = rect.position + rect.size * 0.5
	var pts: = PackedVector2Array([
		Vector2(c.x, rect.position.y + rect.size.y * 0.12), 
		Vector2(rect.position.x + rect.size.x * 0.88, c.y), 
		Vector2(c.x, rect.position.y + rect.size.y * 0.88), 
		Vector2(rect.position.x + rect.size.x * 0.12, c.y), 
	])
	draw_colored_polygon(pts, colors[1])
	draw_circle(c, minf(rect.size.x, rect.size.y) * 0.26, colors[2])
	draw_rect(Rect2(c.x - rect.size.x * 0.24, c.y - rect.size.y * 0.035, 
		rect.size.x * 0.48, rect.size.y * 0.07), Color(0.97, 0.97, 0.97, 0.92))


func _draw_ca(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	var red: Color = colors[0]
	var white: Color = colors[1]
	var side: = rect.size.x * 0.25
	draw_rect(rect, white)
	draw_rect(Rect2(rect.position, Vector2(side, rect.size.y)), red)
	draw_rect(Rect2(rect.position + Vector2(rect.size.x - side, 0.0), 
		Vector2(side, rect.size.y)), red)
	var c: = rect.position + rect.size * 0.5
	var r: = minf(rect.size.x, rect.size.y) * 0.34
	var leaf: = PackedVector2Array()
	for point in [
		Vector2(0.0, -1.0), Vector2(0.18, -0.55), Vector2(0.55, -0.75), 
		Vector2(0.45, -0.25), Vector2(1.0, -0.1), Vector2(0.55, 0.15), 
		Vector2(0.7, 0.6), Vector2(0.22, 0.35), Vector2(0.12, 1.0), 
		Vector2(0.0, 0.68), Vector2(-0.12, 1.0), Vector2(-0.22, 0.35), 
		Vector2(-0.7, 0.6), Vector2(-0.55, 0.15), Vector2(-1.0, -0.1), 
		Vector2(-0.45, -0.25), Vector2(-0.55, -0.75), Vector2(-0.18, -0.55), 
	]:
		leaf.append(c + point * r)
	draw_colored_polygon(leaf, red)


func _draw_tr(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	var white: Color = colors[1]
	var c: = rect.position + rect.size * 0.5
	var unit: = minf(rect.size.x, rect.size.y)
	draw_circle(Vector2(c.x - unit * 0.1, c.y), unit * 0.3, white)
	draw_circle(Vector2(c.x - unit * 0.01, c.y), unit * 0.24, colors[0])
	_star(Vector2(c.x + unit * 0.28, c.y), unit * 0.15, white)


func _draw_in(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[2]], false)
	draw_arc(rect.position + rect.size * 0.5, 
		minf(rect.size.x, rect.size.y) * 0.19, 0.0, TAU, 28, colors[3], 
		maxf(0.6, rect.size.y * 0.035), true)


func _draw_cz(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * 0.5)), 
		colors[0])
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y * 0.5), 
		Vector2(rect.size.x, rect.size.y * 0.5)), colors[1])
	draw_colored_polygon(PackedVector2Array([
		rect.position, 
		rect.position + Vector2(rect.size.x * 0.52, rect.size.y * 0.5), 
		rect.position + Vector2(0.0, rect.size.y), 
	]), colors[2])


func _draw_pt(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	var split: = rect.size.x * 0.4
	draw_rect(Rect2(rect.position, Vector2(split, rect.size.y)), colors[0])
	draw_rect(Rect2(rect.position + Vector2(split, 0.0), 
		Vector2(rect.size.x - split, rect.size.y)), colors[1])
	var c: = rect.position + Vector2(split, rect.size.y * 0.5)
	draw_circle(c, minf(rect.size.x, rect.size.y) * 0.22, colors[2])


func _draw_gr(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	var blue: Color = colors[0]
	var white: Color = colors[1]
	var stripe: = rect.size.y / 9.0
	for i in 9:
		draw_rect(Rect2(rect.position.x, rect.position.y + stripe * i, 
			rect.size.x, stripe + 0.4), blue if i % 2 == 0 else white)
	var canton: = Rect2(rect.position, Vector2(rect.size.x * 0.37, 
		stripe * 5.0))
	draw_rect(canton, blue)
	var t: = stripe * 1.2
	draw_rect(Rect2(canton.position.x + canton.size.x * 0.5 - t * 0.5, 
		canton.position.y, t, canton.size.y), white)
	draw_rect(Rect2(canton.position.x, canton.position.y + canton.size.y * 0.5
		- t * 0.5, canton.size.x, t), white)


func _draw_ae(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	var left: = rect.size.x * 0.26
	draw_rect(Rect2(rect.position, Vector2(left, rect.size.y)), colors[0])
	var rest: = Rect2(rect.position + Vector2(left, 0.0), 
		Vector2(rect.size.x - left, rect.size.y))
	_draw_stripes(rest, [colors[1], colors[2], colors[3]], false)


func _draw_cl(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * 0.5)), 
		colors[0])
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y * 0.5), 
		Vector2(rect.size.x, rect.size.y * 0.5)), colors[1])
	var canton: = Rect2(rect.position, Vector2(rect.size.x * 0.4, 
		rect.size.y * 0.5))
	draw_rect(canton, colors[2])
	_star(canton.position + canton.size * 0.5, 
		minf(canton.size.x, canton.size.y) * 0.3, colors[0])


func _draw_ph(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * 0.5)), 
		colors[0])
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y * 0.5), 
		Vector2(rect.size.x, rect.size.y * 0.5)), colors[1])
	draw_colored_polygon(PackedVector2Array([
		rect.position, 
		rect.position + Vector2(rect.size.x * 0.52, rect.size.y * 0.5), 
		rect.position + Vector2(0.0, rect.size.y), 
	]), colors[2])
	draw_circle(rect.position + Vector2(rect.size.x * 0.17, rect.size.y * 0.5), 
		minf(rect.size.x, rect.size.y) * 0.12, colors[3])


func _draw_il(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	var white: Color = colors[0]
	var blue: Color = colors[1]
	draw_rect(rect, white)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * 0.14)), 
		blue)
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y * 0.86), 
		Vector2(rect.size.x, rect.size.y * 0.14)), blue)
	var c: = rect.position + rect.size * 0.5
	var r: = minf(rect.size.x, rect.size.y) * 0.26
	var width: = maxf(0.6, rect.size.y * 0.035)
	var up: = PackedVector2Array()
	var down: = PackedVector2Array()
	for i in 3:
		var a: = - PI * 0.5 + TAU * float(i) / 3.0
		var b: = - PI * 0.5 + TAU * float(i + 1) / 3.0
		up.append(c + Vector2(cos(a), sin(a)) * r)
		up.append(c + Vector2(cos(b), sin(b)) * r)
		down.append(c + Vector2(cos(a + PI), sin(a + PI)) * r)
		down.append(c + Vector2(cos(b + PI), sin(b + PI)) * r)
	up.append(up[0])
	up.append(up[1])
	down.append(down[0])
	down.append(down[1])
	draw_polyline(up, blue, width, true)
	draw_polyline(down, blue, width, true)


func _draw_ar(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[0]], false)
	_sun(rect.position + rect.size * 0.5, _unit(rect) * 0.16, colors[2])


func _unit(rect: Rect2) -> float:
	return minf(rect.size.x, rect.size.y)




func _sun(center: Vector2, radius: float, color: Color) -> void :
	for i in 8:
		var angle: = TAU * float(i) / 8.0
		var direction: = Vector2(cos(angle), sin(angle))
		draw_line(center + direction * radius * 1.25, 
			center + direction * radius * 1.85, color, 
			maxf(0.5, radius * 0.2), true)
	draw_circle(center, radius, color)


func _draw_sunrays(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	var c: = rect.position + rect.size * 0.5
	var r: = _unit(rect) * 0.2
	for i in 16:
		var angle: = TAU * float(i) / 16.0
		var direction: = Vector2(cos(angle), sin(angle))
		draw_line(c + direction * r * 1.18, c + direction * r * 2.05, 
			colors[1], maxf(0.45, r * 0.15), true)
	draw_circle(c, r, colors[1])




func _draw_crescent(rect: Rect2, colors: Array, split: bool) -> void :
	var symbol: Color
	var cut: Color
	if split:
		if colors.size() < 3:
			return
		draw_rect(Rect2(rect.position, Vector2(rect.size.x * 0.5, 
			rect.size.y)), colors[0])
		draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.5, 0.0), 
			Vector2(rect.size.x * 0.5, rect.size.y)), colors[1])
		symbol = colors[2]
		cut = colors[1]
	else:
		if colors.size() < 2:
			return
		draw_rect(rect, colors[0])
		symbol = colors[1]
		cut = colors[0]
	var c: = rect.position + Vector2(rect.size.x * 0.46, rect.size.y * 0.5)
	var r: = _unit(rect) * 0.29
	draw_circle(c, r, symbol)
	draw_circle(c + Vector2(r * 0.34, 0.0), r * 0.82, cut)
	_star(Vector2(rect.position.x + rect.size.x * 0.7, c.y), 
		_unit(rect) * 0.12, symbol)


func _draw_crescent_disc(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	var c: = rect.position + rect.size * 0.5
	var r: = _unit(rect) * 0.33
	draw_circle(c, r, colors[1])
	var moon: = c + Vector2( - r * 0.08, 0.0)
	draw_circle(moon, r * 0.54, colors[2])
	draw_circle(moon + Vector2(r * 0.18, 0.0), r * 0.46, colors[1])
	_star(c + Vector2(r * 0.32, 0.0), r * 0.13, colors[2])



func _draw_star_stripes(rect: Rect2, colors: Array, vertical: bool) -> void :
	if colors.size() < 2:
		return
	_draw_stripes(rect, colors.slice(0, colors.size() - 1), vertical)
	_star(rect.position + rect.size * 0.5, _unit(rect) * 0.22, 
		colors[colors.size() - 1])



func _draw_tri(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[2]], false)
	draw_colored_polygon(PackedVector2Array([
		rect.position, 
		rect.position + Vector2(rect.size.x * 0.42, rect.size.y * 0.5), 
		rect.position + Vector2(0.0, rect.size.y), 
	]), colors[3])
	if colors.size() >= 5:
		_star(rect.position + Vector2(rect.size.x * 0.14, rect.size.y * 0.5), 
			_unit(rect) * 0.1, colors[4])




func _draw_diag(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	var band: Color
	var outline: Color
	if colors.size() >= 4:
		draw_rect(rect, colors[0])
		draw_colored_polygon(PackedVector2Array([
			rect.position + Vector2(rect.size.x, 0.0), 
			rect.position + rect.size, 
			rect.position + Vector2(0.0, rect.size.y), 
		]), colors[1])
		band = colors[2]
		outline = colors[3]
	else:
		draw_rect(rect, colors[0])
		band = colors[1]
		outline = colors[2]
	var a: = rect.position + Vector2(0.0, rect.size.y)
	var b: = rect.position + Vector2(rect.size.x, 0.0)
	draw_line(a, b, outline, rect.size.y * 0.46, true)
	draw_line(a, b, band, rect.size.y * 0.26, true)



func _draw_serrated(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	var base: = rect.size.x * 0.34
	var tip: = rect.size.x * 0.22
	var points: = PackedVector2Array()
	points.append(rect.position + Vector2(base, 0.0))
	for i in range(1, 9):
		var x: = tip if i % 2 == 1 else base
		points.append(rect.position + Vector2(x, 
			rect.size.y * float(i) / 8.0))
	points.append(rect.position + Vector2(rect.size.x, rect.size.y))
	points.append(rect.position + Vector2(rect.size.x, 0.0))
	draw_colored_polygon(points, colors[1])


func _draw_jm(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	var c: = rect.position + rect.size * 0.5
	draw_colored_polygon(PackedVector2Array([
		rect.position, rect.position + Vector2(0.0, rect.size.y), c]), colors[1])
	draw_colored_polygon(PackedVector2Array([
		rect.position + Vector2(rect.size.x, 0.0), 
		rect.position + rect.size, c]), colors[1])
	var gold: Color = colors[2] if colors.size() >= 3 else Color(1.0, 0.78, 0.16)
	var width: = maxf(1.0, rect.size.y * 0.12)
	draw_line(rect.position, rect.position + rect.size, gold, width, true)
	draw_line(rect.position + Vector2(rect.size.x, 0.0), 
		rect.position + Vector2(0.0, rect.size.y), gold, width, true)


func _draw_pa(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	var w: = rect.size.x
	var h: = rect.size.y
	draw_rect(Rect2(rect.position, Vector2(w * 0.5, h * 0.5)), colors[0])
	draw_rect(Rect2(rect.position + Vector2(w * 0.5, 0.0), 
		Vector2(w * 0.5, h * 0.5)), colors[1])
	draw_rect(Rect2(rect.position + Vector2(0.0, h * 0.5), 
		Vector2(w * 0.5, h * 0.5)), colors[2])
	draw_rect(Rect2(rect.position + Vector2(w * 0.5, h * 0.5), 
		Vector2(w * 0.5, h * 0.5)), colors[3])
	_star(rect.position + Vector2(w * 0.25, h * 0.25), _unit(rect) * 0.14, 
		colors[2])
	_star(rect.position + Vector2(w * 0.75, h * 0.75), _unit(rect) * 0.14, 
		colors[1])


func _draw_do(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	var w: = rect.size.x
	var h: = rect.size.y
	draw_rect(Rect2(rect.position, Vector2(w * 0.5, h * 0.5)), colors[0])
	draw_rect(Rect2(rect.position + Vector2(w * 0.5, 0.0), 
		Vector2(w * 0.5, h * 0.5)), colors[1])
	draw_rect(Rect2(rect.position + Vector2(0.0, h * 0.5), 
		Vector2(w * 0.5, h * 0.5)), colors[1])
	draw_rect(Rect2(rect.position + Vector2(w * 0.5, h * 0.5), 
		Vector2(w * 0.5, h * 0.5)), colors[0])
	var t: = maxf(1.0, h * 0.12)
	draw_rect(Rect2(rect.position.x + w * 0.5 - t * 0.5, rect.position.y, 
		t, h), colors[2])
	draw_rect(Rect2(rect.position.x, rect.position.y + h * 0.5 - t * 0.5, 
		w, t), colors[2])


func _draw_uy(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	var white: Color = colors[0]
	var blue: Color = colors[1]
	var stripe: = rect.size.y / 9.0
	for i in 9:
		draw_rect(Rect2(rect.position.x, rect.position.y + stripe * i, 
			rect.size.x, stripe + 0.4), white if i % 2 == 0 else blue)
	var canton: = Rect2(rect.position, Vector2(rect.size.x * 0.42, 
		rect.size.y * 0.55))
	draw_rect(canton, white)
	var gold: Color = colors[2] if colors.size() < 4 else colors[3]
	_sun(canton.position + canton.size * 0.5, canton.size.y * 0.24, gold)


func _draw_ve(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[2]], false)
	var c: = rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.62)
	var radius: = rect.size.x * 0.24
	for i in 8:
		var angle: = - PI * 0.85 + PI * 0.7 * float(i) / 7.0
		_star(c + Vector2(cos(angle), sin(angle)) * radius, 
			_unit(rect) * 0.045, colors[3])


func _draw_cu(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	var stripe: = rect.size.y / 5.0
	for i in 5:
		draw_rect(Rect2(rect.position.x, rect.position.y + stripe * i, 
			rect.size.x, stripe + 0.4), 
			colors[0] if i % 2 == 0 else colors[1])
	draw_colored_polygon(PackedVector2Array([
		rect.position, 
		rect.position + Vector2(rect.size.x * 0.45, rect.size.y * 0.5), 
		rect.position + Vector2(0.0, rect.size.y), 
	]), colors[2])
	if colors.size() >= 4:
		_star(rect.position + Vector2(rect.size.x * 0.15, rect.size.y * 0.5), 
			_unit(rect) * 0.11, colors[3])


func _draw_za(rect: Rect2, colors: Array) -> void :
	if colors.size() < 5:
		return
	var w: = rect.size.x
	var h: = rect.size.y
	draw_rect(Rect2(rect.position, Vector2(w, h / 3.0)), colors[0])
	draw_rect(Rect2(rect.position + Vector2(0.0, h / 3.0), 
		Vector2(w, h / 3.0)), colors[1])
	draw_rect(Rect2(rect.position + Vector2(0.0, h * 2.0 / 3.0), 
		Vector2(w, h / 3.0)), colors[2])
	var gold: Color = colors[4]
	var white: Color = colors[3]
	var mid: = rect.position + Vector2(0.0, h * 0.5)
	var top: = rect.position + Vector2(w, 0.0)
	var bottom: = rect.position + Vector2(w, h)
	draw_line(mid, top, white, h * 0.2, true)
	draw_line(mid, bottom, white, h * 0.2, true)
	draw_line(mid, top, colors[1], h * 0.11, true)
	draw_line(mid, bottom, colors[1], h * 0.11, true)
	draw_colored_polygon(PackedVector2Array([
		rect.position, rect.position + Vector2(w * 0.34, h * 0.5), 
		rect.position + Vector2(0.0, h)]), gold)
	draw_colored_polygon(PackedVector2Array([
		rect.position, rect.position + Vector2(w * 0.26, h * 0.5), 
		rect.position + Vector2(0.0, h)]), Color(0.1, 0.1, 0.12))


func _draw_pk(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	var strip: = rect.size.x * 0.25
	draw_rect(Rect2(rect.position, Vector2(strip, rect.size.y)), colors[1])
	var c: = rect.position + Vector2(rect.size.x * 0.62, rect.size.y * 0.5)
	var r: = _unit(rect) * 0.28
	var white: Color = colors[1]
	draw_circle(c, r, white)
	draw_circle(c + Vector2(r * 0.32, 0.0), r * 0.82, colors[0])
	_star(c + Vector2(r * 0.52, 0.0), r * 0.34, white)


func _draw_bd(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	draw_circle(rect.position + Vector2(rect.size.x * 0.44, rect.size.y * 0.5), 
		_unit(rect) * 0.28, colors[1])


func _draw_lk(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	draw_rect(rect, colors[0])
	draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.1, 
		rect.size.y * 0.1), Vector2(rect.size.x * 0.58, 
		rect.size.y * 0.8)), colors[1])
	draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.68, 
		rect.size.y * 0.1), Vector2(rect.size.x * 0.1, 
		rect.size.y * 0.8)), colors[2])
	draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.78, 
		rect.size.y * 0.1), Vector2(rect.size.x * 0.1, 
		rect.size.y * 0.8)), colors[3])
	draw_circle(rect.position + Vector2(rect.size.x * 0.36, rect.size.y * 0.5), 
		_unit(rect) * 0.12, colors[0])


func _draw_np(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	var points: = PackedVector2Array([
		rect.position + Vector2(rect.size.x * 0.1, rect.size.y * 0.08), 
		rect.position + Vector2(rect.size.x * 0.66, rect.size.y * 0.32), 
		rect.position + Vector2(rect.size.x * 0.34, rect.size.y * 0.44), 
		rect.position + Vector2(rect.size.x * 0.78, rect.size.y * 0.7), 
		rect.position + Vector2(rect.size.x * 0.1, rect.size.y * 0.92), 
	])
	draw_colored_polygon(points, colors[0])
	var center: = Vector2.ZERO
	for point in points:
		center += point
	center /= float(points.size())
	var inner: = PackedVector2Array()
	for point in points:
		inner.append(point.lerp(center, 0.1))
	draw_colored_polygon(inner, colors[1])


func _draw_ir(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[2]], false)
	var c: = rect.position + rect.size * 0.5
	var r: = _unit(rect) * 0.15
	draw_arc(c, r, 0.0, TAU, 16, colors[2], 
		maxf(0.5, r * 0.22), true)
	draw_line(c + Vector2(0.0, - r * 1.15), c + Vector2(0.0, r * 1.15), 
		colors[2], maxf(0.5, r * 0.22), true)


func _draw_iq(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[2]], false)
	var width: = maxf(0.5, rect.size.y * 0.055)
	for i in 3:
		var x: = rect.position.x + rect.size.x * (0.34 + 0.16 * i)
		draw_line(Vector2(x, rect.position.y + rect.size.y * 0.42), 
			Vector2(x, rect.position.y + rect.size.y * 0.58), colors[3], 
			width, true)


func _draw_sy(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[2]], false)
	var r: = _unit(rect) * 0.09
	_star(rect.position + Vector2(rect.size.x * 0.42, rect.size.y * 0.5), 
		r, colors[3])
	_star(rect.position + Vector2(rect.size.x * 0.58, rect.size.y * 0.5), 
		r, colors[3])


func _draw_lb(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[0]], false, 
		[1, 2, 1])
	var c: = rect.position + rect.size * 0.5
	var h: = rect.size.y
	draw_rect(Rect2(c.x - maxf(0.5, rect.size.x * 0.018), c.y, 
		maxf(1.0, rect.size.x * 0.036), h * 0.2), colors[2])
	draw_colored_polygon(PackedVector2Array([
		Vector2(c.x, c.y - h * 0.3), 
		Vector2(c.x + rect.size.x * 0.13, c.y + h * 0.08), 
		Vector2(c.x - rect.size.x * 0.13, c.y + h * 0.08), 
	]), colors[2])
	draw_colored_polygon(PackedVector2Array([
		Vector2(c.x, c.y - h * 0.16), 
		Vector2(c.x + rect.size.x * 0.2, c.y + h * 0.18), 
		Vector2(c.x - rect.size.x * 0.2, c.y + h * 0.18), 
	]), colors[2])


func _draw_tj(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[2]], false, 
		[2, 1, 2])
	var c: = rect.position + rect.size * 0.5
	var unit: = _unit(rect)
	draw_rect(Rect2(c.x - unit * 0.13, c.y - unit * 0.04, 
		unit * 0.26, unit * 0.08), colors[3])
	for i in 3:
		var x: = c.x - unit * 0.1 + unit * 0.1 * i
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, c.y - unit * 0.04), 
			Vector2(x + unit * 0.045, c.y - unit * 0.16), 
			Vector2(x + unit * 0.09, c.y - unit * 0.04), 
		]), colors[3])
	for i in 7:
		var angle: = - PI * 0.88 + PI * 0.76 * float(i) / 6.0
		_star(c + Vector2(cos(angle), sin(angle)) * unit * 0.24, 
			unit * 0.025, colors[3])


func _draw_tm(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	draw_rect(rect, colors[0])
	var band: = Rect2(rect.position + Vector2(rect.size.x * 0.17, 0.0), 
		Vector2(rect.size.x * 0.15, rect.size.y))
	draw_rect(band, colors[1])
	for i in 3:
		var c: = band.position + Vector2(band.size.x * 0.5, 
			band.size.y * (0.24 + 0.26 * i))
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(0.0, - band.size.y * 0.07), 
			c + Vector2(band.size.x * 0.25, 0.0), 
			c + Vector2(0.0, band.size.y * 0.07), 
			c + Vector2( - band.size.x * 0.25, 0.0), 
		]), colors[2])
	var moon: = rect.position + Vector2(rect.size.x * 0.62, 
		rect.size.y * 0.32)
	var r: = _unit(rect) * 0.18
	draw_circle(moon, r, colors[3])
	draw_circle(moon + Vector2(r * 0.34, 0.0), r * 0.82, colors[0])
	for i in 5:
		_star(moon + Vector2(r * (1.1 + 0.38 * (i % 3)), 
			r * (-0.6 + 0.3 * (i / 3))), _unit(rect) * 0.035, colors[3])


func _draw_uz(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	var h: = rect.size.y
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, h * 0.3)), colors[0])
	draw_rect(Rect2(rect.position + Vector2(0.0, h * 0.3), 
		Vector2(rect.size.x, h * 0.03)), colors[3])
	draw_rect(Rect2(rect.position + Vector2(0.0, h * 0.33), 
		Vector2(rect.size.x, h * 0.34)), colors[1])
	draw_rect(Rect2(rect.position + Vector2(0.0, h * 0.67), 
		Vector2(rect.size.x, h * 0.03)), colors[3])
	draw_rect(Rect2(rect.position + Vector2(0.0, h * 0.7), 
		Vector2(rect.size.x, h * 0.3)), colors[2])
	var c: = rect.position + Vector2(rect.size.x * 0.18, h * 0.16)
	var r: = h * 0.11
	draw_circle(c, r, colors[1])
	draw_circle(c + Vector2(r * 0.36, 0.0), r * 0.82, colors[0])
	for i in 3:
		for j in 2:
			_star(rect.position + Vector2(rect.size.x * (0.3 + 0.11 * i), 
				h * (0.09 + 0.11 * j)), h * 0.035, colors[1])


func _draw_mn(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[0]], true, 
		[1, 2, 1])
	var c: = rect.position + Vector2(rect.size.x * 0.17, 
		rect.size.y * 0.5)
	var unit: = _unit(rect)
	draw_circle(c + Vector2(0.0, - unit * 0.12), unit * 0.075, colors[2])
	draw_rect(Rect2(c.x - unit * 0.02, c.y - unit * 0.05, 
		unit * 0.04, unit * 0.2), colors[2])
	draw_colored_polygon(PackedVector2Array([
		c + Vector2( - unit * 0.09, unit * 0.16), 
		c + Vector2(0.0, unit * 0.02), 
		c + Vector2(unit * 0.09, unit * 0.16), 
	]), colors[2])


func _draw_kh(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[0]], false, 
		[1, 2, 1])
	var c: = rect.position + rect.size * 0.5
	var h: = rect.size.y
	draw_rect(Rect2(c.x - rect.size.x * 0.15, c.y - h * 0.04, 
		rect.size.x * 0.3, h * 0.24), colors[2])
	for i in 3:
		var x: = c.x - rect.size.x * 0.12 + rect.size.x * 0.12 * i
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - rect.size.x * 0.035, c.y - h * 0.04), 
			Vector2(x, c.y - h * 0.2), 
			Vector2(x + rect.size.x * 0.035, c.y - h * 0.04), 
		]), colors[2])


func _draw_la(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[0]], false, 
		[1, 2, 1])
	draw_circle(rect.position + rect.size * 0.5, _unit(rect) * 0.24, 
		colors[2])


func _draw_tw(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	var canton: = Rect2(rect.position, Vector2(rect.size.x * 0.5, 
		rect.size.y * 0.5))
	draw_rect(canton, colors[1])
	var c: = canton.position + canton.size * 0.5
	var r: = canton.size.y * 0.34
	for i in 12:
		var angle: = TAU * float(i) / 12.0
		var direction: = Vector2(cos(angle), sin(angle))
		draw_line(c + direction * r * 0.9, c + direction * r * 1.4, 
			colors[2], maxf(0.45, r * 0.18), true)
	draw_circle(c, r * 0.55, colors[2])


func _draw_hk(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	var c: = rect.position + rect.size * 0.5
	var unit: = _unit(rect)
	for i in 5:
		var angle: = - PI * 0.5 + TAU * float(i) / 5.0
		draw_circle(c + Vector2(cos(angle), sin(angle)) * unit * 0.14, 
			unit * 0.1, colors[1])
	draw_circle(c, unit * 0.055, colors[0])


func _draw_sg(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * 0.5)), 
		colors[0])
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y * 0.5), 
		Vector2(rect.size.x, rect.size.y * 0.5)), colors[1])
	var c: = rect.position + Vector2(rect.size.x * 0.26, rect.size.y * 0.27)
	var r: = _unit(rect) * 0.2
	draw_circle(c, r, colors[1])
	draw_circle(c + Vector2(r * 0.34, 0.0), r * 0.82, colors[0])
	var star_c: = rect.position + Vector2(rect.size.x * 0.44, 
		rect.size.y * 0.21)
	for i in 5:
		var angle: = - PI * 0.5 + TAU * float(i) / 5.0
		_star(star_c + Vector2(cos(angle), sin(angle)) * _unit(rect) * 0.09, 
			_unit(rect) * 0.038, colors[1])


func _draw_kr(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	var c: = rect.position + rect.size * 0.5
	var r: = _unit(rect) * 0.28
	var top: = PackedVector2Array()
	var bottom: = PackedVector2Array()
	for i in 17:
		var a: = PI + PI * float(i) / 16.0
		top.append(c + Vector2(cos(a), sin(a)) * r)
		var b: = PI * float(i) / 16.0
		bottom.append(c + Vector2(cos(b), sin(b)) * r)
	draw_colored_polygon(top, colors[1])
	draw_colored_polygon(bottom, colors[2])
	draw_circle(c + Vector2( - r * 0.34, 0.0), r * 0.34, colors[1])
	draw_circle(c + Vector2(r * 0.34, 0.0), r * 0.34, colors[2])
	var bar: = maxf(0.6, rect.size.y * 0.035)
	for corner in [Vector2(0.16, 0.16), Vector2(0.84, 0.16), 
			Vector2(0.16, 0.84), Vector2(0.84, 0.84)]:
		var p: = rect.position + Vector2(rect.size.x * corner.x, 
			rect.size.y * corner.y)
		for i in 3:
			var offset: = Vector2((float(i) - 1.0) * rect.size.y * 0.09, 0.0)
			draw_line(p + offset - Vector2(rect.size.y * 0.06, 0.0), 
				p + offset + Vector2(rect.size.y * 0.06, 0.0), colors[2], 
				bar, true)


func _draw_my(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	var stripe: = rect.size.y / 7.0
	for i in 7:
		draw_rect(Rect2(rect.position.x, rect.position.y + stripe * i, 
			rect.size.x, stripe + 0.4), 
			colors[0] if i % 2 == 0 else colors[1])
	var canton: = Rect2(rect.position, Vector2(rect.size.x * 0.5, 
		rect.size.y * 0.55))
	draw_rect(canton, colors[2])
	var c: = canton.position + Vector2(canton.size.x * 0.42, 
		canton.size.y * 0.5)
	var r: = _unit(rect) * 0.16
	draw_circle(c, r, colors[3])
	draw_circle(c + Vector2(r * 0.34, 0.0), r * 0.82, colors[2])
	_star(c + Vector2(r * 0.72, 0.0), r * 0.42, colors[3])


func _draw_bn(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	draw_rect(rect, colors[0])
	draw_line(rect.position + Vector2(0.0, rect.size.y * 0.18), 
		rect.position + Vector2(rect.size.x, rect.size.y * 0.82), colors[1], 
		rect.size.y * 0.3, true)
	draw_line(rect.position + Vector2(0.0, rect.size.y * 0.18), 
		rect.position + Vector2(rect.size.x, rect.size.y * 0.82), colors[2], 
		rect.size.y * 0.14, true)
	var c: = rect.position + rect.size * 0.5
	draw_circle(c, _unit(rect) * 0.15, colors[3])
	_star(c, _unit(rect) * 0.08, colors[0])


func _draw_tl(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	draw_rect(rect, colors[0])
	draw_colored_polygon(PackedVector2Array([
		rect.position, 
		rect.position + Vector2(rect.size.x * 0.55, rect.size.y * 0.5), 
		rect.position + Vector2(0.0, rect.size.y), 
	]), colors[1])
	draw_colored_polygon(PackedVector2Array([
		rect.position + Vector2(0.0, rect.size.y * 0.25), 
		rect.position + Vector2(rect.size.x * 0.34, rect.size.y * 0.5), 
		rect.position + Vector2(0.0, rect.size.y * 0.75), 
	]), colors[2])
	_star(rect.position + Vector2(rect.size.x * 0.15, rect.size.y * 0.5), 
		_unit(rect) * 0.1, colors[3])


func _draw_mv(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	var panel: = Rect2(rect.position + Vector2(rect.size.x * 0.2, 
		rect.size.y * 0.28), Vector2(rect.size.x * 0.66, 
		rect.size.y * 0.44))
	draw_rect(panel, colors[1])
	var c: = panel.position + panel.size * 0.5
	var r: = panel.size.y * 0.34
	draw_circle(c, r, colors[2])
	draw_circle(c + Vector2(r * 0.34, 0.0), r * 0.82, colors[1])


func _draw_bt(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	draw_colored_polygon(PackedVector2Array([
		rect.position, 
		rect.position + Vector2(rect.size.x, 0.0), 
		rect.position + rect.size, 
	]), colors[1])
	var c: = rect.position + rect.size * 0.5
	var r: = _unit(rect) * 0.16
	draw_arc(c, r, - PI * 0.2, PI * 0.9, 12, colors[2], 
		maxf(0.6, r * 0.3), true)
	draw_circle(c + Vector2( - r * 0.35, - r * 0.35), r * 0.3, colors[2])


func _draw_uk_stars(rect: Rect2, colors: Array, variant: String) -> void :
	if colors.is_empty():
		return
	var field: Color = colors[0]
	draw_rect(rect, field)
	var canton: = Rect2(rect.position, Vector2(rect.size.x * 0.5, 
		rect.size.y * 0.5))
	_draw_uk(canton, [Color(0.1, 0.18, 0.48), Color(0.97, 0.97, 0.97), 
		Color(0.82, 0.12, 0.16)])
	var white: = Color(0.97, 0.97, 0.97)
	var red: = Color(0.82, 0.12, 0.16)
	var unit: = _unit(rect)
	if variant == "au":
		_star(rect.position + Vector2(rect.size.x * 0.25, rect.size.y * 0.78), 
			unit * 0.16, white)
		for spot in [Vector2(0.8, 0.2), Vector2(0.64, 0.4), 
				Vector2(0.84, 0.5), Vector2(0.68, 0.64), 
				Vector2(0.88, 0.74)]:
			_star(rect.position + Vector2(rect.size.x * spot.x, 
				rect.size.y * spot.y), unit * 0.065, white)
	elif variant == "nz":
		for spot in [Vector2(0.76, 0.22), Vector2(0.62, 0.44), 
				Vector2(0.82, 0.56), Vector2(0.7, 0.76)]:
			var p: = rect.position + Vector2(rect.size.x * spot.x, 
				rect.size.y * spot.y)
			_star(p, unit * 0.085, white)
			_star(p, unit * 0.055, red)
	else:
		var shield: = Rect2(rect.position + Vector2(rect.size.x * 0.62, 
			rect.size.y * 0.3), Vector2(rect.size.x * 0.3, 
			rect.size.y * 0.42))
		draw_rect(shield, white)
		draw_rect(Rect2(shield.position + Vector2(shield.size.x * 0.42, 0.0), 
			Vector2(shield.size.x * 0.16, shield.size.y)), red)
		draw_rect(Rect2(shield.position + Vector2(0.0, shield.size.y * 0.42), 
			Vector2(shield.size.x, shield.size.y * 0.16)), red)


func _draw_pg(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	draw_colored_polygon(PackedVector2Array([
		rect.position + Vector2(0.0, rect.size.y), 
		rect.position + rect.size, 
		rect.position + Vector2(rect.size.x, 0.0), 
	]), colors[1])
	var white: Color = colors[2]
	for spot in [Vector2(0.78, 0.22), Vector2(0.66, 0.42), 
			Vector2(0.86, 0.48), Vector2(0.72, 0.62), Vector2(0.9, 0.72)]:
		_star(rect.position + Vector2(rect.size.x * spot.x, 
			rect.size.y * spot.y), _unit(rect) * 0.055, white)
	draw_colored_polygon(PackedVector2Array([
		rect.position + Vector2(rect.size.x * 0.24, rect.size.y * 0.4), 
		rect.position + Vector2(rect.size.x * 0.42, rect.size.y * 0.62), 
		rect.position + Vector2(rect.size.x * 0.18, rect.size.y * 0.68), 
	]), colors[3] if colors.size() >= 4 else Color(1.0, 0.8, 0.16))


func _draw_ws(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	var canton: = Rect2(rect.position, Vector2(rect.size.x * 0.44, 
		rect.size.y * 0.56))
	draw_rect(canton, colors[1])
	for i in 5:
		var angle: = - PI * 0.5 + TAU * float(i) / 5.0
		_star(canton.position + canton.size * 0.5
			+ Vector2(cos(angle), sin(angle)) * canton.size.y * 0.24, 
			canton.size.y * 0.1, colors[2])


func _draw_to(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	var canton: = Rect2(rect.position, Vector2(rect.size.x * 0.44, 
		rect.size.y * 0.56))
	draw_rect(canton, colors[1])
	var t: = maxf(1.0, rect.size.y * 0.1)
	draw_rect(Rect2(canton.position.x + canton.size.x * 0.5 - t * 0.5, 
		canton.position.y, t, canton.size.y), colors[2])
	draw_rect(Rect2(canton.position.x, canton.position.y + canton.size.y * 0.5
		- t * 0.5, canton.size.x, t), colors[2])


func _draw_vu(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * 0.5)), 
		colors[0])
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y * 0.5), 
		Vector2(rect.size.x, rect.size.y * 0.5)), colors[1])
	var mid: = rect.position + Vector2(0.0, rect.size.y * 0.5)
	var top: = rect.position + Vector2(rect.size.x, 0.0)
	var bottom: = rect.position + rect.size
	draw_line(mid, top, colors[3], rect.size.y * 0.16, true)
	draw_line(mid, bottom, colors[3], rect.size.y * 0.16, true)
	draw_line(mid, top, colors[2], rect.size.y * 0.1, true)
	draw_line(mid, bottom, colors[2], rect.size.y * 0.1, true)
	draw_colored_polygon(PackedVector2Array([
		rect.position, rect.position + Vector2(rect.size.x * 0.3, 
		rect.size.y * 0.5), rect.position + Vector2(0.0, rect.size.y), 
	]), Color(0.1, 0.1, 0.12))
	draw_circle(rect.position + Vector2(rect.size.x * 0.12, 
		rect.size.y * 0.5), _unit(rect) * 0.12, colors[3])


func _draw_bb(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[0]], true)
	var c: = rect.position + rect.size * 0.5
	var unit: = _unit(rect)
	draw_rect(Rect2(c.x - unit * 0.025, c.y - unit * 0.24, 
		unit * 0.05, unit * 0.48), colors[2])
	for i in 3:
		var x: = c.x + (float(i) - 1.0) * unit * 0.09
		draw_line(Vector2(x, c.y - unit * 0.22), 
			Vector2(x, c.y - unit * 0.06), colors[2], 
			maxf(0.6, unit * 0.035), true)
		draw_line(Vector2(x, c.y - unit * 0.06), c, colors[2], 
			maxf(0.6, unit * 0.035), true)


func _draw_bs(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[0]], false, 
		[1, 2, 1])
	draw_colored_polygon(PackedVector2Array([
		rect.position, 
		rect.position + Vector2(rect.size.x * 0.42, rect.size.y * 0.5), 
		rect.position + Vector2(0.0, rect.size.y), 
	]), colors[2])


func _draw_bz(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * 0.14)), 
		colors[1])
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y * 0.86), 
		Vector2(rect.size.x, rect.size.y * 0.14)), colors[1])
	var c: = rect.position + rect.size * 0.5
	var r: = _unit(rect) * 0.24
	draw_circle(c, r, colors[2])
	draw_arc(c, r * 0.82, 0.0, TAU, 18, colors[3] if colors.size() >= 4
		else Color(0.16, 0.55, 0.26), maxf(0.5, r * 0.18), true)


func _draw_ug(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	var stripe: = rect.size.y / 6.0
	for i in 6:
		draw_rect(Rect2(rect.position.x, rect.position.y + stripe * i, 
			rect.size.x, stripe + 0.4), colors[i % 3])
	var c: = rect.position + rect.size * 0.5
	var r: = _unit(rect) * 0.2
	draw_circle(c, r, colors[3] if colors.size() >= 4
		else Color(0.97, 0.97, 0.97))
	draw_circle(c, r * 0.28, Color(0.55, 0.55, 0.58))
	draw_line(c + Vector2( - r * 0.7, 0.0), c + Vector2(r * 0.7, 0.0), 
		Color(0.55, 0.55, 0.58), maxf(0.5, r * 0.2), true)


func _draw_zw(rect: Rect2, colors: Array) -> void :
	if colors.size() < 5:
		return
	var band: = rect.size.y / 7.0
	var order: = [colors[0], colors[1], colors[2], colors[3], colors[2], 
		colors[1], colors[0]]
	for i in 7:
		draw_rect(Rect2(rect.position.x, rect.position.y + band * i, 
			rect.size.x, band + 0.4), order[i])
	draw_colored_polygon(PackedVector2Array([
		rect.position, 
		rect.position + Vector2(rect.size.x * 0.42, rect.size.y * 0.5), 
		rect.position + Vector2(0.0, rect.size.y), 
	]), Color(0.97, 0.97, 0.97))
	_star(rect.position + Vector2(rect.size.x * 0.14, rect.size.y * 0.5), 
		_unit(rect) * 0.1, colors[4])


func _draw_zm(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	draw_rect(rect, colors[0])
	for i in 3:
		draw_rect(Rect2(rect.position + Vector2(rect.size.x * (0.6 + 0.11 * i), 
			rect.size.y * 0.34), Vector2(rect.size.x * 0.09, 
			rect.size.y * 0.54)), colors[i + 1])
	var eagle: = rect.position + Vector2(rect.size.x * 0.8, rect.size.y * 0.25)
	draw_colored_polygon(PackedVector2Array([
		eagle + Vector2( - rect.size.x * 0.16, 0.0), 
		eagle + Vector2(0.0, - rect.size.y * 0.12), 
		eagle + Vector2(rect.size.x * 0.16, 0.0), 
		eagle + Vector2(0.0, rect.size.y * 0.05), 
	]), colors[3])


func _draw_mz(rect: Rect2, colors: Array) -> void :
	if colors.size() < 5:
		return
	var h: = rect.size.y
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, h * 0.34)), 
		colors[0])
	draw_rect(Rect2(rect.position + Vector2(0.0, h * 0.34), 
		Vector2(rect.size.x, h * 0.03)), colors[3])
	draw_rect(Rect2(rect.position + Vector2(0.0, h * 0.37), 
		Vector2(rect.size.x, h * 0.26)), colors[1])
	draw_rect(Rect2(rect.position + Vector2(0.0, h * 0.63), 
		Vector2(rect.size.x, h * 0.03)), colors[3])
	draw_rect(Rect2(rect.position + Vector2(0.0, h * 0.66), 
		Vector2(rect.size.x, h * 0.34)), colors[2])
	draw_colored_polygon(PackedVector2Array([
		rect.position, 
		rect.position + Vector2(rect.size.x * 0.42, rect.size.y * 0.5), 
		rect.position + Vector2(0.0, rect.size.y), 
	]), colors[4])
	_star(rect.position + Vector2(rect.size.x * 0.14, rect.size.y * 0.5), 
		_unit(rect) * 0.1, colors[3])


func _draw_ao(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * 0.5)), 
		colors[0])
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y * 0.5), 
		Vector2(rect.size.x, rect.size.y * 0.5)), colors[1])
	var c: = rect.position + rect.size * 0.5
	draw_arc(c, _unit(rect) * 0.24, 0.0, PI, 14, colors[2], 
		maxf(0.5, _unit(rect) * 0.045), true)
	_star(c + Vector2( - _unit(rect) * 0.12, - _unit(rect) * 0.04), 
		_unit(rect) * 0.1, colors[2])


func _draw_na(rect: Rect2, colors: Array) -> void :
	if colors.size() < 5:
		return
	_draw_diag(rect, [colors[0], colors[1], colors[2], colors[3]])
	_sun(rect.position + Vector2(rect.size.x * 0.22, rect.size.y * 0.24), 
		_unit(rect) * 0.12, colors[4])


func _draw_rw(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, rect.size.y * 0.5)), 
		colors[0])
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y * 0.5), 
		Vector2(rect.size.x, rect.size.y * 0.12)), colors[1])
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y * 0.62), 
		Vector2(rect.size.x, rect.size.y * 0.38)), colors[2])
	_sun(rect.position + Vector2(rect.size.x * 0.78, rect.size.y * 0.26), 
		_unit(rect) * 0.1, colors[3])


func _draw_cd(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	draw_line(rect.position + Vector2(0.0, rect.size.y), 
		rect.position + Vector2(rect.size.x, 0.0), colors[1], 
		rect.size.y * 0.3, true)
	draw_line(rect.position + Vector2(0.0, rect.size.y), 
		rect.position + Vector2(rect.size.x, 0.0), colors[2], 
		rect.size.y * 0.16, true)
	_star(rect.position + Vector2(rect.size.x * 0.18, rect.size.y * 0.2), 
		_unit(rect) * 0.13, colors[1])


func _draw_ne(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[2]], false)
	draw_circle(rect.position + rect.size * 0.5, _unit(rect) * 0.16, colors[3])


func _draw_ec(rect: Rect2, colors: Array) -> void :
	if colors.size() < 4:
		return
	_draw_stripes(rect, [colors[0], colors[1], colors[2]], false, 
		[2, 1, 1])
	var c: = rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.58)
	var r: = _unit(rect) * 0.16
	draw_circle(c, r * 0.55, colors[3])
	draw_colored_polygon(PackedVector2Array([
		c + Vector2( - r, 0.0), c + Vector2(0.0, - r * 0.45), 
		c + Vector2(0.0, r * 0.25), 
	]), colors[3])
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(r, 0.0), c + Vector2(0.0, - r * 0.45), 
		c + Vector2(0.0, r * 0.25), 
	]), colors[3])


func _draw_ma(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	_star(rect.position + rect.size * 0.5, _unit(rect) * 0.3, colors[1])


func _draw_sa(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	var white: Color = colors[1]
	var width: = maxf(0.5, rect.size.y * 0.05)
	for i in 3:
		var y: = rect.position.y + rect.size.y * (0.24 + 0.1 * i)
		draw_line(Vector2(rect.position.x + rect.size.x * (0.28 + 0.04 * i), y), 
			Vector2(rect.position.x + rect.size.x * (0.72 - 0.04 * i), y), 
			white, width, true)
	var sy: = rect.position.y + rect.size.y * 0.6
	draw_line(Vector2(rect.position.x + rect.size.x * 0.24, sy), 
		Vector2(rect.position.x + rect.size.x * 0.76, sy), white, 
		maxf(0.6, rect.size.y * 0.075), true)
	draw_line(Vector2(rect.position.x + rect.size.x * 0.24, sy), 
		Vector2(rect.position.x + rect.size.x * 0.2, sy - rect.size.y * 0.08), 
		white, maxf(0.5, rect.size.y * 0.05), true)


func _draw_af(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	var black: Color = colors[1]
	var c: = rect.position + rect.size * 0.5
	var width: = maxf(0.5, rect.size.y * 0.045)
	draw_arc(c, _unit(rect) * 0.2, 0.0, TAU, 16, black, width, true)
	for i in 3:
		var x: = c.x + (float(i) - 1.0) * _unit(rect) * 0.11
		draw_line(Vector2(x, c.y - _unit(rect) * 0.15), 
			Vector2(x, c.y + _unit(rect) * 0.15), black, width, true)


func _draw_mk(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	var c: = rect.position + rect.size * 0.5
	var reach: = maxf(rect.size.x, rect.size.y)
	for i in 8:
		var angle: = TAU * float(i) / 8.0
		var direction: = Vector2(cos(angle), sin(angle))
		draw_line(c + direction * _unit(rect) * 0.22, c + direction * reach, 
			colors[1], _unit(rect) * 0.16, true)
	draw_circle(c, _unit(rect) * 0.28, colors[1])
	draw_circle(c, _unit(rect) * 0.22, colors[0])


func _draw_sc(rect: Rect2, colors: Array) -> void :
	if colors.size() < 5:
		return
	var origin: = rect.position + Vector2(0.0, rect.size.y)
	var steps: = 5
	for i in steps:
		var a0: = - PI * 0.5 + PI * 0.5 * float(i) / float(steps)
		var a1: = - PI * 0.5 + PI * 0.5 * float(i + 1) / float(steps)
		var p0: = _ray_edge(rect, origin, Vector2(cos(a0), sin(a0)))
		var p1: = _ray_edge(rect, origin, Vector2(cos(a1), sin(a1)))
		draw_colored_polygon(PackedVector2Array([origin, p0, p1]), 
			colors[i])


func _ray_edge(rect: Rect2, origin: Vector2, direction: Vector2) -> Vector2:
	var t: = 100000.0
	if direction.x > 0.0001:
		t = minf(t, (rect.position.x + rect.size.x - origin.x) / direction.x)
	if direction.x < -0.0001:
		t = minf(t, (rect.position.x - origin.x) / direction.x)
	if direction.y > 0.0001:
		t = minf(t, (rect.position.y + rect.size.y - origin.y) / direction.y)
	if direction.y < -0.0001:
		t = minf(t, (rect.position.y - origin.y) / direction.y)
	return origin + direction * t


func _draw_al(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	var c: = rect.position + rect.size * 0.5
	var unit: = _unit(rect)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0.0, - unit * 0.26), 
		c + Vector2(unit * 0.1, - unit * 0.02), 
		c + Vector2(unit * 0.34, unit * 0.04), 
		c + Vector2(unit * 0.12, unit * 0.16), 
		c + Vector2(0.0, unit * 0.3), 
		c + Vector2( - unit * 0.12, unit * 0.16), 
		c + Vector2( - unit * 0.34, unit * 0.04), 
		c + Vector2( - unit * 0.1, - unit * 0.02), 
	]), colors[1])
	draw_circle(c + Vector2( - unit * 0.06, - unit * 0.27), unit * 0.05, 
		colors[1])
	draw_circle(c + Vector2(unit * 0.06, - unit * 0.27), unit * 0.05, 
		colors[1])


func _draw_ba(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	draw_colored_polygon(PackedVector2Array([
		rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.16), 
		rect.position + Vector2(rect.size.x * 0.86, rect.size.y), 
		rect.position + Vector2(rect.size.x * 0.14, rect.size.y), 
	]), colors[1])
	for i in 5:
		var f: = 0.14 + 0.72 * float(i) / 4.0
		var p: = Vector2(
			rect.position.x + rect.size.x * (0.5 - 0.36 * f), 
			rect.position.y + rect.size.y * (0.16 + 0.84 * f))
		_star(p, _unit(rect) * 0.055, colors[2])


func _draw_me(rect: Rect2, colors: Array) -> void :
	if colors.size() < 2:
		return
	draw_rect(rect, colors[0])
	draw_rect(rect.grow( - maxf(1.0, rect.size.y * 0.08)), colors[1], false, 
		maxf(1.0, rect.size.y * 0.08))
	var c: = rect.position + rect.size * 0.5
	var unit: = _unit(rect)
	draw_circle(c, unit * 0.12, colors[1])
	draw_colored_polygon(PackedVector2Array([
		c + Vector2( - unit * 0.1, 0.0), 
		c + Vector2( - unit * 0.32, unit * 0.1), 
		c + Vector2( - unit * 0.12, unit * 0.14), 
	]), colors[1])
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(unit * 0.1, 0.0), 
		c + Vector2(unit * 0.32, unit * 0.1), 
		c + Vector2(unit * 0.12, unit * 0.14), 
	]), colors[1])


func _draw_mt(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * 0.5, rect.size.y)), 
		colors[0])
	draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.5, 0.0), 
		Vector2(rect.size.x * 0.5, rect.size.y)), colors[1])
	var canton: = Rect2(rect.position, Vector2(rect.size.x * 0.5, 
		rect.size.y * 0.5))
	var t: = maxf(1.0, canton.size.y * 0.22)
	var c: = canton.position + canton.size * 0.5
	draw_rect(Rect2(c.x - t * 0.5, canton.position.y, t, canton.size.y), 
		colors[2])
	draw_rect(Rect2(canton.position.x, c.y - t * 0.5, canton.size.x, t), 
		colors[2])


func _draw_cy(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	var c: = rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.42)
	var points: = PackedVector2Array()
	for i in 12:
		var angle: = TAU * float(i) / 12.0
		points.append(c + Vector2(cos(angle) * rect.size.x * 0.28, 
			sin(angle) * rect.size.y * 0.14))
	draw_colored_polygon(points, colors[1])
	for side in [-1.0, 1.0]:
		var arc_c: = c + Vector2(side * rect.size.x * 0.18, 
			rect.size.y * 0.22)
		draw_arc(arc_c, rect.size.y * 0.12, - PI * 0.9, PI * 0.9, 10, 
			colors[2], maxf(0.5, rect.size.y * 0.04), true)


func _draw_xk(rect: Rect2, colors: Array) -> void :
	if colors.size() < 3:
		return
	draw_rect(rect, colors[0])
	var c: = rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.58)
	var unit: = _unit(rect)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2( - unit * 0.18, - unit * 0.16), 
		c + Vector2( - unit * 0.06, - unit * 0.22), 
		c + Vector2(unit * 0.1, - unit * 0.14), 
		c + Vector2(unit * 0.18, unit * 0.02), 
		c + Vector2(unit * 0.06, unit * 0.18), 
		c + Vector2( - unit * 0.1, unit * 0.14), 
	]), colors[1])
	for i in 6:
		var angle: = PI * (0.14 + 0.72 * float(i) / 5.0)
		_star(rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.22)
			+ Vector2(cos(angle), sin(angle)) * unit * 0.18, 
			unit * 0.045, colors[2])


func _draw_globe(rect: Rect2) -> void :
	draw_rect(rect, Color(0.12, 0.14, 0.17, 1.0))
	var c: = rect.position + rect.size * 0.5
	var r: = minf(rect.size.x, rect.size.y) * 0.32
	var line: = Color(0.72, 0.76, 0.8, 0.9)
	draw_arc(c, r, 0.0, TAU, 20, line, maxf(0.6, r * 0.12), true)
	draw_line(c + Vector2( - r, 0.0), c + Vector2(r, 0.0), line, 
		maxf(0.5, r * 0.1), true)
	draw_arc(c, r * 0.45, - PI * 0.5, PI * 0.5, 12, line, 
		maxf(0.5, r * 0.1), true)
	draw_arc(c, r * 0.45, PI * 0.5, PI * 1.5, 12, line, 
		maxf(0.5, r * 0.1), true)


func _star(center: Vector2, radius: float, color: Color) -> void :
	var points: = PackedVector2Array()
	for i in 10:
		var r: = radius if i % 2 == 0 else radius * 0.42
		var angle: = - PI * 0.5 + PI * float(i) / 5.0
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, color)
