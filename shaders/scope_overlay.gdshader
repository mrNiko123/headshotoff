shader_type canvas_item;

// Круглая маска оптики AWP: чёрные поля вокруг линзы с мягким краем
// и лёгкая виньетка внутри стекла.

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float max_radius : hint_range(0.2, 1.0) = 0.94;
uniform float feather = 2.0;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.42;
uniform vec4 mask_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
// Размер прямоугольника в координатах интерфейса и масштаб этих координат
// в пиксели окна: так линза остаётся круглой даже при растянутом 4:3.
uniform vec2 rect_size = vec2(1280.0, 720.0);
uniform vec2 pixel_scale = vec2(1.0, 1.0);

void fragment() {
	// Смещение от центра в пикселях окна — одинаковое по обеим осям.
	vec2 offset_px = (UV - vec2(0.5)) * rect_size * pixel_scale;
	float extent_px = min(rect_size.x * pixel_scale.x, rect_size.y * pixel_scale.y);
	float radius = extent_px * 0.5 * max_radius * progress;
	float dist = length(offset_px);

	// 1 снаружи линзы, 0 внутри.
	float edge = smoothstep(radius - feather, radius + feather * 0.5, dist);
	// Затемнение к краю стекла.
	float inner = smoothstep(radius * 0.52, max(radius - feather, 1.0), dist) * vignette_strength * progress;
	float alpha = clamp(max(edge, inner * (1.0 - edge)), 0.0, 1.0);
	alpha *= clamp(progress * 8.0, 0.0, 1.0);

	COLOR = vec4(mask_color.rgb, alpha * mask_color.a);
}
