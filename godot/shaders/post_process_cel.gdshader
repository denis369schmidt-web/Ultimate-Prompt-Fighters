shader_type canvas_item;

// ─────────────────────────────────────────────────────────────────────────────
// POST-PROCESSING COMIC INK OUTLINE & VIBRANCE PASS (CANVAS_ITEM SAFE)
// ─────────────────────────────────────────────────────────────────────────────
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float outline_threshold : hint_range(0.001, 0.08) = 0.012;
uniform vec4 ink_color : source_color = vec4(0.03, 0.03, 0.05, 1.0);
uniform float ink_strength : hint_range(0.0, 1.0) = 0.75;
uniform float color_boost : hint_range(1.0, 1.5) = 1.08;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 texel = 1.0 / vec2(textureSize(screen_texture, 0));

	vec4 scene_col = texture(screen_texture, uv);

	// Multi-directional edge detection (Sobel Luminance)
	vec3 c_r = texture(screen_texture, uv + vec2(texel.x * 1.2, 0.0)).rgb;
	vec3 c_l = texture(screen_texture, uv - vec2(texel.x * 1.2, 0.0)).rgb;
	vec3 c_u = texture(screen_texture, uv + vec2(0.0, texel.y * 1.2)).rgb;
	vec3 c_d = texture(screen_texture, uv - vec2(0.0, texel.y * 1.2)).rgb;

	float lum_c = dot(scene_col.rgb, vec3(0.299, 0.587, 0.114));
	float lum_r = dot(c_r, vec3(0.299, 0.587, 0.114));
	float lum_l = dot(c_l, vec3(0.299, 0.587, 0.114));
	float lum_u = dot(c_u, vec3(0.299, 0.587, 0.114));
	float lum_d = dot(c_d, vec3(0.299, 0.587, 0.114));

	float lum_diff = abs(lum_c - lum_r) + abs(lum_c - lum_l) + abs(lum_c - lum_u) + abs(lum_c - lum_d);
	float edge = smoothstep(outline_threshold, outline_threshold * 2.5, lum_diff) * ink_strength;

	// Composite Anime Inked Output with vibrant color contrast
	vec3 vibrant_col = pow(scene_col.rgb, vec3(1.0 / color_boost));
	vec3 out_col = mix(vibrant_col, ink_color.rgb, edge);

	COLOR = vec4(out_col, scene_col.a);
}
