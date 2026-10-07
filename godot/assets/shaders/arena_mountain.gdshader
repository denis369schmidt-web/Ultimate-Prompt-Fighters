shader_type spatial;
// Distant mountain ridge: triplanar scanned rock, snow on flat parts and above the snow
// line (broken up by noise), darker in the gullies. Used on generated ridge meshes.

uniform sampler2D rock_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rock_nrm : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D snow_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 rock_tint : source_color = vec4(0.55, 0.58, 0.66, 1.0);
uniform vec4 snow_tint : source_color = vec4(0.92, 0.95, 1.0, 1.0);
uniform float tex_scale = 0.05;
uniform float snow_line = 18.0;
uniform float snow_slope = 0.62;

varying vec3 wpos;
varying vec3 wnorm;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnorm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

vec3 tri(sampler2D t, vec3 p, vec3 w) {
	return texture(t, p.zy).rgb * w.x + texture(t, p.xz).rgb * w.y + texture(t, p.xy).rgb * w.z;
}

void fragment() {
	vec3 w = pow(abs(wnorm), vec3(4.0));
	w /= (w.x + w.y + w.z);
	vec3 p = wpos * tex_scale;
	vec3 rock = tri(rock_tex, p, w) * rock_tint.rgb;
	vec3 snow = tri(snow_tex, p * 2.0, w) * snow_tint.rgb;
	float detail = tri(rock_tex, p * 3.7, w).g;
	float flatness = smoothstep(snow_slope - 0.12, snow_slope + 0.1, wnorm.y + (detail - 0.5) * 0.35);
	float height = smoothstep(snow_line - 6.0, snow_line + 6.0, wpos.y + (detail - 0.5) * 10.0);
	float s = clamp(max(flatness * smoothstep(snow_line - 18.0, snow_line, wpos.y), height * 0.85 * flatness + height * 0.25), 0.0, 1.0);
	ALBEDO = mix(rock, snow, s);
	NORMAL_MAP = mix(tri(rock_nrm, p, w), vec3(0.5, 0.5, 1.0), s * 0.7);
	ROUGHNESS = mix(0.92, 0.6, s);
}
