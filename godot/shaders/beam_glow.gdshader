shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
// Energy beam: bright core, soft glowing edges and a flowing streak pattern along the beam,
// instead of a flat opaque box. Used by main.gd _beam().

// Per beam (instance uniforms): all beams share one material.
instance uniform vec4 color : source_color = vec4(0.5, 0.8, 1.0, 1.0);
instance uniform float alpha = 1.0;
uniform float intensity = 2.4;
uniform float flow_speed = 6.0;

void fragment() {
	// Edge falloff: 1 where the surface faces the camera (beam center), 0 at the silhouette.
	float facing = clamp(abs(dot(NORMAL, VIEW)), 0.0, 1.0);
	float core = pow(facing, 3.0);
	float glow = pow(facing, 0.8);
	// Streaks flowing along the beam (UV.y runs along the cylinder).
	float streak = 0.75 + 0.25 * sin(UV.y * 40.0 - TIME * flow_speed + sin(UV.x * 6.2831) * 2.0);
	vec3 hot = mix(color.rgb, vec3(1.0), core * 0.7);
	ALBEDO = hot * intensity * (glow * 0.6 + core * 0.9) * streak * alpha;
}
