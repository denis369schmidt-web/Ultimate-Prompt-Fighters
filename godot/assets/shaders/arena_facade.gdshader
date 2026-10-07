shader_type spatial;
// Near city facade: scanned wall texture (brick/concrete) in world space, floor ledges,
// recessed window frames with sills, lit rooms with a warm/cool interior gradient,
// half-drawn blinds and dark rooms that still reflect the sky. Roofs get a dark tar top.

uniform sampler2D wall_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D wall_nrm : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 tint : source_color = vec4(0.55, 0.5, 0.48, 1.0);
uniform float tex_scale = 0.33;
uniform vec2 cell = vec2(2.2, 3.0);
uniform float lit_ratio = 0.35;
uniform float seed = 1.0;
uniform vec4 lit_a : source_color = vec4(1.0, 0.72, 0.4, 1.0);
uniform vec4 lit_b : source_color = vec4(0.5, 0.85, 1.0, 1.0);
uniform vec4 lit_c : source_color = vec4(1.0, 0.4, 0.75, 1.0);
uniform float emission_gain = 1.8;

varying vec3 wpos;
varying vec3 wnorm;

float hash(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233)) + seed * 7.13) * 43758.5453); }

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnorm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	if (wnorm.y > 0.5) {
		ALBEDO = vec3(0.05, 0.05, 0.055);
		ROUGHNESS = 0.9;
	} else if (wnorm.y < -0.5) {
		ALBEDO = vec3(0.02);
	} else {
		vec2 p = abs(wnorm.z) > 0.5 ? wpos.xy : wpos.zy;
		vec3 wall = texture(wall_tex, p * tex_scale).rgb * tint.rgb;
		NORMAL_MAP = texture(wall_nrm, p * tex_scale).rgb;
		vec2 c = p / cell;
		vec2 id = floor(c);
		vec2 f = fract(c);
		// Window opening, frame and sill.
		float win = step(0.2, f.x) * step(f.x, 0.8) * step(0.22, f.y) * step(f.y, 0.78);
		float frame = step(0.16, f.x) * step(f.x, 0.84) * step(0.18, f.y) * step(f.y, 0.82) - win;
		float sill = step(0.14, f.x) * step(f.x, 0.86) * step(0.13, f.y) * step(f.y, 0.18);
		// Floor ledge every row.
		float ledge = step(0.955, f.y);
		float r = hash(id);
		float on = step(1.0 - lit_ratio, r) * (0.8 + 0.2 * sin(TIME * 0.3 + r * 40.0));
		float pick = hash(id * 1.7 + 3.1);
		vec3 lc = pick < 0.65 ? lit_a.rgb : (pick < 0.88 ? lit_b.rgb : lit_c.rgb);
		// Interior: brighter towards the ceiling, blinds cut the top part of some windows.
		float blind = hash(id + 9.3);
		float blind_line = 0.78 - blind * 0.4;
		float slats = step(blind_line, f.y) * (0.55 + 0.45 * step(0.5, fract(f.y * 22.0)));
		float room = mix(0.45, 1.0, smoothstep(0.22, 0.78, f.y));
		float light_amt = on * room * mix(1.0, 0.35, slats);
		vec3 glass = vec3(0.025, 0.03, 0.04) + vec3(0.03, 0.04, 0.06) * smoothstep(0.2, 0.8, f.y + f.x * 0.3);
		vec3 col = wall;
		col = mix(col, wall * 0.55, ledge);
		col = mix(col, vec3(0.08, 0.08, 0.09), frame);
		col = mix(col, wall * 1.15 + 0.03, sill);
		col = mix(col, mix(glass, lc * 0.2, on), win);
		ALBEDO = col;
		EMISSION = lc * win * light_amt * emission_gain;
		ROUGHNESS = mix(0.85, 0.06, win);
		METALLIC = win * 0.3;
	}
}
