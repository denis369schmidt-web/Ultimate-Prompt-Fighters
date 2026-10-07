shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;
// Polar light curtain: vertical rays that drift sideways, the lower edge bright green,
// the top fading to violet; the ribbon itself waves (vertex). One quad strip per curtain.

uniform sampler2D noise_tex : filter_linear_mipmap, repeat_enable;
uniform vec4 low_col : source_color = vec4(0.25, 1.0, 0.55, 1.0);
uniform vec4 high_col : source_color = vec4(0.55, 0.3, 1.0, 1.0);
uniform float strength = 1.4;
uniform float seed = 0.0;

void vertex() {
	VERTEX.z += sin(VERTEX.x * 0.06 + TIME * 0.25 + seed) * 6.0 + sin(VERTEX.x * 0.17 - TIME * 0.4) * 2.0;
	VERTEX.y += sin(VERTEX.x * 0.05 + TIME * 0.2 + seed * 2.0) * 2.5;
}

void fragment() {
	float rays = texture(noise_tex, vec2(UV.x * 3.0 + TIME * 0.01 + seed, 0.2)).r;
	rays = pow(rays, 2.2) * 1.8 + texture(noise_tex, vec2(UV.x * 9.0 - TIME * 0.02, seed)).r * 0.4;
	float v = 1.0 - UV.y; // 0 bottom, 1 top
	float lower = smoothstep(0.0, 0.08, v) * (1.0 - smoothstep(0.08, 1.0, v));
	float shimmer = 0.75 + 0.25 * sin(TIME * 1.3 + UV.x * 40.0 + seed);
	float edges = smoothstep(0.0, 0.15, UV.x) * smoothstep(1.0, 0.85, UV.x);
	vec3 col = mix(low_col.rgb, high_col.rgb, smoothstep(0.15, 0.9, v));
	ALBEDO = col * rays * lower * shimmer * edges * strength;
}
