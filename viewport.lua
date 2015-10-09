viewport = viewport or {}
if viewport.init == nil then
	viewport.scale = 1
	viewport.pushed = 0
	viewport.init = true
	viewport.translateX = 0
	viewport.translateY = 0
	viewport.width = 1920
	viewport.height = 1080
end



function viewport.load()
	viewport.fullCanvas = love.graphics.newCanvas(1920, 1080) -- unhard code this
	--viewport.halfCanvas = love.graphics.newCanvas(1920/2, 1080/2) -- uncomment this for trilinear filtering
	love.graphics.setCanvas(viewport.fullCanvas)
end


function viewport.push()
	love.graphics.setCanvas(viewport.fullCanvas)
	viewport.fullCanvas:clear()
	viewport.pushed = viewport.pushed + 1

	love.graphics.setColor(255,255,255)
end


function viewport.screenshot()
	if love.keyboard.isDown("0") then
		viewport.fullCanvas:getImageData():encode("screenshot.png")
	end
end


--Bilinear filter
function viewport.pop()
	love.graphics.setColor(255,255,255)

	local width , height = love.graphics.getDimensions()
	local widthScale , heightScale = width/1920 , height/1080
	love.graphics.setCanvas()
	love.graphics.setColor(255,255,255)
	do
		heart.push()

		if widthScale >= heightScale then
			viewport.scale = heightScale
			viewport.translateX = math.round(-(1920*viewport.scale-width)/2)
			viewport.translateY = 0
		else
			viewport.scale = widthScale
			viewport.translateX = 0
			viewport.translateY = math.round(-(1080*viewport.scale-height)/2)
		end

		--Debug
		if _Debug then
				viewport.translateY = love.graphics.getHeight() - 1080*viewport.scale
		end

		love.graphics.translate(viewport.translateX,viewport.translateY)
		love.graphics.draw(viewport.fullCanvas,0,0,0,viewport.scale)

		heart.pop()
	end
	love.graphics.setCanvas()
	
	viewport.pushed = viewport.pushed - 1
	
	love.graphics.setColor(255,255,255)
end


-- Trilinear filtering -- viewport.halfCanvas must be enabled NOT WORKING
--[[
function viewport.pop()
	love.graphics.setColor(255,255,255)

	love.graphics.setCanvas(viewport.halfCanvas)
	viewport.halfCanvas:clear()
	love.graphics.draw(viewport.fullCanvas,0,0,0,0.5)

	local width , height = love.graphics.getDimensions()
	local widthScale , heightScale = width/1920 , height/1080
	local scale
	love.graphics.setCanvas()
	love.graphics.setColor(255,255,255)
	love.graphics.push()


	if widthScale >= heightScale then
		scale = heightScale
		love.graphics.translate(math.round(-(1920*scale-width)/2),0)
	else
		scale = widthScale
		love.graphics.translate(0,math.round(-(1080*scale-height)/2))
	end

	-- Debug function
	if _Debug and not select(3,love.window.getMode()).fullscreen then
		love.graphics.origin()
		local hs = select(2,love.window.getDesktopDimensions())*love.window.getPixelScale()
		if love._os == "Windows" then
			hs = hs - 40*love.window.getPixelScale()
			love.graphics.translate(0, hs-540*love.window.getPixelScale() )
		elseif love._os == "OS X" then
			hs = hs - 23*love.window.getPixelScale()
			love.graphics.translate(0, hs-405*love.window.getPixelScale() )
		end
		--local hw = select(1,love.graphics.getDimensions()) -- maybe not fixed height??
		
	end
	
	local alphaBlend = ((scale + 2) - scale * 3) * 255
	
	
	if scale >= 1 then
		love.graphics.draw(viewport.fullCanvas,0,0,0,scale)
	elseif scale > 0.5 then
		love.graphics.draw(viewport.fullCanvas,0,0,0,scale) -- scaling here
		love.graphics.setColor(255,255,255,alphaBlend)
		love.graphics.draw(viewport.halfCanvas,0,0,0,2*scale)
	else
		love.graphics.draw(viewport.halfCanvas,0,0,0,2*scale)
	end

	love.graphics.pop()
	love.graphics.setCanvas()
	
	viewport.pushed = viewport.pushed - 1
	
	love.graphics.setColor(255,255,255)
end
--]]