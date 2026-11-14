shader_type spatial;

// След от пули: тёмная пробоина с рваным краем и пыльным ободком. Рисуется
// на маленьком кваде, прижатом к поверхности, поэтому не нуждается в текстуре
// и одинаково читается на бетоне, металле и полу.
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

uniform vec4 hole_color : source_color = vec4(0.020, 0.017, 0.014, 0.96);
uniform vec4 rim_color : source_color = vec4(0.66, 0.61, 0.53, 0.72);
uniform float hole_radius = 0.52;
uniform float rim_radius = 0.90;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float angle = atan(p.y, p.x);
	// Неровный край: дырка не выглядит штампованным кружком.
	float wobble = 1.0
		+ 0.10 * sin(angle * 6.0 + 1.3)
		+ 0.06 * sin(angle * 11.0 + 0.4);
	float d = length(p) / wobble;
	float hole = 1.0 - smoothstep(hole_radius - 0.10, hole_radius, d);
	float rim = smoothstep(hole_radius - 0.06, hole_radius + 0.02, d)
		* (1.0 - smoothstep(rim_radius - 0.12, rim_radius, d));
	vec3 col = mix(hole_color.rgb, rim_color.rgb, rim);
	float alpha = max(hole * hole_color.a, rim * rim_color.a);
	if (alpha < 0.01) {
		discard;
	}
	ALBEDO = col;
	ALPHA = alpha;
}
