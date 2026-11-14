shader_type spatial;

// Светлая панельная поверхность «студии»: мировые швы каждые N метров,
// перекрестия на стыках и лёгкая шахматная разница плит. Сетка строится
// в мировых координатах по нормали, поэтому один шейдер подходит и полу,
// и стенам, и повёрнутым рампам — швы идут непрерывно по всей карте.

uniform vec4 base_color : source_color = vec4(0.86, 0.87, 0.89, 1.0);
uniform vec4 seam_color : source_color = vec4(0.62, 0.64, 0.67, 1.0);
uniform vec4 cross_color : source_color = vec4(0.48, 0.50, 0.54, 1.0);
uniform float grid_size = 2.0;
uniform float seam_width = 0.018;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.9;
uniform float checker_amount : hint_range(0.0, 0.2) = 0.0;
uniform float grain_amount : hint_range(0.0, 0.1) = 0.012;

varying vec3 world_pos;
varying vec3 world_normal;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = abs(world_normal);
	vec2 uv;
	if (n.y >= n.x && n.y >= n.z) {
		uv = world_pos.xz;
	} else if (n.x >= n.z) {
		uv = world_pos.zy;
	} else {
		uv = world_pos.xy;
	}

	vec2 grid = uv / grid_size;
	vec2 cell = fract(grid);
	vec2 edge = min(cell, 1.0 - cell) * grid_size;
	float nearest = min(edge.x, edge.y);
	// Вдали тонкий шов начинает мерцать — расширяем его на размер пикселя.
	float width = max(seam_width, fwidth(nearest) * 0.85);
	float seam = 1.0 - smoothstep(width * 0.45, width, nearest);

	// Перекрестие в узле сетки: короткая горизонтальная и вертикальная черта.
	vec2 node = abs(fract(grid + 0.5) - 0.5) * grid_size;
	float arm = grid_size * 0.075;
	float bar = max(grid_size * 0.011, 0.012);
	float across = 1.0 - smoothstep(bar, bar * 1.8, node.x);
	float along = 1.0 - smoothstep(bar, bar * 1.8, node.y);
	float cross_h = across * (1.0 - smoothstep(arm, arm * 1.8, node.y));
	float cross_v = along * (1.0 - smoothstep(arm, arm * 1.8, node.x));
	float cross = max(cross_h, cross_v);

	vec2 panel = floor(grid);
	float checker = mix(1.0 - checker_amount, 1.0,
		mod(panel.x + panel.y, 2.0));
	float grain = (hash21(floor(uv * 3.0)) - 0.5) * grain_amount;

	vec3 albedo = base_color.rgb * checker;
	albedo = mix(albedo, seam_color.rgb, seam * 0.9);
	albedo = mix(albedo, cross_color.rgb, cross * 0.85);
	ALBEDO = clamp(albedo + grain, 0.0, 1.0);
	ROUGHNESS = roughness_value;
	METALLIC = 0.0;
	SPECULAR = 0.32;
}
