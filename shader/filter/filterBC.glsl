
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 result = Texel(texture, texture_coords );
	result = vec4(brightnessMath(result),1);
	result = vec4(contrastMath(result),1);
	result = desaturate(result);
	result = whiteToAlphaFunction(result);



	return result*color;
}

