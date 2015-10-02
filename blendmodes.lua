blendMode = blendMode or {}

blendMode.canvas = blendMode.canvas or love.graphics.newCanvas(1920,1080)
blendMode.overlay = blendMode.overlay or shader.new("blendmode/overlay.glsl")
blendMode.multiply = blendMode.multiply or shader.new("blendmode/multiply.glsl")
blendMode.screen = blendMode.screen or shader.new("blendmode/screen.glsl")

local AJi = AJi or love.graphics.newImage("blendmode/applejackbase.png")
local AJm = AJm or love.graphics.newImage("blendmode/applejackshade4.png")

function heart.graphics.draw(image,mode,x,y)
	x = x or 0
	y = y or 0
	if mode == "overlay" or mode == "multiply" or mode == "screen" then
		shader.set(blendMode[mode])
		blendMode[mode]:send("drawingImage",image)
		blendMode[mode]:send("pos",{x,y})
		blendMode[mode]:send("size",{image:getWidth(),image:getHeight()})
	else
		assert(false, "Invalid blend mode, \""..tostring(mode).."\"\nValid blend modes == \"screen\" , \"multiply\" , \"overlay\"")
	end
	love.graphics.draw(viewport.fullCanvas)
	shader.set()
end

function blendModeDrawingsTEST()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(AJi,0,-300)
	love.graphics.setColor(255,255,255)
	heart.graphics.draw(AJm,"overlay",200,200)
end
