extern vec2 textureResolution;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec2 uv = texture_coords;

	uv = uv*textureResolution + 0.5;
	vec2 iuv = floor( uv );
	vec2 fuv = fract( uv );
	uv = iuv + fuv*fuv*(3.0-2.0*fuv); 
	uv = (uv - 0.5)/textureResolution;
	vec4 colB = texture2D( texture, uv );

	vec4 result = colB * color;

	return result;
}