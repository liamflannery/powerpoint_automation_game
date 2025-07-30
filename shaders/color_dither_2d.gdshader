/*
    Asset: Godot Color Dither (Modified)
    File: color_dither_2d.gdshader
    Description: A color dither shader with threshold-based dithering
*/
shader_type canvas_item;
render_mode unshaded;


// Pixel offset used only for alpha dithering
uniform vec2 alpha_dither_pixel_offset = vec2(0.0);

uniform bool enabled = true;
/*
    Modified color_dither_include.gdshaderinc with threshold functionality
*/
const mat4 bayer_matrix = mat4(
    vec4(00.0 / 16.0, 12.0 / 16.0, 03.0 / 16.0, 15.0 / 16.0),
    vec4(08.0 / 16.0, 04.0 / 16.0, 11.0 / 16.0, 07.0 / 16.0),
    vec4(02.0 / 16.0, 14.0 / 16.0, 01.0 / 16.0, 13.0 / 16.0),
    vec4(10.0 / 16.0, 06.0 / 16.0, 09.0 / 16.0, 05.0 / 16.0));

// Get the dither value from a 4x4 Bayer Matrix
float get_dither_value(vec2 pixel) {
    int x = int(pixel.x - 4.0 * floor(pixel.x / 4.0));
    int y = int(pixel.y - 4.0 * floor(pixel.y / 4.0));
    return bayer_matrix[x][y];
}

// Pixel size used in dithering
uniform float dither_pixel_size = 1.0;
// The pixel offset used for dithering
uniform vec2 dither_pixel_offset = vec2(0.0);
// Albedo color
uniform vec4 albedo : source_color = vec4(1.0);
// Albedo multiplier
uniform float albedo_strength = 1.0;
// Dithering threshold - higher values = less dithering, more solid colors
uniform float dither_threshold : hint_range(0.0, 1.0) = 0.3;

#if defined(IS_POSTPROCESSOR)
// Used as a screen-reading postprocessor
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest, repeat_disable;

vec4 get_albedo(vec2 uv) {
    return texture(screen_texture, uv) * vec4(albedo.rgb * albedo_strength, 1.0);
}

vec2 get_pixel_center(vec2 uv) {
    return floor(uv * vec2(textureSize(screen_texture, 0)) / dither_pixel_size + dither_pixel_offset) + 0.5;
}
#else
// Used as a regular material
vec4 get_albedo(sampler2D texture_albedo, vec2 uv) {
    return texture(texture_albedo, uv) * albedo * vec4(vec3(albedo_strength), 1.0);
}

vec2 get_pixel_center(sampler2D texture_albedo, vec2 uv) {
    return floor(uv * vec2(textureSize(texture_albedo, 0)) / dither_pixel_size + dither_pixel_offset) + 0.5;
}
#endif

// The dither palette texture
uniform sampler2D dither_palette : source_color, filter_nearest;

// Get two adjacent palette colors for comparison
vec4 get_palette_color_at_index(float color_index, vec4 color) {
    vec2 palette_size = vec2(textureSize(dither_palette, 0));
    float y = (clamp(color.g * 16.0, 0.5, 15.5) + color_index * 16.0) / palette_size.y;
    float x = clamp(floor(color.r * 16.0), 0.0, 15.0) / 16.0 + clamp(color.b * 16.0, 0.5, 15.5) / 256.0;
    return texture(dither_palette, vec2(x, y));
}

// Return the dither value for a color with threshold consideration
vec4 get_dither_color_with_threshold(float dither_value, vec4 color) {
    vec2 palette_size = vec2(textureSize(dither_palette, 0));
    float color_count = floor((palette_size.y + 1.0) / 16.0);

    // Calculate which two colors we'd be dithering between
    float exact_color_index = dither_value * color_count;
    float lower_index = floor(exact_color_index);
    float upper_index = min(lower_index + 1.0, color_count - 1.0);

    // Get the two palette colors
    vec4 lower_color = get_palette_color_at_index(lower_index, color);
    vec4 upper_color = get_palette_color_at_index(upper_index, color);

    // Calculate color difference (using perceptual weighting)
    vec3 color_diff = upper_color.rgb - lower_color.rgb;
    float color_distance = sqrt(
        0.299 * color_diff.r * color_diff.r +
        0.587 * color_diff.g * color_diff.g +
        0.114 * color_diff.b * color_diff.b
    );

    // If color difference is below threshold, use the nearest solid color
    if (color_distance < dither_threshold) {
        float fraction = exact_color_index - lower_index;
        float chosen_index = (fraction < 0.5) ? lower_index : upper_index;
        return vec4(get_palette_color_at_index(chosen_index, color).rgb, 1.0);
    }

    // Otherwise, use normal dithering
    float y = (clamp(color.g * 16.0, 0.5, 15.5) + floor(dither_value * color_count) * 16.0) / palette_size.y;
    float x = clamp(floor(color.r * 16.0), 0.0, 15.0) / 16.0 + clamp(color.b * 16.0, 0.5, 15.5) / 256.0;
    return vec4(texture(dither_palette, vec2(x, y)).rgb, 1.0);
}
void fragment() {
    vec4 color = get_albedo(TEXTURE, UV);
    vec2 pixel = get_pixel_center(TEXTURE, UV);
    float dither_value_alpha = get_dither_value(pixel + alpha_dither_pixel_offset);

    if (color.a <= dither_value_alpha) {
        discard;
    }

    float dither_value = get_dither_value(pixel);
	if(enabled){
    	COLOR = get_dither_color_with_threshold(dither_value, color);
		}
	else{

	}
}