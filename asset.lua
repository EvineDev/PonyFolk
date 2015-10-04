asset = asset or {}


if not love.filesystem.exists("asset") then
	love.filesystem.createDirectory("asset")
end

asset.fontHeight = 0
asset.saveName = {}
asset.save = {}
asset.folderInk = {}
asset.moveable = false
asset.instructions = false
asset.mark = false

-- tests
--love.filesystem.write("metadataimage.lua","print('Apples'); --assert(false)\n--garbage ewoifj")
--love.filesystem.remove("metadataimage.lua")

do -- Load metadataimage
	local chunck , loadErr
	local function loadFile()
		chunck , loadErr = love.filesystem.load("metadataimage.lua")
	end
	local ok , syntaxErr = pcall(loadFile)
	
	if chunck == nil then
		if syntaxErr then print(syntaxErr) end
		if loadErr then print(loadErr) end -- If file does not exist is not an "Error" per say

		goto skip
	end
	ok,runErr = pcall(chunck)
	if ok == false then
		print(runErr)

		goto skip
	end

	local i = 1
	for k,v in pairs(asset.save) do
		asset.saveName[i] = k
		i = i +1
	end
end
::skip::

local scaleMod = 1
local posx = 0
local posy = 0
local currentImage
local currentImageName
local currentImageDate
local currentImageNameFlag = false
local currentImageCollisionX = 0
local currentImageCollisionY = 0


function asset.saveFile(quit)
	if quit ~= "quit" then
		print("saved")
		if currentImageName ~= nil then
			table.insert(asset.saveName,currentImageName)
			asset.save[currentImageName] =
			{
				x = posx,
				y = posy,
				s = scaleMod,
				w = currentImageCollisionX,
				h = currentImageCollisionY,
				object = "object" -- or Wall, Tile or UI?
			}
		end
	end

	local file = love.filesystem.newFile("metadataimage.lua","w") -- Open in write mode to clear file
	file:open("a")
	file:write("asset.save = \r\n{\r\n")


	for k, v in pairs(asset.save) do
		file:write("\t[ '"..k.."' ] = {x = "..tostring(asset.save[k].x)..
			", y = "..tostring(asset.save[k].y)..
			", s = "..tostring(asset.save[k].s)..
			", w = "..tostring(asset.save[k].w)..
			", h = "..tostring(asset.save[k].h)..
			", object = "..tostring(asset.save[k].object)..
			"},\r\n")
	end


	file:write("}\r\n")
	file:close()
end

function asset.quit()
	asset.saveFile("quit")
end


function asset.mousereleased(button)
	if button == "r" then
		asset.moveable = not asset.moveable
		if currentImageName then
			asset.save[currentImageName] = nil -- This removes the entry from the list
		end
	end
end

function removeIndexes(t,countRemaining)
	for i = countRemaining+1 ,#t do
		t[i] = nil
	end
end

function asset.keypressed(key)
	if key == "s" then
		if currentImageName ~= nil then
			
			asset.saveFile()

			--print(currentImageName)
			--print(scaleMod)
			--print(posx)
			--print(posy)
		end
	end
end

function catcheImage(fileName)
	if currentImageName ~= fileName or
		currentImageDate ~= love.filesystem.getLastModified(fileName) then

		currentImageName = fileName 
		currentImage = love.graphics.newImage(fileName)
		currentImageDate = love.filesystem.getLastModified(fileName)
	end
	return currentImage
end

function asset.drawCurrent(fileName)

	
	local image = catcheImage(fileName) -- This is the fileName
	
	if asset.save[fileName] then
		saveInfo = asset.save[fileName]
		posx,posy = saveInfo.x , saveInfo.y
		scaleMod = saveInfo.s
		currentImageCollisionX = saveInfo.w
		currentImageCollisionY = saveInfo.h
	else
		if asset.moveable then
			posx,posy = translateToIso(mouse.x,mouse.y)
		end

		scaleMod = ui.slider(scaleMod,1500,20,400,75,0.05,4)
		heart.push("all")
		love.graphics.setColor(0,0,0)
		love.graphics.setFont(heart.font)
		love.graphics.printf("Item Scale",1500,95,400,"center")
		heart.pop()
	end

	local screenX,screenY = translateToScreen(posx,posy)
	local scale = grid.blockSize/250 * scaleMod
	
	

	heart.push()
	--printv("s: "..scaleMod)
	--printv("y: "..posy)
	--printv("x: "..posx)

	-- Save x,y,s
	love.graphics.translate(screenX,screenY)
	love.graphics.scale(scale)

	love.graphics.setColor(255,255,255)
	love.graphics.draw(image,
		0,
		0,
		0,
		1,
		1,
		image:getWidth()*0.5,
		image:getHeight()*0.5) -- offsetFromMiddle
	heart.pop()
	
	currentImageNameFlag = true
end





function asset.downFolder(filePath,ink)
	local fileName = love.filesystem.getDirectoryItems(filePath)

	local valid = 1
	for itemNum = 1, #fileName do
		local item = filePath.."/"..fileName[itemNum]

		if love.filesystem.isDirectory(item) then
			
			asset.downFolderCommon("dir",item,fileName[itemNum],ink,valid)

			if ink <= #asset.folderInk and asset.folderInk[ink] == fileName[itemNum] then
				asset.downFolder(item,ink+1)
			end

			valid = valid +1
		elseif item:lower():find(".png",#item-3) then

			asset.downFolderCommon("file",item,fileName[itemNum],ink,valid)
			valid = valid +1
		end
	end
end


local function color(value,level)
	love.graphics.setColor(heart.hsv(value,1,1,level))
end

function asset.downFolderCommon(typeFile,item,fileName,ink,valid)

	local hue
	if typeFile == "dir" then
		hue = 30
	elseif typeFile == "file" then
		hue = 240
		if asset.save[item] then
			hue = 120
		end
	end

	local fontHeight = asset.fontHeight
	local fontWidth = fontHeight*7

	color(hue,0.2)

	if math.floor(mouse.y / fontHeight)+1 == valid and
		math.floor(mouse.x / fontWidth)+1 == ink then
		color(hue,0.4)
		if mouse.left then
			color(hue,0.6)
		end
		if mouse.beenReleased.left then
			if asset.folderInk[ink] ~= fileName then
				removeIndexes(asset.folderInk,ink)
				asset.folderInk[ink] = fileName
			else
				removeIndexes(asset.folderInk,ink-1)
			end
		end
	end
	if asset.folderInk[ink] == fileName then
		if typeFile == "file" then
			asset.drawCurrent(item)
		end
		color(hue,0.6)
	end
	love.graphics.rectangle("fill",(ink-1)*fontWidth,(valid-1)*fontHeight,fontWidth,fontHeight)
	love.graphics.setColor(20,20,20)
	love.graphics.rectangle("line",(ink-1)*fontWidth,(valid-1)*fontHeight,fontWidth,fontHeight)
	love.graphics.setColor(0,0,0)
	love.graphics.print(fileName,(ink-1)*fontWidth,(valid-1)*fontHeight)
end


function asset.viewItems()

	asset.fontHeight = love.graphics.getFont():getHeight()
	currentImageNameFlag = false
	asset.downFolder("asset",1)

	if currentImageNameFlag == false then
		currentImageName = nil
	end
	--for k,v in ipairs(asset.folderInk) do -- To see where we are in the folders
		--printv(asset.folderInk[k],k)
	--end

end


function asset.draw()
	love.graphics.setColor(230,230,215)
	love.graphics.rectangle("fill",0,0,1920,1080)
	love.graphics.setColor(0,0,0)
	asset.polyDraw(0,0,5,5)

	asset.viewItems()

	-- Zoom level
	love.graphics.setColor(0,0,0)
	--grid.blockSize = ui.slider(grid.blockSize , 1300,910,600,150,50,500 )
	--grid.blockSizeWidth = grid.blockSize*(math.sqrt(2)*2)
	heart.push("all")
	love.graphics.setFont(heart.font)
	local fontHeight = love.graphics.getFont():getHeight()
	love.graphics.setColor(0,0,0)
	love.graphics.printf("Zoom level",1300,900-fontHeight,600,"center")

	-- Save Folder
	love.graphics.setColor(20,20,20,50)
	if mouse.x > 20 and mouse.x < 520 and mouse.y > 1060-fontHeight and mouse.y < 1060 then
		love.graphics.setColor(20,200,20,50)
		if mouse.left then
			love.graphics.setColor(20,200,20,100)
		end
		if mouse.beenReleased.left then
			asset.saveFile()
			love.system.openURL("file://"..love.filesystem.getSaveDirectory())
		end
	end
	love.graphics.rectangle("fill",20,1060-fontHeight,500,fontHeight)

	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line",20,1060-fontHeight,500,fontHeight)
	love.graphics.printf("Open Save Folder",20,1060-fontHeight,500,"center")
	
	-- Save button
	love.graphics.setColor(20,20,20,50)
	if mouse.x > 20 and mouse.x < 220 and mouse.y > 1060-20*2-fontHeight*3 and mouse.y < 1060-20*2-fontHeight*2 then
		love.graphics.setColor(20,200,20,50)
		if mouse.left then
			love.graphics.setColor(20,200,20,100)
		end
		if mouse.beenReleased.left then
			asset.saveFile()
		end
	end
	love.graphics.rectangle("fill",20,1060-20*2-fontHeight*3,200,fontHeight)

	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line",20,1060-20*2-fontHeight*3,200,fontHeight)
	love.graphics.printf("Save",20,1060-20*2-fontHeight*3,200,"center")


	-- Mark area
	if mouse.beenReleased.left then
		if asset.mark then
			asset.mark = false
		end
	end

	love.graphics.setColor(20,20,20,50)
	if mouse.x > 20 and mouse.x < 470 and mouse.y > 1060-20-fontHeight*2 and mouse.y < 1060-20-fontHeight then
		love.graphics.setColor(20,200,20,50)
		if mouse.left then
			love.graphics.setColor(20,200,20,100)
		end
		
		if mouse.beenReleased.left then
			asset.mark = true
			asset.save[currentImageName] = nil
		end
	end
	if asset.mark then
		love.graphics.setColor(20,200,20,100)
	end
	love.graphics.rectangle("fill",20,1060-20-fontHeight*2,450,fontHeight)

	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line",20,1060-20-fontHeight*2,450,fontHeight)
	love.graphics.printf("Mark Collision",20,1060-20-fontHeight*2,450,"center")

	-- Instructions
	if mouse.beenReleased.left then
		asset.instructions = false
	end
	love.graphics.setColor(20,20,20,50)
	if mouse.x > 540 and mouse.x < (540+450) and mouse.y > 1060-fontHeight and mouse.y < 1060 then
		love.graphics.setColor(20,200,20,50)
		if mouse.left then
			love.graphics.setColor(20,200,20,100)
		end
		
		if mouse.beenReleased.left then
			asset.instructions = true
		end
	end

	if asset.instructions then
		love.graphics.setColor(235,235,235,180)
		love.graphics.rectangle("fill",300,260,800,570)
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("line",300,260,800,570)
		love.graphics.line(690,580,960,540,940,550,940,530,960,540)

		local info = 
		[[ If it the first time using this software then
		-- Press "Open Save Folder"
		-- Put your asset into the "asset" folder

		 Place assets
		-- Select file
		-- Right click to move it
		-- Put it up in the corner
		-- Press "Mark Collision"
		-- Mark the tiles the object should occupy
		-- Press "Save" or "s" on the keyboard

		"metadataimage.lua" Contains the save information]]

		love.graphics.setFont(heart.fontMedium)

		love.graphics.printf(info,305,260,800,"left")

		love.graphics.setFont(heart.font)
		love.graphics.setColor(20,200,20,100)
	end
	love.graphics.rectangle("fill",540,1060-fontHeight,450,fontHeight)

	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line",540,1060-fontHeight,450,fontHeight)
	love.graphics.printf("Instructions",540,1060-fontHeight,450,"center")


	heart.pop()
	if asset.mark then
		currentImageCollisionX , currentImageCollisionY = math.round(grid.mouse.x+1) , math.round(grid.mouse.y+1)
	end

end

function asset.polyDraw(x,y,w,h)
	for xi = 0, w-1 do
		for yi = 0, h-1 do
			love.graphics.setColor(255,0,0,40)
			if not asset.mark and asset.save[currentImageName] then
				if asset.save[currentImageName].w > xi and asset.save[currentImageName].h > yi then
					drawPolygonTile(xi,yi,"fill")
				end
			else
				if currentImageCollisionX > xi and currentImageCollisionY > yi then
					drawPolygonTile(xi,yi,"fill")
				end
			end
			
			love.graphics.setColor(0,0,0)
			drawPolygonTile(xi,yi)
		end
	end
	for xi = 0, w-1 do
		drawFlatWall(xi,-0.5,1,-1,3.5,0)
	end
	for yi = 0, h-1 do
		drawFlatWall(-0.5,yi,1,1,3.5,0)
	end
end