filter = {}

base = base or love.graphics.newImage("filter/base.png") -- -0.468,-0.148

AJ = AJ or love.graphics.newImage("blendmode/applejackbase.png")


filter.filterBC = shader.new("filter/filterBC.glsl")
brightnessValue = brightnessValue or 0
contrastValue = contrastValue or 1
desaturateValue = desaturateValue or 1



function filter.draw()
	shader.set(filter.filterBC)
	filter.filterBC:send("brightness",brightnessValue)
	filter.filterBC:send("contrast",contrastValue)
	filter.filterBC:send("desaturateValue",desaturateValue)
	filter.filterBC:send("whiteToAlpha",false)
	love.graphics.setColor(255,255,255)
	love.graphics.draw(AJ,0,-300,0,1)
	shader.set()

	brightnessValue = ui.slider(brightnessValue,50,50,500,150,-1,1) -- Normally -1 to 1
	contrastValue = ui.slider(contrastValue,50,200,500,150,0,10) -- Normally 0 to 10
	desaturateValue = ui.slider(desaturateValue,50,350,500,150,0,1) -- Normally 0 to 10

end
