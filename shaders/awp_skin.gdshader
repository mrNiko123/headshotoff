shader_type spatial;

// AWP HEADSHOT: палитровая текстура модели плюс оттенок скина.
// Палитра состоит из плоских ячеек, поэтому цвет корпуса крутится по HSV:
// серый металл почти не меняется, а зелёный корпус становится оранжевым
// (DRAGON) или холодным (ARCTIC), не превращаясь в сплошную заливку.

render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_tex : source_color, filter_linear, repeat_enable;
uniform float hue_shift : hint_range(-0.5, 0.5) = 0.0;
uniform float saturation_value : hint_range(0.0, 2.0) = 1.0;
uniform float value_scale : hint_range(0.0, 2.0) = 1.0;
uniform float emission_boost : hint_range(0.0, 1.0) = 0.10;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.46;
uniform float metallic_value : hint_range(0.0, 1.0) = 0.08;
// Мягкий блик по силуэту: у низкополигонального корпуса грани плоские,
// и без него тёмные ячейки палитры читаются как дыры в модели.
uniform float rim_strength : hint_range(0.0, 1.0) = 0.12;
// Минимальная яркость альбедо: почти чёрные ячейки палитры (металл
// ствола и планки) иначе не ловят ни ключ, ни заполняющий свет.
uniform float dark_lift : hint_range(0.0, 0.2) = 0.022;
// Перекраска оружия из меню цветов. Цвет накладывается поверх палитры,
// сохраняя её рисунок: яркие ячейки окрашиваются сильнее, тёмный металл
// остаётся тёмным. `paint_amount` = 0 возвращает исходный скин.
uniform vec4 paint_color : source_color = vec4(0.0);
uniform float paint_amount : hint_range(0.0, 1.0) = 0.0;

vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec3 tex = texture(albedo_tex, UV).rgb;
	vec3 hsv = rgb_to_hsv(tex);
	hsv.x = fract(hsv.x + hue_shift);
	hsv.y = clamp(hsv.y * saturation_value, 0.0, 1.0);
	hsv.z = clamp(hsv.z * value_scale, 0.0, 1.0);
	vec3 col = hsv_to_rgb(hsv);
	// Перекраска: к выбранному цвету примешивается столько же светотени,
	// сколько было в палитре, поэтому корпус не превращается в заливку.
	float luma = clamp(dot(col, vec3(0.299, 0.587, 0.114)), 0.0, 1.0);
	vec3 paint = paint_color.rgb * clamp(0.45 + 0.80 * luma, 0.0, 1.0);
	col = mix(col, paint, paint_amount);
	// Поднимаем только самые тёмные ячейки: палитра не меняется, но металл
	// перестаёт быть абсолютно чёрным силуэтом.
	vec3 lifted = max(col, vec3(dark_lift));
	ALBEDO = lifted;
	// Слабая эмиссия вытягивает силуэт из черноты, не делая оружие неоновым.
	// Контровой блик ловят рёбра корпуса даже там, где ключ не достаёт.
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float rim = pow(1.0 - facing, 3.0);
	EMISSION = lifted * emission_boost + lifted * rim * rim_strength;
	ROUGHNESS = roughness_value;
	METALLIC = metallic_value;
}
