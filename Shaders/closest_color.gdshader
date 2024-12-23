shader_type canvas_item;

//uniform vec3 palette[8];

uniform sampler2D palette_texture; //will show up in the inspector, can put our palette into it
uniform int palette_size; // can define in the inspector
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
// Called for every pixel the material is visible on.
void fragment() {

	vec3 pixel_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;

	// find closest palette color
	float min_distance = 100000.0; // start with a huge number
	vec3 closest_color = vec3(0.0); // assign each channel to 0.0
	for (int i = 0; i < palette_size; i++) {
		// calculate NORMALIZED position in the palette
		float t = float(i) / float(palette_size - 1);
		// sample color from the palette
		vec3 palette_color = texture(palette_texture, vec2(t,0.5)).rgb;
		float current_distance = distance(pixel_color, palette_color);
		if (current_distance < min_distance) {
			min_distance = current_distance;
			closest_color = palette_color;
		}
	}
	//output closest color
	COLOR = vec4(closest_color, 1.0);

}
