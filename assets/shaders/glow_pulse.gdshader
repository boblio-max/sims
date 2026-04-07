shader_type spatial;
render_mode blend_add, cull_disabled;

uniform vec4 glow_color : source_color = vec4(0.0, 0.5, 1.0, 1.0);
uniform float speed : hint_range(0.1, 5.0) = 2.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    float pulse = (sin(TIME * speed) + 1.0) * 0.5;
    ALBEDO = glow_color.rgb;
    ALPHA = glow_color.a * (pulse * intensity + (1.0 - intensity));
    EMISSION = glow_color.rgb * 2.0;
}
