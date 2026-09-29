shader_type spatial;
render_mode cull_front, unshaded;

// INVERTED HULL SCREEN-ALIGNED BLACK OUTLINE PASS
// Guilty Gear / Dragon Ball FighterZ Anime-Silhouette
uniform float outline_width : hint_range(0.0, 0.08) = 0.016;
uniform vec4 outline_color : source_color = vec4(0.05, 0.05, 0.07, 1.0);

void vertex() {
	vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal = mat3(PROJECTION_MATRIX) * (mat3(MODELVIEW_MATRIX) * NORMAL);
	// Screen-space extrusion: preserves uniform pixel thickness at distance
	clip_position.xy += normalize(clip_normal.xy) * outline_width * clip_position.w * 0.003;
	POSITION = clip_position;
}

void fragment() {
	ALBEDO = outline_color.rgb;
}
