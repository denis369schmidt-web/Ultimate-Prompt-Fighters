shader_type spatial;
render_mode cull_disabled;
// Banner or flag in the wind, animated entirely on the GPU: pinned along one edge
// (top for banners, left for flags), waves travel across the cloth. Two-tone woven
// pattern with a border and a simple round emblem; no texture needed.

uniform vec4 base_col : source_color = vec4(0.55, 0.08, 0.08, 1.0);
uniform vec4 trim_col : source_color = vec4(0.95, 0.75, 0.3, 1.0);
uniform float wind = 1.0;
uniform float seed = 0.0;
uniform bool flag = false;       // pinned at the left edge instead of the top
uniform bool emblem = true;

varying float shade;

void vertex() {
	float free_amt = flag ? UV.x : UV.y;
	float along = flag ? UV.x : UV.y;
	float across = flag ? UV.y : UV.x;
	float w = sin(along * 7.0 - TIME * 3.2 * wind + seed) * 0.6 + sin(across * 5.0 + along * 3.0 - TIME * 2.1 * wind + seed * 1.7) * 0.4;
	VERTEX.z += w * free_amt * 0.18 * wind;
	if (flag) { VERTEX.y -= free_amt * free_amt * 0.08; }
	shade = 0.82 + 0.18 * w;
}

void fragment() {
	vec2 uv = UV;
	float border = step(uv.x, 0.07) + step(0.93, uv.x) + step(uv.y, 0.06) + step(0.94, uv.y);
	vec2 c = flag ? vec2(0.5, 0.5) : vec2(0.5, 0.38);
	float d = length((uv - c) * vec2(1.0, flag ? 0.6 : 1.6));
	float ring = emblem ? (smoothstep(0.2, 0.19, d) - smoothstep(0.15, 0.14, d) + smoothstep(0.08, 0.07, d)) : 0.0;
	float weave = 0.94 + 0.06 * sin(uv.x * 900.0) * sin(uv.y * 900.0);
	vec3 col = mix(base_col.rgb, trim_col.rgb, clamp(border + ring, 0.0, 1.0));
	// Hem at the free bottom of banners: dark tassel line.
	if (!flag) { col = mix(col, trim_col.rgb * 0.6, step(0.985, uv.y)); }
	ALBEDO = col * weave * shade;
	ROUGHNESS = 0.85;
	SPECULAR = 0.25;
	BACKLIGHT = base_col.rgb * 0.35;
}
