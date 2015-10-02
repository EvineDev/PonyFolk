extern Image drawingImage; //This is image being added
extern vec2 pos; //Position on screen
extern vec2 size; //Size of image Being added.
vec4 result ; //result

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 DRAW_C = loadImage( drawingImage ,  texture_coords ,  pos,  size );
	vec4 SOURCE_C = Texel(texture, texture_coords );

	for ( int i = 0; i < 3; i++ )
	{
		result[i] = (SOURCE_C[i] < 0.5) ?
			(2*SOURCE_C[i] * DRAW_C[i]) : //Multi blend
			(1-2*(1-SOURCE_C[i]) * (1-DRAW_C[i])) ; //Screen blend
	}
		
	//result = (SOURCE_C*(1-DRAW_C.a)+result); // premultiplied

	result = alphaBlend(SOURCE_C , DRAW_C , result);
	result = clipOutline(texture_coords, pos, size, SOURCE_C, result);


	return result;
}

