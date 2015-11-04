// This file is concatenated in front of other shaderfiles to give them access to generic functions.

vec4 loadImage(Image loadImage , vec2 texture_coords , vec2 pos, vec2 size )
{
	return Texel(loadImage, vec2(
		texture_coords.x * love_ScreenSize.x/size.x - pos.x/size.x ,
		texture_coords.y * love_ScreenSize.y/size.y - pos.y/size.y));
}

vec4 alphaBlend(vec4 SOURCE_C , vec4 DRAW_C , vec4 result)
{
	result = (SOURCE_C*(1-DRAW_C.a)+result*DRAW_C.a) ; // alpha blend
	result.a = (SOURCE_C.a*(1-DRAW_C.a)+DRAW_C.a) ;
	return result;
}


//Avoid drawing outside the DRAW_C texture
vec4 clipOutline(vec2 texture_coords, vec2 pos, vec2 size, vec4 SOURCE_C , vec4 result)
{
	if( texture_coords.x * love_ScreenSize.x < pos.x ||
	texture_coords.y * love_ScreenSize.y < pos.y ||
	texture_coords.x * love_ScreenSize.x > pos.x + size.x ||
	texture_coords.y * love_ScreenSize.y > pos.y + size.y )
	{
		return SOURCE_C;
	}
	else
	{
		return result;
	}
	
} 


extern float brightness = 0;
extern float contrast = 1;
extern bool whiteToAlpha = true;
extern float desaturateValue = 0;

vec3 contrastMath(vec4 value)
{
	vec3 result = vec3(value.r,value.g,value.b);
	result = (result-0.5)*contrast+0.5;
	return result;
}

vec3 brightnessMath(vec4 value)
{
	vec3 result = vec3(value.r,value.g,value.b);
	return result+brightness;
}

vec4 whiteToAlphaFunction(vec4 value)
{
	if (whiteToAlpha == true)
	{
		float temp = 1-(value.r + value.g + value.b)/3;
		return vec4(0,0,0, temp );
	}
	return value;
}

vec4 desaturate(vec4 value)
{
	float num = (value.r+value.g+value.b)/3;
	vec3 result = vec3(value.r,value.g,value.b);

	result = result*desaturateValue + num * (1-desaturateValue);

	return vec4(result,value.a);
}

