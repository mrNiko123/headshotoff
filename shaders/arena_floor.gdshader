shader_type spatial;

uniform vec4 base_color : source_color = vec4(0.255, 0.235, 0.200, 1.0);
uniform vec4 seam_color : source_color = vec4(0.105, 0.095, 0.080, 1.0);
uniform float tile_size = 2.0;

varying vec3 world_pos;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 tile = world_pos.xz / tile_size;
	vec2 edge = abs(fract(tile) - 0.5);
	float seam = smoothstep(0.472, 0.5, max(edge.x, edge.y));

	float grain = hash21(floor(world_pos.xz * 4.0)) * 0.045;
	float stain = smoothstep(0.82, 1.0, hash21(floor(world_pos.xz * 0.35))) * 0.05;

	ALBEDO = mix(base_color.rgb, seam_color.rgb, seam * 0.6) + grain - stain;
	ROUGHNESS = 0.93;
	METALLIC = 0.02;
}
