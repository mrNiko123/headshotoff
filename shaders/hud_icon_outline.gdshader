shader_type canvas_item;

// Иконка слота HUD: 3D-модель рендерится белой в прозрачный SubViewport,
// а здесь из её альфы собирается полупрозрачная заливка и обводка в цвете
// HUD. Так силуэт остаётся объёмным, но не тащит текстуры и рамки.

uniform vec4 outline_color : source_color = vec4(1.0);
uniform vec4 fill_color : source_color = vec4(1.0, 1.0, 1.0, 0.14);
uniform float outline_width : hint_range(0.5, 3.0) = 1.3;
uniform vec4 halo_color : source_color = vec4(0.0, 0.0, 0.0, 0.38);
uniform sampler2D icon_tex : hint_default_transparent, filter_linear, repeat_disable;

float alpha_at(vec2 uv) {
	return texture(icon_tex, uv).a;
}

float ring_alpha(vec2 uv, vec2 step_px) {
	float value = 0.0;
	value = max(value, alpha_at(uv + vec2(step_px.x, 0.0)));
	value = max(value, alpha_at(uv - vec2(step_px.x, 0.0)));
	value = max(value, alpha_at(uv + vec2(0.0, step_px.y)));
	value = max(value, alpha_at(uv - vec2(0.0, step_px.y)));
	value = max(value, alpha_at(uv + step_px));
	value = max(value, alpha_at(uv - step_px));
	value = max(value, alpha_at(uv + vec2(step_px.x, -step_px.y)));
	value = max(value, alpha_at(uv + vec2(-step_px.x, step_px.y)));
	return value;
}

vec4 over(vec4 base, vec4 src) {
	float a = src.a + base.a * (1.0 - src.a);
	vec3 rgb = (src.rgb * src.a + base.rgb * base.a * (1.0 - src.a)) / max(a, 0.0001);
	return vec4(rgb, a);
}

void fragment() {
	float a = alpha_at(UV);
	vec2 px = TEXTURE_PIXEL_SIZE * outline_width;
	float edge = clamp(ring_alpha(UV, px) - a, 0.0, 1.0);

	// Тёмный ореол на пиксель шире обводки: иконка читается и на светлом
	// небе, и на песке, не превращаясь в плашку.
	vec2 halo_px = TEXTURE_PIXEL_SIZE * (outline_width + 1.2);
	float halo = clamp(ring_alpha(UV, halo_px) - a, 0.0, 1.0) * (1.0 - edge);

	vec4 col = vec4(fill_color.rgb, fill_color.a * a);
	col = over(col, vec4(outline_color.rgb, outline_color.a * edge));
	col = over(col, vec4(halo_color.rgb, halo_color.a * halo));
	COLOR = col;
}
