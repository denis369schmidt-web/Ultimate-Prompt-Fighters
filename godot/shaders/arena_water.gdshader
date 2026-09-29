shader_type spatial;
// Animated water: layered sine waves (vertex), fresnel sheen and glossy highlights.
render_mode cull_disabled;

uniform vec4 deep_color : source_color = vec4(0.02, 0.10, 0.18, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.08, 0.42, 0.52, 1.0);
uniform vec4 sheen_color : source_color = vec4(0.75, 0.9, 1.0, 1.0);
uniform float wave_height = 0.18;
uniform float wave_scale = 0.35;
uniform float speed = 1.0;

varying float h;

float wave(vec2 p, float t) {
	return sin(p.x * wave_scale + t) * 0.5
		+ sin(p.y * wave_scale * 1.7 + t * 1.3) * 0.35
		+ sin((p.x + p.y) * wave_scale * 2.3 - t * 0.8) * 0.15;
}

void vertex() {
	vec3 w = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float t = TIME * speed;
	h = wave(w.xz, t);
	VERTEX.y += h * wave_height;
	float e = 0.15;
	float hx = wave(w.xz + vec2(e, 0.0), t) - h;
	float hz = wave(w.xz + vec2(0.0, e), t) - h;
	NORMAL = normalize(vec3(-hx * wave_height / e, 1.0, -hz * wave_height / e));
}

void fragment() {
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	ALBEDO = mix(deep_color.rgb, shallow_color.rgb, clamp(h * 0.5 + 0.5, 0.0, 1.0) * 0.7) + sheen_color.rgb * fres * 0.35;
	ROUGHNESS = 0.05;
	SPECULAR = 0.9;
}
