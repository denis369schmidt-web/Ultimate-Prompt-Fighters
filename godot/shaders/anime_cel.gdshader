shader_type spatial;
render_mode diffuse_toon, specular_toon, cull_back;

// ─────────────────────────────────────────────────────────────────────────────
// GUILTY GEAR / DRAGON BALL STYLE 2-STEP ANIME CEL-SHADER
// ─────────────────────────────────────────────────────────────────────────────
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
uniform bool use_albedo_texture = false;

uniform sampler2D normal_texture : hint_normal, filter_linear_mipmap;
uniform bool use_normal_texture = false;
uniform float normal_scale : hint_range(-16.0, 16.0) = 1.0;

// Triplanar support for base procedural fighters (Ninja, Lava Golem, Valkyrie)
uniform bool use_triplanar = false;
uniform vec3 triplanar_scale = vec3(0.015, 0.015, 0.015);
uniform float triplanar_sharpness = 4.0;

// 2-Step Anime Tone Ramp
uniform vec4 shadow_tint : source_color = vec4(0.55, 0.50, 0.65, 1.0);
uniform float shadow_threshold : hint_range(-0.5, 1.0) = 0.15;
uniform float shadow_softness : hint_range(0.001, 0.25) = 0.035;

// Emission (Ki, Rinnegan, Fire, Plasma)
uniform vec4 emission_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D emission_texture : source_color, filter_linear_mipmap;
uniform bool use_emission_texture = false;
uniform float emission_energy : hint_range(0.0, 20.0) = 0.0;

// PBR Surface Controls
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform float rim_strength : hint_range(0.0, 3.0) = 0.85;
uniform vec4 rim_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

varying vec3 v_world_pos;
varying vec3 v_world_normal;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize(mat3(MODEL_MATRIX) * NORMAL);
}

vec4 triplanar_sample(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

void fragment() {
	vec4 base = albedo_color;

	if (use_triplanar && use_albedo_texture) {
		vec3 tri_pos = v_world_pos * triplanar_scale;
		vec3 tri_weights = abs(v_world_normal);
		tri_weights = pow(tri_weights, vec3(triplanar_sharpness));
		tri_weights /= (tri_weights.x + tri_weights.y + tri_weights.z);
		base *= triplanar_sample(albedo_texture, tri_weights, tri_pos);
	} else if (use_albedo_texture) {
		base *= texture(albedo_texture, UV);
	}

	ALBEDO = base.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;

	if (use_normal_texture && !use_triplanar) {
		NORMAL_MAP = texture(normal_texture, UV).rgb;
		NORMAL_MAP_DEPTH = normal_scale;
	}

	vec3 em = emission_color.rgb;
	if (use_emission_texture) {
		em *= texture(emission_texture, UV).rgb;
	}
	EMISSION = em * emission_energy;
}

void light() {
	// N dot L (Lambertian Light Angle)
	float NdotL = dot(NORMAL, LIGHT);
	
	// 2-Stufiges Anime-Stepping: Knackiger Übergang zwischen Licht und Schatten
	float light_step = smoothstep(shadow_threshold - shadow_softness, shadow_threshold + shadow_softness, NdotL * ATTENUATION);
	
	// Schatten bekommen eine satte Anime-Tönung statt trübem Dunkelgrau
	vec3 ambient_shade = mix(shadow_tint.rgb, vec3(1.0), light_step);
	vec3 diffuse_light = ALBEDO * LIGHT_COLOR * ambient_shade;

	// Toon Specular Highlight (Präzise Anime-Reflexion für Panzer/Klingen/Aura)
	vec3 half_vector = normalize(VIEW + LIGHT);
	float NdotH = max(dot(NORMAL, half_vector), 0.0);
	float spec_pow = pow(NdotH, (1.0 - roughness) * 96.0 + 8.0);
	float spec_step = step(0.88, spec_pow) * (metallic > 0.15 ? 1.4 : 0.4);
	vec3 specular_light = spec_step * LIGHT_COLOR * (metallic > 0.3 ? ALBEDO : vec3(1.0));

	// Anime Grazing Rim Contour
	float rim = 1.0 - max(dot(VIEW, NORMAL), 0.0);
	float rim_step = step(0.62, rim) * max(dot(NORMAL, LIGHT) + 0.35, 0.0) * rim_strength;
	vec3 rim_light = rim_step * rim_color.rgb * LIGHT_COLOR * 0.8;

	DIFFUSE_LIGHT += diffuse_light + specular_light + rim_light;
}
