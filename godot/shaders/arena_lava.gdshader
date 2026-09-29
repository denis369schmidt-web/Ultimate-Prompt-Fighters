shader_type spatial;
// Flowing lava: scrolling fractal noise, bright glowing veins over dark crust.

uniform vec4 hot : source_color = vec4(1.0, 0.55, 0.12, 1.0);
uniform vec4 cool : source_color = vec4(0.18, 0.03, 0.01, 1.0);
uniform vec2 uv_mult = vec2(8.0, 8.0);
uniform vec2 flow = vec2(0.02, 0.05);
uniform float glow = 3.2;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float n2(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) { v += a * n2(p); p *= 2.03; a *= 0.5; }
	return v;
}

void fragment() {
	vec2 p = UV * uv_mult + TIME * flow;
	float f = fbm(p + fbm(p * 0.5 - TIME * flow * 0.7));
	float c = smoothstep(0.42, 0.72, f);
	ALBEDO = mix(cool.rgb, hot.rgb, c);
	EMISSION = hot.rgb * pow(c, 2.0) * glow + cool.rgb * 0.4;
	ROUGHNESS = mix(0.9, 0.4, c);
}
