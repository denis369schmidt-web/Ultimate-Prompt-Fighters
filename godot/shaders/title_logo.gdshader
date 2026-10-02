shader_type canvas_item;
// Title logo lettering: forged-metal gradient with a horizon break, a shine that sweeps across
// now and then, italic lean. The label draws its glyphs white (fill), dark (outline) and with a
// translucent glow (shadow); the vertex color tells the three apart.

uniform vec4 top_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 mid_color : source_color = vec4(0.8, 0.84, 0.9, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.3, 0.34, 0.42, 1.0);
uniform vec4 edge_color : source_color = vec4(0.03, 0.03, 0.05, 1.0);
uniform float text_top = 0.0;
uniform float text_height = 100.0;
uniform float text_width = 600.0;
uniform float skew = 0.16;
uniform float shine_period = 5.0;
uniform float shine_offset = 0.0;

varying vec2 local;
varying vec4 vcol;

void vertex() {
	local = VERTEX;
	vcol = COLOR;
	VERTEX.x += (text_top + text_height * 0.5 - VERTEX.y) * skew;
}

void fragment() {
	float a = texture(TEXTURE, UV).a;
	if (vcol.a < 0.99) {
		// Glow (label shadow): keep its color, soften it.
		COLOR = vec4(vcol.rgb, vcol.a * a);
	} else if (vcol.r + vcol.g + vcol.b < 1.5) {
		COLOR = vec4(edge_color.rgb, a);
	} else {
		float t = clamp((local.y - text_top) / text_height, 0.0, 1.0);
		vec3 g = t < 0.52 ? mix(top_color.rgb, mid_color.rgb, t / 0.52) : mix(bottom_color.rgb * 1.25, bottom_color.rgb, (t - 0.52) / 0.48);
		// Horizon: a thin dark line where the metal folds.
		g *= 1.0 - 0.35 * (smoothstep(0.49, 0.52, t) - smoothstep(0.52, 0.56, t));
		// Diagonal shine, once per period.
		float phase = fract((TIME + shine_offset) / shine_period) * 1.8 - 0.4;
		float x = local.x / text_width - (1.0 - t) * 0.12;
		float shine = smoothstep(0.045, 0.0, abs(x - phase));
		g += vec3(1.0, 0.97, 0.9) * shine * 0.85;
		COLOR = vec4(g, a);
	}
}
