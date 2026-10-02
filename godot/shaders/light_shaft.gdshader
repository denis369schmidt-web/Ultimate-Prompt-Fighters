shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;
// God ray: a soft additive beam of light falling into the arena, with drifting dust
// streaks and a slow breathing intensity. UV.y = 0 at the top (light source).

uniform vec4 tint : source_color = vec4(1.0, 0.9, 0.7, 1.0);
uniform float strength = 0.35;
uniform float seed = 0.0;

void fragment() {
	float across = 1.0 - abs(UV.x - 0.5) * 2.0;
	float beam = pow(clamp(across, 0.0, 1.0), 2.2);
	float along = smoothstep(0.0, 0.12, UV.y) * (1.0 - smoothstep(0.55, 1.0, UV.y));
	float streaks = 0.75 + 0.25 * sin(UV.x * 37.0 + seed * 5.0 + TIME * 0.3) * sin(UV.y * 9.0 - TIME * 0.5 + seed);
	float breathe = 0.8 + 0.2 * sin(TIME * 0.45 + seed * 2.1);
	ALBEDO = tint.rgb * beam * along * streaks * breathe * strength;
}
