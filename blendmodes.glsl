extern Image drawingImage; //This is image being added
extern vec2 pos; //Position on screen
extern vec2 size; //Size of image.
extern int typeBlend;
vec4 result ; //result
int i = 0 ; //increment for "for" loop

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{

vec4 DRAW_C = Texel(drawingImage, vec2(
	texture_coords.x * love_ScreenSize.x/size.x - pos.x/size.x ,
	texture_coords.y * love_ScreenSize.y/size.y - pos.y/size.y));
vec4 SOURCE_C = Texel(texture, texture_coords );


if (typeBlend == 0)
{
	result = (1-(1-SOURCE_C) * (1-DRAW_C)) ; //Screen blend
}
else
{
	if (typeBlend == 1)
	{
		result = (SOURCE_C * DRAW_C) ; //Multi blend
	}
	else
	{
	for ( i = 0; i < 3; i++ )
	    {
	    	result[i] = (SOURCE_C[i] < 0.5) ?
	    		(2*SOURCE_C[i] * DRAW_C[i]) : //Multi blend
	    		(1-2*(1-SOURCE_C[i]) * (1-DRAW_C[i])) ; //Screen blend
		}
	}
}

//result = (SOURCE_C*(1-DRAW_C.a)+result); // premultiplied

result = (SOURCE_C*(1-DRAW_C.a)+result*DRAW_C.a) ; // alpha blend
result.a = (SOURCE_C.a*(1-DRAW_C.a)+DRAW_C.a) ;

//Avoid drawing outside the DRAW_C texture
if(texture_coords.x * love_ScreenSize.x < pos.x ||
	texture_coords.y * love_ScreenSize.y < pos.y ||
	texture_coords.x * love_ScreenSize.x > pos.x + size.x ||
	texture_coords.y * love_ScreenSize.y > pos.y + size.y
	)
	{
		return SOURCE_C;
	}

return result;
}