shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;
// Drifting fog bank behind the stage: two layers of scrolling noise, soft edges, tinted
// to the arena mood. Cheap (one texture, no lighting), gives depth and movement.

uniform sampler2D noise_tex : filter_linear_mipmap, repeat_enable;
uniform vec4 tint : source_color = vec4(0.8, 0.85, 0.9, 1.0);
uniform float density = 0.55;
uniform float speed = 0.012;
uniform float seed = 0.0;

void fragment() {
	vec2 uv = UV;
	float n1 = texture(noise_tex, uv * vec2(1.6, 0.9) + vec2(TIME * speed + seed, seed * 0.37)).r;
	float n2 = texture(noise_tex, uv * vec2(3.1, 1.7) - vec2(TIME * speed * 1.7, -seed)).r;
	float n = n1 * 0.65 + n2 * 0.35;
	// Fade at every border so the quad never shows its edges; denser near the bottom.
	float edge = smoothstep(0.0, 0.18, uv.x) * smoothstep(1.0, 0.82, uv.x) * smoothstep(0.0, 0.35, uv.y) * smoothstep(1.0, 0.55, uv.y);
	ALBEDO = tint.rgb;
	ALPHA = clamp(smoothstep(0.35, 0.85, n) * edge * density, 0.0, 1.0);
}
