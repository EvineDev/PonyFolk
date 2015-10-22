
heart.hotLoad("entity.lua",true)
heart.hotLoad("tile.lua",true) -- clear tile table, Remove for release.

grid = grid or {}


grid.block = {}
grid.size = 23 -- Calculate this maybe???
assert(grid.size/2 ~= math.floor(grid.size/2), "grid.size must be a odd number" )
--grid.blockSizeWidth = 300 -- 300 is default Height is half the width
--grid.blockSize = grid.blockSizeWidth/(math.sqrt(2)*2) -- Backsolve from width
grid.blockSize = grid.blockSize or 8
grid.blockSizeWidth = grid.blockSizeWidth or grid.blockSize*(math.sqrt(2)*2) -- 100 default
grid.blockTranslateX, grid.blockTranslateY = 0,-12 --* grid.blockSizeWidth * 0.5

--print(grid.blockSizeWidth)

grid.outline = {}
grid.outline.width = 12
grid.outline.height = 12

grid.bufferDraw = {}

grid.mouse = v2.new()

grid.tilePressedX = 0
grid.tilePressedY = 0

--grid.blockSizeWidth = 1360
--grid.blockSize = 480.8326112
--Tile width  = 1360
--Tile height = 680
--Tile degrees = 63.434948822922°
--Tile degrees in 3D from topdown to isometric 60° 

--Wall tiles is 2.5 tiles high

--[[render a tile to canvas and print out 
ooijgrierg = love.graphics.newCanvas(620,300)
heart.push("all")
love.graphics.setNewFont(24)
--love.graphics.setBlendMode("premultiplied")
love.graphics.setCanvas(ooijgrierg)
love.graphics.setColor(255,255,255)

love.graphics.rectangle("fill",0,0,600,300)
love.graphics.setColor(0,0,0)
love.graphics.line(
	100,150,
	300,50,
	500,150,
	300,250,
	100,150)

ooijgrierg:getImageData():encode("isometrictileblank.png")

love.graphics.rectangle("line",100,50,400,200)
love.graphics.printf("Width 400",0,20,600,"center")
love.graphics.printf("Height\n200",520,120,620,"left")
love.graphics.printf("Angle\n63.435°",0,120,260,"right")


ooijgrierg:getImageData():encode("isometrictile.png")

heart.pop()
love.graphics.setCanvas()
--]]


function grid.mousepressed(button)
	grid.tilePressedX = math.round(grid.mouse.x)
	grid.tilePressedY = math.round(grid.mouse.y)
end


local function compareKey(a,b,key)
	return a[key] < b[key]
end


local function compareBufferZlevel(a,b)
	return compareKey(a,b,"bufferZlevel")
end


local function coverPoly(inTable)
	local x,y,w,h = inTable.x , inTable.y ,  inTable.w , inTable.h


	local t1, t2 = translateToScreen(x+w+0.5,y+h+0.5)
	local t3, t4 = translateToScreen(x-0.5,y+h+0.5)
	local t5, t6 = translateToScreen(x-0.5,y+h+0.5,4)
	local t7, t8 = translateToScreen(x-0.5,y-0.5,4)
	local t9, t10 = translateToScreen(x+w+0.5,y-0.5,4)
	local t11, t12 = translateToScreen(x+w+0.5,y-0.5)
	love.graphics.polygon("fill",t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12)

	local centerx, centery = translateToScreen(x+w+0.5,y+h+0.5,4)
	love.graphics.setColor(0,0,0)
	love.graphics.line(centerx, centery , translateToScreen(x+w+0.5,y-0.5,4))
	love.graphics.line(centerx, centery , translateToScreen(x-0.5,y+h+0.5,4))
	love.graphics.line(centerx, centery , translateToScreen(x+w+0.5,y+h+0.5,0))
	love.graphics.polygon("line",t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12)
end


function grid.mouseupdate()
	grid.mouse.x , grid.mouse.y = translateToIso(mouse.x,mouse.y)
end


function grid.update()	
	if false then
		for x = -grid.size/2 + 0.5 , grid.size/2-0.5 do
			grid.block[x] = {}
			for y = -grid.size/2 + 0.5 , grid.size/2-0.5 do
				grid.block[x][y] = 0
			end
		end
	end

	--love.graphics.print( math.round(grid.mouse.x).."\n"..math.round(grid.mouse.y) )
	--love.graphics.printf("mouse cordinates\n"..grid.mouse.x.."\n"..grid.mouse.y,0,0,1920,"right")
	
	-- Grid transformation
	heart.push()
	--love.graphics.translate(viewport.width/2,viewport.height/2)
	--love.graphics.scale(2,1)
	--love.graphics.rotate(math.pi/4)
	--Test outline
	--love.graphics.setColor(0,0,0)
	--love.graphics.circle("line",0,0,(grid.blockSize*grid.size*0.5)*math.sqrt(2))
	heart.pop()

	
	--[[
	for x = -grid.size/2 + 0.5 , grid.size/2-0.5 do
		for y = -grid.size/2 + 0.5 , grid.size/2-0.5 do
			--if  math.abs(x) + math.abs(y) < grid.outline.width and y + x < grid.outline.height and y + x > -grid.outline.height or math.abs(x) + math.abs(y) < grid.outline.height and y - x < grid.outline.width and y - x > -grid.outline.width then

			local point1 , point2 = translateToScreen(x+0.5,y+0.5)
			local point3 , point4 = translateToScreen(x+0.5,y-0.5)
			local point5 , point6 = translateToScreen(x-0.5,y-0.5)
			local point7 , point8 = translateToScreen(x-0.5,y+0.5)

			--love.graphics.polygon("line",point1,point2,point3,point4,point5,point6,point7,point8)
			--end
		end
	end
	--]]
	--Outline Square
	if false then
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("line",
			(1920-grid.outline.width*grid.blockSizeWidth)/2,
			(1080-grid.outline.height*grid.blockSizeWidth*0.5)/2,
			grid.outline.width*grid.blockSizeWidth,
			grid.outline.height*grid.blockSizeWidth*0.5)
	end
	
	--[[Simplest X then Y drawing
	local color = 0
	for x = -grid.size/2 + 0.5 , grid.size/2-0.5 do
		for y = -grid.size/2 + 0.5 , grid.size/2-0.5 do
			--if  math.abs(x) + math.abs(y) < grid.outline.width and y + x < grid.outline.height and y + x > -grid.outline.height or math.abs(x) + math.abs(y) < grid.outline.height and y - x < grid.outline.width and y - x > -grid.outline.width then

			love.graphics.setColor(heart.hsv(240/529*color,1,1))
			
			local point1 , point2 = translateToScreen(x+0.5,y+0.5)
			local point3 , point4 = translateToScreen(x+0.5,y-0.5)
			local point5 , point6 = translateToScreen(x-0.5,y-0.5)
			local point7 , point8 = translateToScreen(x-0.5,y+0.5)

			love.graphics.polygon("line",point1,point2,point3,point4,point5,point6,point7,point8)
			--end

			color = color+1
		end
	end
	printo(color)
	--]]

	--[[ From y on screen top to bottom grid 23x23
	local color = 0
	local yOnGrid = 1
	local gridDirection = 1
	while yOnGrid > 0 do
		if yOnGrid == 23 then
			gridDirection = -1
			--break
		end
		
		for i = 1, yOnGrid do
			color = color +1
			love.graphics.setColor(heart.hsv(240/529*color,1,1))
			local x,y
			local xOnGrid = (i-yOnGrid/2)-0.5
			if gridDirection == 1 then
				y = yOnGrid/2-11.5
				x = yOnGrid/2-11.5
			else
				y = -yOnGrid/2+11.5
				x = -yOnGrid/2+11.5
			end

			
			
			local point1 , point2 = translateToScreen(y+xOnGrid+0.5,x-xOnGrid+0.5)
			local point3 , point4 = translateToScreen(y+xOnGrid-0.5,x-xOnGrid+0.5)
			local point5 , point6 = translateToScreen(y+xOnGrid-0.5,x-xOnGrid-0.5)
			local point7 , point8 = translateToScreen(y+xOnGrid+0.5,x-xOnGrid-0.5)

			love.graphics.polygon("line",point1,point2,point3,point4,point5,point6,point7,point8)
		end

		yOnGrid=yOnGrid+gridDirection
	end
	printo(color)
	--]]

	--[[ Render x and y alternating
	if true then
		local color = 0
		local ink = grid.size
		local direction = true
		while ink > 0 do
			if direction then
				local y = (grid.size+1)/2-ink
				for x = y,math.floor(grid.size/2) do
					color = drawAndInk(x,y,color)
				end
			else
				local x = math.floor(grid.size/2)-ink
				for y = (grid.size+1)/2-ink,math.floor(grid.size/2) do
					color = drawAndInk(x,y,color)
				end
			end

			if direction then
				ink = ink-1
				direction = false
			else
				direction = true
			end
		end
	end
	--printo(color)
	--]]

	-- Select tile code
	---[[
	if true then
		love.graphics.setColor(255,255,255)
		drawTileWraped(grid.tilesq, math.round(grid.mouse.x),math.round(grid.mouse.y),0)
		if math.abs(grid.mouse.y-math.floor(grid.mouse.y)-0.5) > math.abs(grid.mouse.x-math.floor(grid.mouse.x)-0.5) then
			drawWallWraped(grid.wallsq, math.floor(grid.mouse.x)+0.5,math.round(grid.mouse.y),0,-1)

		else
			drawWallWraped(grid.wallsq, math.round(grid.mouse.x),math.floor(grid.mouse.y)+0.5,0,1)
		end
	end



	--drawTileWraped(grid.tilesq, 3,0,0,math.pi*2,1)
--[[
	drawWallWraped(grid.wallsq, 3,-0.5,0,1,0,1)

	
	--drawTileWraped(grid.tilesq, 1,1)
	--drawTileWraped(grid.tilesq, 2,1)
	--drawTileWraped(grid.tilesq, 3,1)
	--drawTileWraped(grid.tilesq, 1,2)
	--drawTileWraped(grid.tilesq, 2,2)
	--drawTileWraped(grid.tilesq, 3,2)
	--drawTileWraped(grid.tilesq, 1,3)
	--drawTileWraped(grid.tilesq, 2,3)
	--drawTileWraped(grid.tilesq, 3,3)

	drawWallWraped(grid.wallsq, 3.5,0,0,-1)
	drawWallWraped(grid.wallsq, 3.5,1,0,-1)
	drawWallWraped(grid.wallsq, 3.5,2,0,-1)
	drawWallWraped(grid.wallsq, 3.5,3,0,-1)

	drawWallWraped(grid.wallsq, 0, 3.5,0,1)
	drawWallWraped(grid.wallsq, 1, 3.5,0,1)
	
	drawWallWraped(grid.wallsq, 3, 3.5,0,1)

	--drawTileWraped(grid.tilesq, 2)
	drawWallWraped(grid.wallsq, 2,-0.5)
	--drawTileWraped(grid.tilesq, 1)
	drawWallWraped(grid.wallsq, 1,-0.5)
	--drawTileWraped(grid.tilesq, 0)
	drawWallWraped(grid.wallsq,0,-0.5)
	
	drawWallWraped(grid.wallsq,-0.5,0,0,-1)
	drawWallWraped(grid.wallsq, -0.5,1,0,-1)
	--drawTileWraped(grid.tilesq, 0,1)
	drawWallWraped(grid.wallsq, -0.5,2,0,-1)
	--drawTileWraped(grid.tilesq, 0,2)
	drawWallWraped(grid.wallsq, -0.5,3,0,-1)
	--drawTileWraped(grid.tilesq, 0,3)


	--drawWallWraped(grid.wallsq, 1+2, 3.6,0,1)
	

	--drawWallWraped(grid.wallsq, 3.6, 1+2,0,-1)
	--drawTileWraped(grid.tilesq,4,2,0)
	--drawTileWraped(grid.tilesq,3,2,0)

	--drawWallWraped(grid.wallsq, 2.5, 3.5,0,-1,0,1)	
	--drawTileWraped(grid.tilesq,2,4,0)
	--drawTileWraped(grid.tilesq,3,3,0)

	--drawTileDirect(tile.image, 2,0,0,0,1)
	--drawWallDirect(wall.image, 2,-0.5,0,0,1,1)
--]]

	
	
	-- HACK
	for i = 1, #tilecolworighreiogj do
		heart.sethsv((i-1)*(300/#tilecolworighreiogj),1,1,1)
		drawFlatTile(tilecolworighreiogj[i].x, tilecolworighreiogj[i].y)
	end

	-- Render from tile code
	if true then
		local color = 0
		for x = 1 , tile.width * 0.2 do
			for y = 1 , tile.height * 0.2 do
				color = drawAndInk(x,y,color)
				if tile[x][y].entityWallRight ~= 0 then
					drawWallWraped(grid.wallsq,x+0.5,y,0,-1)
				end
				if tile[x][y].entityWallLeft ~= 0 then
					drawWallWraped(grid.wallsq,x,y+0.5,0,1)
				end
			end
		end
	end


	-- Render stuff
	---[[
	if true then
		table.sort(grid.bufferDraw,compareBufferZlevel)
		local i = 1
		while i <= #grid.bufferDraw do 
		--while i <= 1+math.wrap(math.floor(_Time*2),#grid.bufferDraw) do -- Show render order.

			love.graphics.setColor(255,255,255,180)
			local buffer = grid.bufferDraw[i]
			local screenX , screenY = translateToScreen(buffer.x,buffer.y,buffer.z)
			if buffer.tileType == "wrappedWall" then
				love.graphics.draw(buffer.image,
					screenX,
					screenY,
					0,
					buffer.s*buffer.m,
					buffer.s,
					buffer.image:getWidth()*0.5,
					buffer.image:getHeight(),
					0,
					0.5)
			elseif buffer.tileType == "wrappedTile" then
				heart.push()
				love.graphics.translate(screenX,screenY)
				love.graphics.scale(2,1)
				love.graphics.draw(buffer.image,
					0,
					0,
					buffer.r+math.pi/4,
					buffer.s,
					buffer.s,
					buffer.image:getWidth()*0.5,
					buffer.image:getHeight()*0.5)

				heart.pop()
			end
			i = i+1
			
		end
	end
	grid.bufferDraw = {}
	--]]
	
	--[[
	local wallThickness = 0.2

	local pos = {}
	pos[1] = {-3,2}
	pos[2] = {-2,0}
	pos[3] = {1,-2}
	pos[4] = {3,-4}
	local posNorm = {}
	posNorm[1] = {4,4.5}
	posNorm[2] = {5.5,3}
	local wallHeight = 3.75
	--]]

--[[
	-- Proper corner outside
		love.graphics.setColor(108,52,0)
		drawFlatWall(pos[1][1]+wallThickness/4 , pos[1][2]+0.5+wallThickness/2 , 1+wallThickness/2,-1,wallHeight) -- left
		love.graphics.setColor(198,142,90)
		drawFlatWall(pos[1][1]+0.5+wallThickness/2 , pos[1][2]+wallThickness/4 , 1+wallThickness/2,1,wallHeight) -- right
		love.graphics.setColor(158,102,50)
		drawFlatTile(pos[1][1] , pos[1][2]+0.5 , 1 , wallThickness,wallHeight,"dl") -- left
		drawFlatTile(pos[1][1]+0.5 , pos[1][2] , wallThickness,1,wallHeight,"dr") -- right

	-- Proper corner inside
		love.graphics.setColor(108,52,0)
		drawFlatWall(pos[2][1]+wallThickness/4 , pos[2][2]-0.5+wallThickness/2,1-wallThickness/2,-1,wallHeight) -- right
		drawFlatWall(pos[2][1]-0.5 , pos[2][2]+0.5,wallThickness,-1,wallHeight) -- left
		love.graphics.setColor(198,142,90)
		drawFlatWall(pos[2][1]-0.5+wallThickness/2 , pos[2][2]+wallThickness/4,1-wallThickness/2,1,wallHeight) -- left
		drawFlatWall(pos[2][1]+0.5 , pos[2][2]-0.5,wallThickness,1,wallHeight) -- right
		love.graphics.setColor(158,102,50)
		drawFlatTile(pos[2][1] , pos[2][2]-0.5,1,wallThickness,wallHeight,"ul") -- right
		drawFlatTile(pos[2][1]-0.5 , pos[2][2],wallThickness,1,wallHeight,"ur") -- left

	-- Proper corner right
		love.graphics.setColor(108,52,0)
		drawFlatWall(pos[3][1]-wallThickness/4 , pos[3][2]-0.5+wallThickness/2,1-wallThickness/2,-1,wallHeight) -- Higher
		drawFlatWall(pos[3][1]+0.5 , pos[3][2]+0.5,wallThickness,-1,wallHeight) -- Lower
		love.graphics.setColor(198,142,90)
		drawFlatWall(pos[3][1]+0.5+wallThickness/2 , pos[3][2]-wallThickness/4,1+wallThickness/2,1,wallHeight) -- Lower
		love.graphics.setColor(158,102,50)
		drawFlatTile(pos[3][1] , pos[3][2]-0.5,1,wallThickness,wallHeight,"ru") -- Higher
		drawFlatTile(pos[3][1]+0.5 , pos[3][2],wallThickness,1,wallHeight,"rd") -- Lower

	-- Proper corner left
		love.graphics.setColor(198,142,90)
		drawFlatWall(pos[4][1]-0.5+wallThickness/2 , pos[4][2]-wallThickness/4,1-wallThickness/2,1,wallHeight) -- Higher
		drawFlatWall(pos[4][1]+0.5 , pos[4][2]+0.5,wallThickness,1,wallHeight) -- Lower
		love.graphics.setColor(108,52,0)
		drawFlatWall(pos[4][1]-wallThickness/4 , pos[4][2]+0.5+wallThickness/2,1+wallThickness/2,-1,wallHeight) -- Lower
		love.graphics.setColor(158,102,50)
		drawFlatTile(pos[4][1] , pos[4][2]+0.5,1,wallThickness,wallHeight,"ld") -- Lower
		drawFlatTile(pos[4][1]-0.5 , pos[4][2],wallThickness,1,wallHeight,"lu") -- Higher

	--Normal left wall
		love.graphics.setColor(108,52,0)
		drawFlatWall(posNorm[1][1],posNorm[1][2]+wallThickness/2,1,-1,wallHeight) -- left
		love.graphics.setColor(198,142,90)
		drawFlatWall(posNorm[1][1]+0.5,posNorm[1][2],wallThickness,1,wallHeight) -- left
		love.graphics.setColor(158,102,50)
		drawFlatTile(posNorm[1][1],posNorm[1][2],1,wallThickness,wallHeight) -- left

	--Normal right wall 
		love.graphics.setColor(108,52,0)
		drawFlatWall(posNorm[2][1],posNorm[2][2]+0.5,wallThickness,-1,wallHeight) -- right
		love.graphics.setColor(198,142,90)
		drawFlatWall(posNorm[2][1]+wallThickness/2,posNorm[2][2],1,1,wallHeight) -- right
		love.graphics.setColor(158,102,50)
		drawFlatTile(posNorm[2][1],posNorm[2][2],wallThickness,1,wallHeight) -- right
--]]
	--[[	--Polygon creation from line
	if false then
		local line = 
		{
			0,0.5,"l",
			0.5,1,"r",
			0.5,2,"r",
			0.5,3,"r",
		}

		love.graphics.setColor(0,0,0)
		for i = 1, #line, 3 do
			local x,y = translateToScreen(line[i],line[i+1])
			love.graphics.circle("fill",x,y,20)

			local x1a,y1a,x2a,y2a , x1b,y1b,x2b,y2b
			if line[i+2] == "r" then
				x1a,y1a = translateToScreen(line[i]-0.1,line[i+1]-0.5)
				x2a,y2a = translateToScreen(line[i]-0.1,line[i+1]+0.5)
				x1b,y1b = translateToScreen(line[i]+0.1,line[i+1]-0.5)
				x2b,y2b = translateToScreen(line[i]+0.1,line[i+1]+0.5)
			elseif line[i+2] == "l" then
				x1a,y1a = translateToScreen(line[i]-0.5,line[i+1]-0.1)
				x2a,y2a = translateToScreen(line[i]+0.5,line[i+1]-0.1)
				x1b,y1b = translateToScreen(line[i]-0.5,line[i+1]+0.1)
				x2b,y2b = translateToScreen(line[i]+0.5,line[i+1]+0.1)
			end
			love.graphics.line(x1a,y1a,x2a,y2a)
			love.graphics.line(x1b,y1b,x2b,y2b)
		end
		local posx,posy = viewport.width/2,viewport.height/2
		heart.push("all")
		love.graphics.setLineWidth(grid.blockSize*0.2)
		love.graphics.setLineJoin("miter")
		love.graphics.translate(posx,posy)
		love.graphics.scale(2,1)
		love.graphics.rotate(math.pi/4)

		love.graphics.line(grid.blockSize*0.5,0,grid.blockSize*0.5*3,0,grid.blockSize*0.5*3,grid.blockSize*0.5*2)

		heart.pop()
	end
	--]]




--[[
	love.graphics.setColor(230,230,230)
	--love.graphics.rectangle("fill",0,0,1920,1080)
	

	love.graphics.setColor(0,0,0)
	
	local pos = {{},{},{},{},{}}
	pos[1][1],pos[1][2] = translateToScreen(0+0.25,0-0.25,10)
	pos[1][3],pos[1][4] = translateToScreen(0+0.25,0-0.25,-10)
	pos[2][1],pos[2][2] = translateToScreen(0+0.75,0-0.75,10)
	pos[2][3],pos[2][4] = translateToScreen(0+0.75,0-0.75,-10)
	pos[3][1],pos[3][2] = translateToScreen(0-0.25,0+0.25,10)
	pos[3][3],pos[3][4] = translateToScreen(0-0.25,0+0.25,-10)
	pos[4][1],pos[4][2] = translateToScreen(0-0.75,0+0.75,10)
	pos[4][3],pos[4][4] = translateToScreen(0-0.75,0+0.75,-10)
	pos[5][1],pos[5][2] = translateToScreen(0+1.25,0-1.25,10)
	pos[5][3],pos[5][4] = translateToScreen(0+1.25,0-1.25,-10)

	love.graphics.line(pos[1])
	love.graphics.line(pos[2])
	love.graphics.line(pos[3])
	love.graphics.line(pos[4])
	love.graphics.line(pos[5])

	love.graphics.setColor(180,0,0)
	local pos = {{},{},{},{},{},{}}
	pos[1][1],pos[1][2] = translateToScreen(0,-1)
	pos[2][1],pos[2][2] = translateToScreen(1,-1)
	pos[3][1],pos[3][2] = translateToScreen(0,0)
	pos[4][1],pos[4][2] = translateToScreen(1,0)
	pos[5][1],pos[5][2] = translateToScreen(0,1)
	pos[6][1],pos[6][2] = translateToScreen(1,1)
	love.graphics.circle("fill",pos[1][1],pos[1][2],30)
	love.graphics.circle("fill",pos[2][1],pos[2][2],30)
	love.graphics.circle("fill",pos[3][1],pos[3][2],30)
	love.graphics.circle("fill",pos[4][1],pos[4][2],30)
	love.graphics.circle("fill",pos[5][1],pos[5][2],30)
	love.graphics.circle("fill",pos[6][1],pos[6][2],30)


	love.graphics.setColor(0,100,0)
	local pos = {{},{},{},{}}
	pos[1][1],pos[1][2] = translateToScreen(0.5,-0.5)
	pos[2][1],pos[2][2] = translateToScreen(1,-1)
	pos[3][1],pos[3][2] = translateToScreen(0.5,0.5)
	pos[4][1],pos[4][2] = translateToScreen(0,1)
	love.graphics.circle("fill",pos[1][1],pos[1][2],20)
	love.graphics.circle("fill",pos[2][1],pos[2][2],20)
	love.graphics.circle("fill",pos[3][1],pos[3][2],20)
	love.graphics.circle("fill",pos[4][1],pos[4][2],20)
--]]

	--love.graphics.setColor(100,100,100)
	--isocircle(math.round(grid.mouse.x),math.round(grid.mouse.y))
	--[[
	if mouse.left then
		local thingTable = {}
		local dirX,dirY = 1,1
		if grid.mouse.x < grid.tilePressedX then 
			dirX = -1
		end
		if grid.mouse.y < grid.tilePressedY then 
			dirY = -1
		end
		for x = grid.tilePressedX, math.round(grid.mouse.x), dirX do
			for y = grid.tilePressedY, math.round(grid.mouse.y), dirY do
				table.insert(thingTable,x)
				table.insert(thingTable,y)
				--isocircle(x,y)
			end
		end
		insertThing(thingTable)
	end
	--]]
	


	-- Sorting sprites. Note that I sort the sprites in the wrong direction then I go in the reverse of that table and render the sprites. (It shouldn't go in the wrong dirction)
	if true then
		local sortedTable = {}
		-- Test code mark inserts the sprites
		if mouse.beenReleased.left then 
			local x,y = grid.tilePressedX,grid.tilePressedY
			local w,h = math.round(grid.mouse.x)-grid.tilePressedX , math.round(grid.mouse.y)-grid.tilePressedY
			--grid.mark(x,y,w,h)
		end

		-- Create dependecies.
		for i = 1, entity.count do -- Loop over the objects
			if entity[i] ~= nil then
				for x = entity[i].x, entity[i].x+entity[i].w  do -- x axis
					for y = entity[i].y, entity[i].y+entity[i].h do -- y axis
						local t = tile[x][y].objectMark

						
						if t then
							if type(entity[i].dep) == "table" then
								-- Compare the elements returned by checkmarked with the elements in the table.
								-- Check if it's faster to reverse the j or g loop
								for j = 1, #t do
									for g = 1, #entity[i].dep do
										if entity[i].dep[g] == t[j] then
											goto foundInTable -- faster?? No variables initalized
										end
									end
									table.insert((entity[i].dep),t[j])
									::foundInTable::
								end
							else
								entity[i].dep = t
							end
						end
						love.graphics.setColor(0,255,0)
						--isocircle(x,y)
					end
				end
			else
				print("entity["..i.."] == nil")
			end
		end

		-- entity[i].dep is either a table or nil depending on if it overlap something.
		-- Indexes in entity[i].dep table is where in entity[index] the dependencies lie.

		-- draw a polygon on the covered area, Don't draw outside of this.
		-- Should be replaced with spritebatch:add or something

		
		if true then
			for i = 1, #entity do
				grid.recursiveInsert(i,sortedTable)
			end
			
			for i =  #sortedTable , 1 , -1 do
				local val = (sortedTable[i]/(#sortedTable))
				
				-- Draw sprite

				heart.sethsv((#sortedTable-i)*(300/#sortedTable), 1-val+0.2, val+0.2)
				coverPoly(entity[sortedTable[i]],#sortedTable-i)
				entity[sortedTable[i]].recorded = nil
			end
		end
		
	end

	


	grid.blockSize = ui.slider(grid.blockSize , 1300,910,600,150,2,500 )
	grid.blockSizeWidth = grid.blockSize*(math.sqrt(2)*2)
	
end


function grid.recursiveInsert(i,sortedTable)
	--printo(i,#entity)
	if entity[i] ~= nil and not entity[i].recorded then -- Am I sure this is a good solution to just skip if its nil?
		if entity[i].dep then
			for j = 1, #entity[i].dep do
				grid.recursiveInsert(entity[i].dep[j],sortedTable)
				--printv(i,"::",j)
			end
		end
		table.insert(sortedTable,i)
		--printv("Q"..i)

		entity[i].recorded = true
	end
end


function grid.mark(thing,x,y,w,h) -- 0 based: w,h
	assert(thing == "wallleft" or thing == "wallright" or thing == "object", "Invalid object being passed into grid.mark")
	w,h = w or 0, h or 0
	assert(type(x) == "number", "x is not a number")
	assert(type(y) == "number", "y is not a number")
	assert(x > 1 and x <= tile.width-1, "x is not in range")
	assert(y > 1 and y <= tile.height-1, "y is not in range")
	assert(thing == "wallleft" and w==0 and h==0 or thing == "wallright" and w==0 and h==0 or thing == "object", "width or height parameter must be 0,0 for walls grid.mark")
	if w < 0 then
		x = x+w
		w = -w
	end
	if h < 0 then
		y = y+h
		h = -h
	end

	-- These asserts shouldn't stop the game when it's running. So they need to rewired to give warning instead.
	if thing == "object" then
		for i = x, x+w do
			for j = y, y+h do
				--print(i,j)
				assert(tile[i][j].entityIndex == 0,"Object already inserted here")
				if i < x+w then
					--print(i,j)
					assert(tile[i][j].entityWallLeft == 0,"Wall Left is blocking object")
				end
				if j < y+h then
					--print(i,j)
					assert(tile[i][j].entityWallRight == 0,"Wall Right is blocking object")
				end
			end
		end
	elseif thing == "wallleft" then
		assert(tile[x][y].entityWallLeft == 0 , "Wall already inserted here")
		if tile[x][y].entityIndex ~= 0 and tile[x][y+1].entityIndex == tile[x][y].entityIndex then
			assert( false ,"Object is blocking wall")
		end
	elseif thing == "wallright" then
		assert(tile[x][y].entityWallRight == 0 , "Wall already inserted here")
		if tile[x][y].entityIndex ~= 0 and tile[x+1][y].entityIndex == tile[x][y].entityIndex then
			assert( false ,"Object is blocking wall")
		end
	end

	local where = heart.lengthSparse(entity)+1 -- Gets the first available "hole" in entity array.
	if where ~= #entity+1 then -- Check if the data messes up in this case. #entity+1 does not do what I want on a sparse array.
		print("---Check Array----",where,#entity+1)
	end
	entity.count = math.max(entity.count,where)
	entity[where] = {x=x,y=y,w=w,h=h} -- Should maybe insert more info here? 
	

	for i = x, x+w do
		for j = y, y+h do
			tile[i][j].entityIndex = where
		end
	end 


	for i = 1, h+1 do
		for j = 1, 4 do
			table.insert(tile[x-j][y+i-j].objectMark , where)
		end
	end
	for i = 1, w+1 do
		for j = 1, 4 do
			table.insert(tile[x+i-j][y-j].objectMark , where)
		end
	end
	for j = 1, 4 do
		table.insert(tile[x-j][y-j].objectMark , where)
	end
end


for x = 1, 5 do
	for y = 1, 5 do
		grid.mark("object",x*4+10,y*4+10,2,2)
	end
end

grid.mark("object",6,6,2,0)

--grid.mark("object",5,8,0,0)

--for i = 1, #entity do
--	print(entity[i].y)
--end


--[[
function insert2d(tableTo,x,y,thing)
	assert(type(tableTo) == "table","Trying to index on non table")
	if not tableTo[x] then
		tableTo[x] = {}
	end
	if not tableTo[x][y] then
		tableTo[x][y] = {}
	end
	table.insert(tableTo[x][y],thing)
end
--]]

--[[
function grid.insertWall(x,y,dir)
	assert(type(x) == "number", "x is not a number")
	assert(type(y) == "number", "y is not a number")
	assert(x > 1 and x <= tile.width-1, "x is not in range")
	assert(y > 1 and y <= tile.height-1, "y is not in range")
	assert(dir == 1 or dir == -1, "dir must be 1 or -1")


	if dir == 1 then
		--drawWallWraped(grid.wallsq,x,y+0.5,0,1)
		grid.mark("wallleft",x,y,0,0)
	elseif dir == -1 then
		--drawWallWraped(grid.wallsq,x+0.5,y,0,-1)
		grid.mark("wallright",x,y,0,0)
	end

	
end
--]]

--[[
refrigerator = love.graphics.newImage("Couchbw2.png")
testImage = love.image.newImageData("Couchbw2.png")


local count = 4 -- handle odd numbers
local var = (1/0.001)/(count/2)

part1 = love.image.newImageData(var,testImage:getHeight())
part2 = love.image.newImageData(var,testImage:getHeight())
part3 = love.image.newImageData(var,testImage:getHeight())
part4 = love.image.newImageData(var,testImage:getHeight())
part1:paste(testImage,0,0,testImage:getWidth()/2-var-var,0)
part2:paste(testImage,0,0,testImage:getWidth()/2-var,0)
part3:paste(testImage,0,0,testImage:getWidth()/2,0)
part4:paste(testImage,0,0,testImage:getWidth()/2+var,0)

someSofa1 = love.graphics.newImage(part1)
someSofa2 = love.graphics.newImage(part2)
someSofa3 = love.graphics.newImage(part3)
someSofa4 = love.graphics.newImage(part4)

function imageParse(filename)
	fileData = love.image.newImageData(filename)

	--Scale image to grid
	local scale = 0.001 -- grid.blockSizeWidth is very relevant to this.

	--Select area for object to rest on.
	local zTable = insertThing(
		0,-1,
		1,-1,
		0,0,
		1,0,
		0,1,
		1,1
		)

	-- #xTable is how many parts to split image into

	-- How to set an alignment 


end


function insertThing(...)
	local inputTable
	if type(select(1,...)) == "table" then
		inputTable = select(1,...)
	else
		inputTable = {...}
	end

	local count = #inputTable
	assert(math.floor(count/2) == count/2 and count > 1 , "insertThing must have x and y cordinates")
	local tableScreenSplit = {}
	local tableScreenSplitIndex = {}
	for i = 1, count, 2 do
		local x,y = inputTable[i] , inputTable[i+1]

		if tableScreenSplit[x-y] then 
			local wasMin = tableScreenSplit[x-y][2]
			local wasMax = tableScreenSplit[x-y][3]
			if x+y > wasMax then
				tableScreenSplit[x-y][3] = x+y -- Max value
			elseif x+y < wasMin then
				tableScreenSplit[x-y][2] = x+y -- Min value
			end
		else
			table.insert(tableScreenSplitIndex,x-y)
			tableScreenSplit[x-y] = {x-y,x+y,x+y}
		end
		love.graphics.setColor(0,0,0)
		isocircle(x,y,0,0.5)
	end
	love.graphics.setColor(100,0,0)

	-- Now I know i need to split this in 4 images
	local resultTable = {}
	for i = 1, #tableScreenSplitIndex do
		local k = tableScreenSplitIndex[i]
		local x = tableScreenSplit[k][1]
		local y = (tableScreenSplit[k][2] + tableScreenSplit[k][3])/2

		love.graphics.setColor(heart.hsv(90/4*(i-1),1,1))
		table.insert(resultTable, (y+x)/2 )
		table.insert(resultTable, (y-x)/2 )

		isocircle((y+x)/2,(y-x)/2,0,0.3)
		love.graphics.setColor(100,0,0)
		--isocircleRender(x,y,0,0.25)
	end
	return resultTable

end

--]]


function renderTranslateToScreen(x,y)
	x = x*(grid.blockSizeWidth/2)
	y = y*(grid.blockSizeWidth/4)
	x,y = x+viewport.width/2,y+viewport.height/2
	return x,y
end


function isocircle(x,y,z,s)
	s = s or 0.3
	s = s * grid.blockSize
	local screenX , screenY = translateToScreen(x,y,z)
	love.graphics.circle("fill",screenX,screenY,s)
end


--[[
function isocircleRender(x,y,z,s)
	s = s or 0.3
	s = s * grid.blockSize
	local screenX , screenY = renderTranslateToScreen(x,y)
	love.graphics.circle("fill",screenX,screenY,s)
end
--]]


function drawWallWraped( image, x,y,z,m,r,s)
	assert(m == nil or m == 1 or m == -1 , "m ,Mirror value must be nil, 1 or -1")
	x,y,z,s,m = x or 0 , y or 0 , z or 0 , s or 1 , m or 1
	s = s * (grid.blockSizeWidth/(image:getWidth()*2))

	--[[-- rotation code
	www = math.pi*0.5
	m = -m
	local length = math.sqrt(x*x+y*y)
	local angle = math.atan2(y,x)
	x = math.cos(angle+www)*length
	y = math.sin(angle+www)*length
	--]]

	local bufferZlevel = x+y

	local toInsertInTable = 
	{
		bufferZlevel = bufferZlevel,
		image = image,
		x = x,
		y = y,
		z = z,
		m = m,
		r = r,
		s = s,
		tileType = "wrappedWall"
	}

	table.insert(grid.bufferDraw , toInsertInTable)
end


function drawTileWraped( image,x,y,z,r,s) -- Figure out rectangle shapes -- Mirror shapes -s ??
	x,y,z,r,s = x or 0 , y or 0 , z or 0 , r or 0 , s or 1

	s = s * (grid.blockSize/image:getWidth())

	local bufferZlevel = x+y

	local toInsertInTable =
	{
		bufferZlevel = bufferZlevel,
		image = image,
		x = x,
		y = y,
		z = z,
		r = r,
		s = s,
		tileType = "wrappedTile"
	}

	table.insert(grid.bufferDraw , toInsertInTable)
end



--[[

grid.thingOrder = {}
grid.thingDraw = {}

local function checkTable(x,y,height)
	if grid.thingDraw[x] == nil then
		grid.thingDraw[x] = {}
	end
	if grid.thingDraw[x][y] == nil then
		grid.thingDraw[x][y] = {height}
	end
end

function insertThing(x,y,w,h)
	w,h=w or 1,h or 1
	for ix = 0,w-1 do
		for iy = 0,h-1 do
			checkTable(x+ix,y+iy)
		end
	end
end

function insertThingWall(x,y)
	if math.floor(x) == x and math.floor(y)+0.5 == y then
		for i = 1, 4 do
			checkTable(x-i+1,y-i+0.5 , i)
			checkTable(x-i,y-i+0.5 , i)
		end
	elseif math.floor(y) == y and math.floor(x)+0.5 == x then
		for i = 1, 4 do
			checkTable(x-i+0.5,y-i , i)
			checkTable(x-i+0.5,y-i+1 , i)
		end
	else
		assert(false, "invalid Wall position")
	end

end

function drawThing()
	for x , v in pairs(grid.thingDraw) do
		for y , t in pairs(v) do
			local screenX, screenY = translateToScreen(x,y)
			if t[1] == nil then
				love.graphics.setColor(0,0,0)
			else
				love.graphics.setColor(t[1]*50,0,0)
			end
			love.graphics.circle("fill",screenX,screenY,20)
			--printo("apples")

		end
	end

	grid.thingOrder = {}
	grid.thingDraw = {}
end

--]]


function drawAndInk(x,y,color)
	--if  math.abs(x) + math.abs(y) < grid.outline.width and y + x < grid.outline.height and y + x > -grid.outline.height or math.abs(x) + math.abs(y) < grid.outline.height and y - x < grid.outline.width and y - x > -grid.outline.width then
		color = color +1
		love.graphics.setColor(heart.hsv(240/221*color,1,1))
		drawPolygonTile(x,y)
	--end
	return color
end


function drawPolygonTile(x,y,mode)
	mode = mode or "line"
	local point1 , point2 = translateToScreen(x+0.5,y+0.5)
	local point3 , point4 = translateToScreen(x+0.5,y-0.5)
	local point5 , point6 = translateToScreen(x-0.5,y-0.5)
	local point7 , point8 = translateToScreen(x-0.5,y+0.5)
	love.graphics.polygon(mode,point1,point2,point3,point4,point5,point6,point7,point8)
end


--[[

grid.drawOrder = {}
grid.drawTable = {}

function insertWall(x,y,z,dir)
	local toInsert = {x=x, y=y, z=z, dir=dir}
	if grid.drawOrder[x] == nil then
		grid.drawOrder[x] = {}
		if grid.drawOrder[x][y] == nil then
			grid.drawOrder[x][y] = {}
		end
	end

	if grid.drawOrder[x+0.5] and grid.drawOrder[x+0.5][y-0.5] then
		toInsert.egde = "left"
		--Loop over index???
		grid.drawOrder[x+0.5][y-0.5][1].egde = "right"
	end
	table.insert(grid.drawTable, {x,y})
	table.insert(grid.drawOrder[x][y],toInsert)
end


function drawWall()

	for i = 1, #grid.drawTable do
		love.graphics.setColor(0,0,0)
		x,y = grid.drawTable[i][1],grid.drawTable[i][2]
		printo(x,y)
		local wall = grid.drawOrder[x][y][1]
		wall.x , wall.y = translateToScreen(wall.x,wall.y,wall.z)
		love.graphics.circle("fill",wall.x,wall.y,20)



		love.graphics.setColor(255,255,255)
		if wall.egde == "right" then
			love.graphics.circle("fill",wall.x-10,wall.y,5)
		elseif wall.egde == "left" then
			love.graphics.circle("fill",wall.x+10,wall.y,5)
		end


		printo(wall.egde)
	end

	grid.drawOrder = {}
	grid.drawTable = {}
end
--]]


function drawFlatTile(x,y,w,h,z,flag) -- Do this thing
	x,y,w,h,z = x or 0,y or 0,w or 1,h or 1, z or 0
	local point = {}
	if flag == "dl" then
		point[1] , point[2] = translateToScreen(x+w*0.5-h*0.5 , y-h*0.5 , z)
		point[3] , point[4] = translateToScreen(x+w*0.5+h*0.5 , y+h*0.5 , z)
		point[5] , point[6] = translateToScreen(x-w*0.5 , y+h*0.5 , z)
		point[7] , point[8] = translateToScreen(x-w*0.5 , y-h*0.5 , z)
	elseif flag == "dr" then
		point[1] , point[2] = translateToScreen(x+w*0.5 , y+h*0.5+w*0.5 , z)
		point[3] , point[4] = translateToScreen(x+w*0.5 , y-h*0.5 , z)
		point[5] , point[6] = translateToScreen(x-w*0.5 , y-h*0.5 , z)
		point[7] , point[8] = translateToScreen(x-w*0.5 , y+h*0.5-w*0.5 , z)
	elseif flag == "ul" then
		point[1] , point[2] = translateToScreen(x+w*0.5,y+h*0.5,z)
		point[3] , point[4] = translateToScreen(x+w*0.5,y-h*0.5,z)
		point[5] , point[6] = translateToScreen(x-w*0.5-h*0.5,y-h*0.5,z)
		point[7] , point[8] = translateToScreen(x-w*0.5+h*0.5,y+h*0.5,z)
	elseif flag == "ur" then
		point[1] , point[2] = translateToScreen(x+w*0.5,y+h*0.5,z)
		point[3] , point[4] = translateToScreen(x+w*0.5,y-h*0.5+w*0.5,z)
		point[5] , point[6] = translateToScreen(x-w*0.5,y-h*0.5-w*0.5,z)
		point[7] , point[8] = translateToScreen(x-w*0.5,y+h*0.5,z)
	elseif flag == "ru" then
		point[1] , point[2] = translateToScreen(x+w*0.5-h*0.5,y+h*0.5,z)
		point[3] , point[4] = translateToScreen(x+w*0.5+h*0.5,y-h*0.5,z)
		point[5] , point[6] = translateToScreen(x-w*0.5,y-h*0.5,z)
		point[7] , point[8] = translateToScreen(x-w*0.5,y+h*0.5,z)
	elseif flag == "rd" then
		point[1] , point[2] = translateToScreen(x+w*0.5,y+h*0.5,z)
		point[3] , point[4] = translateToScreen(x+w*0.5,y-h*0.5-w*0.5,z)
		point[5] , point[6] = translateToScreen(x-w*0.5,y-h*0.5+w*0.5,z)
		point[7] , point[8] = translateToScreen(x-w*0.5,y+h*0.5,z)
	elseif flag == "lu" then
		point[1] , point[2] = translateToScreen(x+w*0.5,y+h*0.5-w*0.5,z)
		point[3] , point[4] = translateToScreen(x+w*0.5,y-h*0.5,z)
		point[5] , point[6] = translateToScreen(x-w*0.5,y-h*0.5,z)
		point[7] , point[8] = translateToScreen(x-w*0.5,y+h*0.5+w*0.5,z)
	elseif flag == "ld" then
		point[1] , point[2] = translateToScreen(x+w*0.5,y+h*0.5,z)
		point[3] , point[4] = translateToScreen(x+w*0.5,y-h*0.5,z)
		point[5] , point[6] = translateToScreen(x-w*0.5+h*0.5,y-h*0.5,z)
		point[7] , point[8] = translateToScreen(x-w*0.5-h*0.5,y+h*0.5,z)
	else
		point[1] , point[2] = translateToScreen(x+w*0.5,y+h*0.5,z)
		point[3] , point[4] = translateToScreen(x+w*0.5,y-h*0.5,z)
		point[5] , point[6] = translateToScreen(x-w*0.5,y-h*0.5,z)
		point[7] , point[8] = translateToScreen(x-w*0.5,y+h*0.5,z)
	end
	love.graphics.polygon("fill",point)
	--lineThing(point)
end


function drawFlatWall(x,y,w,m,h,z)
	assert(m == nil or m == 1 or m == -1 , "m ,Mirror value must be nil, 1 or -1")
	x,y,w,m,h,z = x or 0,y or 0,w or 1,m or 1,h or 2.5,z or 0

	local ay, ax
	if m == 1 then
		ax,ay = 0 , w/2
	else
		ax,ay = w/2 , 0
	end

	local point = {}
	point[1] , point[2] = translateToScreen(x+ax,y+ay,z)
	point[3] , point[4] = translateToScreen(x+ax,y+ay,h+z)
	point[5] , point[6] = translateToScreen(x-ax,y-ay,h+z)
	point[7] , point[8] = translateToScreen(x-ax,y-ay,z)
	love.graphics.polygon("line",point) -- FIX: fill for flat wall
	--lineThing(point)
end

--[[
function lineThing(point)
	heart.push("all")
	love.graphics.setColor(0,0,0)
	love.graphics.setLineWidth(grid.blockSize*0.01)
	love.graphics.setLineJoin("bevel")
	love.graphics.polygon("line",point)
	heart.pop()
end
--]]

function drawWallDirect( image, x,y,z,m,r,s)
	assert(m == nil or m == 1 or m == -1 , "m ,Mirror value must be nil, 1 or -1")

	x,y,z,s,m = x or 0 , y or 0 , z or 0 , s or 1 , m or 1
	s = s * (grid.blockSizeWidth/(image:getWidth()*2))
	local screenX , screenY = translateToScreen(x,y,z)

	love.graphics.draw( image ,screenX , screenY, r , s*m , s, image:getWidth()/2,image:getHeight() - image:getWidth()*0.25 )
	
end


function drawTileDirect( image, x,y,z,r,s)
	x,y,z,s = x or 0 , y or 0 , z or 0 , s or 1
	s = s * (grid.blockSizeWidth/image:getWidth())
	local screenX , screenY = translateToScreen(x,y,z)

	love.graphics.draw( image ,screenX , screenY, r , s , s, image:getWidth()/2,image:getHeight()/2)
	
end


function translateToScreen(x,y,z)
	z = z or 0
	assert(type(x) == "number", "first argument (x) is not a number")
	assert(type(y) == "number", "second argument (y) is not a number")
	assert(type(z) == "number", "thrid argument (z) is not a number")

	x,y = x + grid.blockTranslateX , y - grid.blockTranslateX
	x,y = x + grid.blockTranslateY , y + grid.blockTranslateY

	local angle = math.atan2(y,x)+math.pi/4
    if angle < 0 then angle = angle +math.pi*2 end
    local length = math.sqrt(x * x + y * y)

    x,y = math.cos(angle)*length , math.sin(angle)*length



	x,y = x*2*grid.blockSize, y*grid.blockSize
	x,y = x+viewport.width/2,y+viewport.height/2- z*grid.blockSize*math.sqrt(2)

	return x , y
end


function translateToIso(x,y) -- add in (iso) Z variable so you can select floor level?
	assert(type(x) == "number", "first argument (x) is not a number")
	assert(type(y) == "number", "second argument (y) is not a number")

	x = x - (grid.blockTranslateX * grid.blockSizeWidth) 
	y = y - (grid.blockTranslateY * grid.blockSizeWidth*0.5)

	x = x - viewport.width/2
	y = y - viewport.height/2

	x = x * 0.5

	local angle = math.atan2(y,x)-math.pi/4
    if angle < 0 then angle = angle +math.pi*2 end
    local length = math.sqrt(x * x + y * y)

    x,y = math.cos(angle)*length , math.sin(angle)*length

	x = x / grid.blockSize
	y = y / grid.blockSize

	return x,y
end

grid.tilesq = love.graphics.newImage("testasset/tilesq.png")
grid.wallsq = love.graphics.newImage("testasset/wallsq.png")

--[[

tile = {}
tile.image = love.graphics.newImage("tile.png")
tile.width = tile.image:getWidth()
tile.height = tile.image:getHeight()



wall = {}
wall.image = love.graphics.newImage("wall.png")
wall.width = wall.image:getWidth()
wall.height = wall.image:getHeight()

--]]

--HACK
repgjwpwe()

