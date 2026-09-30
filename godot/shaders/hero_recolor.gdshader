shader_type spatial;
render_mode diffuse_toon, specular_toon, cull_disabled;
// Hero outfit recolor: keeps skin tones and texture detail, moves cloth and armor into the
// hero's own palette (dark areas -> secondary, bright areas -> primary), adds a colored rim
// and a hit flash. Used by hero_gear.gd on the rigged bodies of the house heroes.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform bool has_tex = true;
uniform vec4 base_color : source_color = vec4(1.0);
uniform vec3 primary : source_color = vec3(0.8, 0.6, 0.2);
uniform vec3 secondary : source_color = vec3(0.1, 0.15, 0.2);
uniform vec3 accent : source_color = vec3(1.0, 0.9, 0.5);
uniform float recolor : hint_range(0.0, 1.0) = 0.85;
uniform float keep_skin : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D normal_tex : hint_normal, filter_linear_mipmap, repeat_enable;
uniform bool has_normal = false;
uniform float roughness_v : hint_range(0.0, 1.0) = 0.55;
uniform float metallic_v : hint_range(0.0, 1.0) = 0.15;
uniform vec3 rim_color : source_color = vec3(0.5, 0.8, 1.0);
uniform float rim_strength = 0.55;
uniform float rim_power = 3.0;
uniform float flash = 0.0;
uniform float charge = 0.0;

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void fragment() {
	vec4 tex = has_tex ? texture(albedo_tex, UV) : vec4(1.0);
	vec3 src = tex.rgb * base_color.rgb;
	vec3 hsv = rgb2hsv(src);
	// Skin: warm hue, moderate saturation, not too dark.
	float warm = 1.0 - smoothstep(0.085, 0.13, hsv.x);
	float skin = warm * smoothstep(0.12, 0.22, hsv.y) * (1.0 - smoothstep(0.62, 0.78, hsv.y)) * smoothstep(0.4, 0.56, hsv.z);
	skin *= keep_skin;
	float lum = dot(src, vec3(0.299, 0.587, 0.114));
	vec3 tone = mix(secondary, primary, smoothstep(0.12, 0.5, lum));
	// Very bright, low-saturation spots (buckles, trims, highlights) become the accent metal.
	tone = mix(tone, accent, smoothstep(0.62, 0.85, lum) * (1.0 - hsv.y));
	vec3 recol = tone * (0.45 + lum * 1.15);
	ALBEDO = mix(src, recol, recolor * (1.0 - skin));
	ROUGHNESS = mix(roughness_v, 0.5, skin);
	METALLIC = mix(metallic_v, 0.0, skin);
	if (has_normal) {
		NORMAL_MAP = texture(normal_tex, UV).rgb;
	}
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	EMISSION = rim_color * fres * (rim_strength + charge * 0.9) + vec3(1.0, 0.95, 0.9) * flash * 0.8;
}
