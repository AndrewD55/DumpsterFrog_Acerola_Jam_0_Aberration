
/*  Using Animated Stripes by "alxl" as a base for my conveyor belts shader
	https://godotshaders.com/shader/animated-stripes/    */
shader_type spatial;

uniform vec3 color_gap: source_color = vec3(0.33, 0.33, 0.33);
uniform vec3 color_stripe: source_color = vec3(0.55, 0.55, 0.55);
uniform float divisions = 10.0; // increase for more stripe density
uniform float stripe_bias = 2.5; // 1.0 means no stripes; 2.0 means stripes and gaps are equal size
uniform float speed = 1.0;
uniform float angle = 0.0; // in radians


//Uhh I may change this.. I know conditional logic is not ideal for shader code.
//.. but I don't have time to optimize this
void fragment() {
	float w = cos(angle) * UV.x + sin(angle) * UV.y - speed * TIME;
	if (floor(mod(w * divisions, stripe_bias)) < 0.0001) {
		ALBEDO = color_gap;
	} else {
		ALBEDO = color_stripe;
	}
}
