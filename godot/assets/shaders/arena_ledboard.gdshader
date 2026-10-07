shader_type spatial;
render_mode unshaded, shadows_disabled;
// LED ribbon board around a stadium: dot-matrix pixels showing scrolling chevrons and
// colour waves; dark housing between the LEDs.

uniform vec4 col_a : source_color = vec4(0.2, 0.85, 1.0, 1.0);
uniform vec4 col_b : source_color = vec4(1.0, 0.3, 0.75, 1.0);
uniform float dots = 160.0;
uniform float aspect = 40.0;
uniform float speed = 0.08;
uniform float energy = 2.4;

void fragment() {
	vec2 uv = vec2(UV.x * aspect, UV.y);
	vec2 grid = vec2(dots, dots / aspect);
	vec2 cell = floor(UV * grid) / grid;
	vec2 f = fract(UV * grid);
	float led = smoothstep(0.5, 0.25, length(f - 0.5));
	float x = cell.x * aspect - TIME * speed * aspect;
	float chevron = step(0.5, fract(x * 0.5 + abs(cell.y - 0.5)));
	float wave = 0.5 + 0.5 * sin(x * 0.8 + TIME * 1.5);
	float block = step(0.55, fract(x * 0.05));
	vec3 c = mix(col_a.rgb, col_b.rgb, wave);
	float on = mix(chevron, wave, block);
	ALBEDO = mix(vec3(0.015), c * energy * (0.25 + 0.75 * on), led);
}
