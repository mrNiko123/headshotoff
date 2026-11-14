shader_type spatial;

// Автоматы AK-47 и M4A1-S: плоский цвет (AK) или атлас (M4) плюс скин.
// Как и у AWP, к альбедо добавляется слабый rim — у низкополигонального
// корпуса плоские тёмные грани иначе сливаются в чёрный силуэт вьюмодели.
// `albedo_gain` поднимает очень тёмный атлас M4: без него умножение на
// цвет скина давало почти чёрный корпус.

render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo_color : source_color = vec4(1.0);
uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform bool use_texture = false;
uniform float albedo_gain : hint_range(0.0, 12.0) = 1.0;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.45;
uniform float metallic_value : hint_range(0.0, 1.0) = 0.18;
uniform float emission_boost : hint_range(0.0, 1.0) = 0.10;
uniform float rim_strength : hint_range(0.0, 1.0) = 0.18;
uniform float dark_lift : hint_range(0.0, 0.2) = 0.015;
// Перекраска из меню цветов: цвет ложится поверх скина, сохраняя рисунок
// атласа и светотень. `paint_amount` = 0 — исходный вид.
uniform vec4 paint_color : source_color = vec4(0.0);
uniform float paint_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec3 col = albedo_color.rgb;
	if (use_texture) {
		col *= texture(albedo_tex, UV).rgb;
	}
	col *= albedo_gain;
	float luma = clamp(dot(col, vec3(0.299, 0.587, 0.114)), 0.0, 1.0);
	vec3 paint = paint_color.rgb * clamp(0.45 + 0.80 * luma, 0.0, 1.0);
	col = mix(col, paint, paint_amount);
	vec3 lifted = max(col, vec3(dark_lift));
	ALBEDO = lifted;
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float rim = pow(1.0 - facing, 3.0);
	EMISSION = lifted * emission_boost + lifted * rim * rim_strength;
	ROUGHNESS = roughness_value;
	METALLIC = metallic_value;
}
