shader_type canvas_item;

uniform float rotation_degrees : hint_range(0.0, 360.0) = 0.0;

void fragment() {
    // Convert degrees to radians
    float rotation_radians = rotation_degrees * PI / 180.0;
    
    // Get UV coordinates centered around 0.5, 0.5
    vec2 centered_uv = UV - vec2(0.5, 0.5);
    
    // Create rotation matrix
    float cos_angle = cos(rotation_radians);
    float sin_angle = sin(rotation_radians);
    mat2 rotation_matrix = mat2(vec2(cos_angle, -sin_angle), vec2(sin_angle, cos_angle));
    
    // Apply rotation
    vec2 rotated_uv = rotation_matrix * centered_uv;
    
    // Move back to 0-1 range
    rotated_uv += vec2(0.5, 0.5);
    
    // Sample the texture with rotated UV coordinates
    // Use fract to wrap UV coordinates and keep them in 0-1 range
    COLOR = texture(TEXTURE, fract(rotated_uv));
}