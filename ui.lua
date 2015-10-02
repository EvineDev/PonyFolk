ui = ui or {}
if ui.init == nil then
	love.graphics.setLineJoin("none")
	ui.init = true
end


function ui.graph(tableName , x , y , width , height , rangeMin , rangeMax, expectedValue1, expectedValue2)
	local concatTable = {}
	local tableLength = #tableName
	
	-- X axis
	local strechX = (tableLength/(tableLength-1)  *  width/tableLength)

	-- Y axis
	local scale = height / (rangeMax - rangeMin)
	local strechY = y + height + rangeMin*scale
	if tableLength >= 2 then

		for i = 2 , tableLength*2 , 2 do
			concatTable[i-1] = (i*0.5-1) * strechX + x
			concatTable[i] = (-tableName[i*0.5] * scale) + strechY
		end
		love.graphics.line(concatTable)
	end

	love.graphics.rectangle("line",x,y,width,height)	
		
	local fontOffset = (love.graphics.getFont():getHeight()) * 0.6
	love.graphics.print(rangeMax,x+width+fontOffset*0.5,y-fontOffset)
	love.graphics.print(rangeMin,x+width+fontOffset*0.5,y+height-fontOffset)

	if expectedValue1 ~= nil then
		love.graphics.print(expectedValue1,x+width+fontOffset*0.5,y+height+(-expectedValue1+rangeMin)*scale-fontOffset)
		love.graphics.line(
			x,
			y+height+(-expectedValue1+rangeMin)*scale,
			x+width,
			y+height+(-expectedValue1+rangeMin)*scale)
	end
	if expectedValue2 ~= nil then
		love.graphics.print(expectedValue2,x+width+fontOffset*0.5,y+height+(-expectedValue2+rangeMin)*scale-fontOffset)
		love.graphics.line(
			x,
			y+height+(-expectedValue2+rangeMin)*scale,
			x+width,
			y+height+(-expectedValue2+rangeMin)*scale)
	end
end

function ui.slider(input,x,y,width,height,rangeMin,rangeMax)
	input = input or 0


	local length = rangeMax - rangeMin
	local scale = width / length

	
	if mouse.x > x-20 and
		mouse.x < x+width+20 and
		mouse.y > y and
		mouse.y < y+height then
		if love.mouse.isDown("l") then
			input = ((mouse.x+rangeMin*scale)-x)/scale
		end
	end

	input = math.min(input , rangeMax )
	input = math.max(input , rangeMin)

	local pos = scale * input
	love.graphics.setColor(90,20,20)
	love.graphics.rectangle("fill",x,y,width,height)
	love.graphics.setColor(160,20,20)
	love.graphics.rectangle("fill",(x+pos-rangeMin*scale)-2,y,4,height)
	love.graphics.setColor(230,230,230)
	love.graphics.rectangle("line",x-20,y,width+40,height)
	love.graphics.setColor(255,255,255)
	return input
end


function ui.test()
	bird.pos[1] = ui.slider(bird.pos[1],
		20,20,
		500,50,
		0,1920)
	bird.pos[2] = ui.slider(bird.pos[2],
		20,90,
		500/16*9,50,
		0,1080)
	--bird.size[1] = ui.slider(bird.size[1],
	--	20,160,
	--	200,50,
	--	0,200)
	--bird.size[2] = ui.slider(bird.size[2],
	--	20,230,
	--	100,50,
	--	0,100)
end
