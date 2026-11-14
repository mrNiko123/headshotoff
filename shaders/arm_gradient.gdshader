shader_type spatial;

// Рука HEADSHOT: один BoxMesh, у которого кисть и рукав отличаются только цветом.
// Градиент идёт по локальной оси Y бокса (от кисти к плечу).

render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 sleeve_color : source_color = vec4(0.190, 0.203, 0.224, 1.0);
uniform vec4 glove_color : source_color = vec4(0.238, 0.226, 0.208, 1.0);
uniform float half_length = 0.32;
uniform float glove_span = 0.34;
uniform float fade_span = 0.09;
// 0 — мягкий градиент кисть→рукав, 1 — резкая граница, как у перчатки.
uniform float sharp_split : hint_range(0.0, 1.0) = 0.0;
// Тёмная манжета на стыке: без неё резкая граница выглядит просто сменой
// цвета, а с ней читается как край перчатки.
uniform float cuff_strength : hint_range(0.0, 1.0) = 0.55;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.72;
uniform float metallic_value : hint_range(0.0, 1.0) = 0.0;
// Полуширина и полуглубина бокса: нужны, чтобы закрасить грань как
// круглое предплечье, а не как плоскую карточку.
uniform float half_width = 0.07;
uniform float half_depth = 0.07;

// Пользовательские цвета рук по умолчанию тёмные (около 0.03 в линейном
// пространстве), поэтому даже при ярком ключе рука читалась как чёрное
// пятно без света. boost поднимает альбедо до рабочего диапазона, не меняя
// оттенок, а shadow_lift даёт минимальную подсветку, чтобы тень на руке
// оставалась тенью, но не проваливалась в уголь.
uniform float albedo_boost : hint_range(0.5, 3.0) = 1.45;
uniform float shadow_lift : hint_range(0.0, 0.5) = 0.06;
// Минимальная яркость альбедо. Если игрок выбрал чисто чёрную перчатку
// (например, 0,0,0), умножение на boost и shadow_lift не давало ничего:
// рука оставалась чёрным силуэтом без света и формы. Пол окна возвращает
// такой цвет в тёмно-серый, который снова ловит свет.
uniform float min_albedo : hint_range(0.0, 0.12) = 0.040;
// Мягкий контровой «блик» по силуэту: рука перестаёт быть плоским
// прямоугольником и ловит свет даже там, где ключ её не достаёт.
uniform float rim_strength : hint_range(0.0, 1.0) = 0.18;
// Насколько тёмными выглядят рёбра коробки. Без этого грань руки
// заливалась одним цветом и читалась плоской полосой.
uniform float edge_shade : hint_range(0.0, 1.0) = 0.34;

varying float local_y;
varying float local_x;
varying float local_z;
varying vec3 local_normal;

void vertex() {
	local_y = VERTEX.y;
	local_x = VERTEX.x;
	local_z = VERTEX.z;
	local_normal = NORMAL;
}

void fragment() {
	float total = max(half_length * 2.0, 0.0001);
	// Локальная +Y смотрит от кисти к локтю: кисть у оружия, рукав уходит вниз.
	float split = -half_length + total * glove_span;
	float fade = max(total * fade_span, 0.002);
	float soft_k = smoothstep(split - fade, split + fade, local_y);
	float hard_k = step(split, local_y);
	float k = mix(soft_k, hard_k, sharp_split);
	vec3 col = mix(glove_color.rgb, sleeve_color.rgb, k);
	// Резкий переход получает узкую тёмную манжету на стыке.
	float seam = 1.0 - smoothstep(0.0, max(total * 0.035, 0.004),
		abs(local_y - split));
	col *= 1.0 - seam * sharp_split * cuff_strength;
	vec3 lifted = clamp(col * albedo_boost, vec3(0.0), vec3(1.0));

	// Какая грань бокса видна, поперёк неё и считаем «круглость».
	float across;
	if (abs(local_normal.z) > abs(local_normal.x)) {
		across = clamp(local_x / max(half_width, 0.0001), -1.0, 1.0);
	} else {
		across = clamp(local_z / max(half_depth, 0.0001), -1.0, 1.0);
	}
	float round_shade = sqrt(max(0.0, 1.0 - across * across));
	// К рёбрам грань темнеет: коробка читается как круглое предплечье.
	float form = mix(1.0 - edge_shade, 1.0, round_shade);
	// И немного темнее к локтю, чтобы рука не была залита ровным светом.
	float along = clamp((local_y + half_length) / total, 0.0, 1.0);
	form *= mix(1.0, 0.88, along);

	// Пол по цвету: даже чёрная перчатка получает тёмно-серую основу,
	// на которой видны и свет, и форма предплечья.
	vec3 shaded = max(lifted, vec3(min_albedo)) * form;

	// Мягкий градиент на тёмной руке в 8-битном буфере даёт ступеньки.
	// Дизеринг на пол-уровня разбивает их, поэтому «полоски» не читаются.
	float dither = (fract(sin(dot(FRAGCOORD.xy, vec2(12.9898, 78.233)))
		* 43758.5453) - 0.5) / 255.0;
	ALBEDO = clamp(shaded + dither, vec3(0.0), vec3(1.0));
	ROUGHNESS = roughness_value;
	METALLIC = metallic_value;
	// NORMAL и VIEW в spatial-шейдере уже в пространстве камеры: 0 — грань
	// смотрит вбок от игрока, 1 — прямо на него.
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float rim = pow(1.0 - facing, 3.0);
	EMISSION = shaded * (shadow_lift + rim * rim_strength) + dither;
}
