shader_type spatial;
render_mode cull_disabled, shadows_disabled;
// Spectators on a stand: a tiled crowd picture, every spectator column bobs on its own
// rhythm (cheering), alpha-scissored so no transparency sorting is needed.

uniform sampler2D crowd_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec2 tiles = vec2(6.0, 1.0);
uniform float brightness = 1.0;
uniform float excitement = 1.0;

float hash(float x) { return fract(sin(x * 91.3458) * 47453.5453); }

void fragment() {
	vec2 uv = UV * tiles;
	float col = floor(uv.x * 28.0);
	float h = hash(col + floor(uv.y) * 13.0);
	float jump = max(0.0, sin(TIME * (3.0 + h * 4.0) + h * 30.0)) * 0.035 * excitement;
	vec4 c = texture(crowd_tex, vec2(uv.x, fract(uv.y) + jump));
	if (c.a < 0.5) discard;
	ALBEDO = c.rgb * brightness;
	ROUGHNESS = 0.9;
}
