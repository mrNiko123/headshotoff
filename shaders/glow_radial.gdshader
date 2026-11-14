shader_type spatial;

// Мягкое радиальное свечение HEADSHOT: плоскость без видимых краёв.
// Используется за ножом в меню и предметом в кейсе.

render_mode unshaded, blend_add, cull_disabled, depth_draw_never, fog_disabled;

uniform vec4 glow_color : source_color = vec4(0.886, 0.651, 0.239, 1.0);
uniform float strength = 0.09;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float d = clamp(length(uv), 0.0, 1.0);
	float falloff = 1.0 - smoothstep(0.10, 1.0, d);
	ALBEDO = glow_color.rgb;
	ALPHA = falloff * falloff * strength;
}
