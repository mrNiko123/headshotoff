shader_type spatial;

// Перекрас карты: тонкое наложение поверх геометрии арены. Оно умножает
// уже освещённый кадр на выбранный цвет, поэтому светотень, швы и рисунок
// поверхности сохраняются — карта выглядит перекрашенной, а не залитой
// ровной краской. Наложение живёт только на мешах карты: HUD, оружие и
// небо не затрагиваются.
render_mode unshaded, blend_mul, depth_draw_never, cull_back,
	shadows_disabled, ambient_light_disabled;

uniform vec4 tint : source_color = vec4(0.96, 0.74, 0.34, 1.0);

void fragment() {
	ALBEDO = tint.rgb;
	ALPHA = 1.0;
}
