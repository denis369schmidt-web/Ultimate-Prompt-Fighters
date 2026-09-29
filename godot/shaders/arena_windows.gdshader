shader_type spatial;
// Skyscraper facade: procedural window grid in world space, random lit windows that
// slowly flicker, glossy glass. Roofs stay dark.

uniform vec4 wall : source_color = vec4(0.035, 0.035, 0.06, 1.0);
uniform vec4 lit_a : source_color = vec4(1.0, 0.78, 0.45, 1.0);
uniform vec4 lit_b : source_color = vec4(0.35, 0.95, 1.0, 1.0);
uniform vec4 lit_c : source_color = vec4(1.0, 0.35, 0.8, 1.0);
uniform vec2 cell = vec2(1.1, 1.5);
uniform float lit_ratio = 0.45;
uniform float seed = 1.0;

varying vec3 wpos;
varying vec3 wnorm;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233)) + seed) * 43758.5453); }

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnorm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	if (abs(wnorm.y) > 0.5) {
		ALBEDO = wall.rgb * 0.7;
		ROUGHNESS = 0.8;
	} else {
		vec2 p = abs(wnorm.z) > 0.5 ? wpos.xy : wpos.zy;
		vec2 c = p / cell;
		vec2 id = floor(c);
		vec2 f = fract(c);
		float win = step(0.16, f.x) * step(f.x, 0.84) * step(0.2, f.y) * step(f.y, 0.8);
		float r = hash(id);
		float on = step(1.0 - lit_ratio, r) * (0.75 + 0.25 * sin(TIME * 0.4 + r * 50.0));
		float pick = hash(id * 1.7 + 3.1);
		vec3 lc = pick < 0.6 ? lit_a.rgb : (pick < 0.85 ? lit_b.rgb : lit_c.rgb);
		ALBEDO = mix(wall.rgb, lc * 0.25, win * on);
		EMISSION = lc * win * on * 2.4;
		ROUGHNESS = mix(0.55, 0.08, win);
		METALLIC = 0.35;
	}
}
