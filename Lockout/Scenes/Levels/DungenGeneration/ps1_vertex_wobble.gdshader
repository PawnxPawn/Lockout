shader_type spatial;
render_mode diffuse_burley, specular_disabled;

uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_enable;
uniform bool use_albedo_texture = false;
uniform vec4 albedo_tint : source_color = vec4(1.0);
uniform float wobble_strength : hint_range(0.0, 0.05) = 0.006;
uniform float wobble_speed : hint_range(0.0, 10.0) = 1.0;
uniform float vertex_snap_pixels : hint_range(0.0, 8.0) = 2.0;
uniform float roughness_value : hint_range(0.0, 1.0) = 1.0;

void vertex() {
    // Small, object-space movement to suggest unstable low-poly geometry.
    float phase = TIME * wobble_speed;
    VERTEX.x += sin(phase + VERTEX.y * 3.1) * wobble_strength;
    VERTEX.y += cos(phase * 0.83 + VERTEX.x * 2.7) * wobble_strength * 0.65;

    // Snap clip-space vertex positions to a coarse pixel grid.
    // This is an approximation of PS1 vertex jitter, not exact hardware emulation.
    if (vertex_snap_pixels > 0.0) {
        vec4 clip_pos = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
        vec2 ndc = clip_pos.xy / max(clip_pos.w, 0.00001);
        vec2 snap_grid = vec2(vertex_snap_pixels) / vec2(320.0, 240.0) * 2.0;
        ndc = floor(ndc / snap_grid + vec2(0.5)) * snap_grid;
        clip_pos.xy = ndc * clip_pos.w;
        POSITION = clip_pos;
    }
}

void fragment() {
    vec4 tex_color = vec4(1.0);
    if (use_albedo_texture) {
        tex_color = texture(albedo_texture, UV);
    }
    ALBEDO = (tex_color * albedo_tint).rgb;
    ROUGHNESS = roughness_value;
}
