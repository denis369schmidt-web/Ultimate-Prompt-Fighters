shader_type spatial;
render_mode shadows_disabled;
// Cloud puffs drawn as one MultiMesh: every instance bobs on its own phase (INSTANCE_ID),
// soft wrap lighting and a bright rim so the sea of clouds reads as volume.

uniform vec4 tint : source_color = vec4(0.8, 0.8, 0.85, 1.0);

void vertex() {
	float ph = float(INSTANCE_ID) * 1.73;
	VERTEX.y += sin(TIME * (0.2 + fract(ph) * 0.15) + ph) * 0.3;
}

void fragment() {
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);
	ALBEDO = tint.rgb * (0.92 + 0.08 * NORMAL.y);
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
	EMISSION = tint.rgb * rim * 0.25;
	BACKLIGHT = tint.rgb * 0.3;
}
