shader_type canvas_item;

// Экран смерти: мир выцветает в красно-чёрную палитру, а края кадра
// затягивает тяжёлая виньетка. Прогрессом управляет HUD-твин.

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float vignette : hint_range(0.0, 1.5) = 1.0;

void fragment() {
	vec3 src = texture(screen_texture, SCREEN_UV).rgb;
	float lum = dot(src, vec3(0.299, 0.587, 0.114));

	// Красная кровь в светах и почти чёрный уголь в тенях.
	vec3 blood = vec3(lum * 0.92, lum * 0.055, lum * 0.035);
	vec3 char = vec3(lum * 0.010, 0.0, 0.0);
	vec3 tone = mix(blood, char, smoothstep(0.20, 0.78, lum) * 0.60);

	vec2 uv = UV * 2.0 - 1.0;
	float edge = smoothstep(0.08, 1.18, length(uv));
	float shade = 1.0 - edge * 0.86 * vignette;

	vec3 col = mix(src, tone * shade, progress);
	col = mix(col, vec3(0.0), progress * 0.08);
	COLOR = vec4(col, 1.0);
}
