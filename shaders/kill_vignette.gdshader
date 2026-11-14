shader_type canvas_item;

// Виньетка убийства: акцентная вспышка по краям экрана. Центр остаётся
// прозрачным, поэтому прицел и цель не теряются в засветке.

uniform vec4 glow_color : source_color = vec4(1.0, 0.25, 0.2, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.55;
uniform float inner : hint_range(0.0, 1.5) = 0.74;
uniform float outer : hint_range(0.2, 2.0) = 1.5;
// Прозрачность анимируется отдельно, а не через modulate: шейдер полностью
// перезаписывает COLOR, поэтому modulate до кадра уже не доходит и вспышка
// гасла бы рывком в самом конце твина.
uniform float opacity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	// Чуть сжимаем по вертикали: на широком экране вспышка не должна
	// превращаться в тонкую рамку сверху и снизу.
	float d = length(uv * vec2(1.0, 0.86));
	float edge = smoothstep(inner, outer, d);
	COLOR = vec4(glow_color.rgb, edge * strength * opacity);
}
