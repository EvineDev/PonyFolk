function heart.graphics.newPSD(fileName,flag)
	assert(flag == nil or flag == "plain" or flag == "folders", "flag is set to an invaild value. \"plain\" or \"folders\" is vaild values")

	file = love.filesystem.read(fileName)
	local function hexToNumber(first,second,third,forth) -- first is the direct hex -- Lack 8 length support
		local result = first
		
		if forth ~= nil then
			result = result + second * ( 0xff +1)
			result = result + third * ( 0xffff +1)
			result = result + forth * ( 0xffffff +1)
		elseif third ~= nil then
			result = result + second * ( 0xff +1)
			result = result + third * ( 0xffff +1)
		elseif second ~= nil then
			result = result + second * ( 0xff +1)
		end

		return result
	end

	local function directFileReader(file,endianness)
		self = {}

		self.file = file
		self.count = 1

		self.startPoint = {}

		function self:inkString(name , stringLength , stepLength)
		-- Step length needs to grab 2 bytes in some cases.
			if stepLength == nil then stepLength = 1 end
			assert(self[name] == nil , "Name already taken")


			local resultString = ""
			for i = 1 , stringLength do

				local first = self.file:byte(self.count)
				local second
				local third
				local forth

				if stepLength == 2 then
					second = self.file:byte(self.count+1)
				elseif stepLength == 4 then
					second = self.file:byte(self.count+1)
					third = self.file:byte(self.count+2)
					forth = self.file:byte(self.count+3)
				end


				local resultStringAdd
				if endianness == "big" then
					resultStringAdd = hexToNumber(first,second,third,forth)
					self.count = self.count + stepLength
				elseif endianness == "little" then -- Unsure if little Endian file format strings in different order
					assert(false, "Check how little Endian files formats strings")
					resultStringAdd = hexToNumber(forth,third,second,first)
					self.count = self.count + num
				end

				--print(resultStringAdd)
				if resultStringAdd > 31 and resultStringAdd < 127 then 
					--resultString = resultString.." \""..tostring(resultStringAdd).." "
					resultString = resultString..string.char(resultStringAdd)
				end
			end

			if name == nil then
				return resultString
			end

			self[name] = resultString
			--print(name..": ",self[name])
			
			return resultString
		end

		function self:ink(name , stepLength, div) -- Lack 8 length support
			
			assert(stepLength == 1 or stepLength == 2 or stepLength == 4 ,"ink must be a power of 2. No higher than 4")

			local first = self.file:byte(self.count)
			local second
			local third
			local forth

			if stepLength == 2 then
				second = self.file:byte(self.count+1)
				if endianness == "big" then
					first , second = second , first
				end
			elseif stepLength == 4 then
				second = self.file:byte(self.count+1)
				third = self.file:byte(self.count+2)
				forth = self.file:byte(self.count+3)
				if endianness == "big" then
					first , second , third , forth = forth, third , second , first
				end
			end

			if div ~= "don't count" then self.count = self.count + stepLength end
			resultString = hexToNumber(first,second,third,forth)



			if div == "int" and resultString >= 128 then
				assert(stepLength == 1, "function :ink does not handle \"int\" longer than 1 byte ")
				resultString = resultString - 256
			end


			if name == nil then
				return resultString
			end

			if name == tonumber(name) then
				name = tonumber(name)
			end
			
			assert(self[name] == nil , "Name already taken")
			self[name] = resultString
			--print(name..": ",self[name])
			--assert endianness??
		end

		return self
	end
	--print()

	local artal = directFileReader(file,"big") 

	artal.warnings = {}

	-- Header
	assert(artal:inkString(nil,4) == "8BPS" , "File must be a .psd")
	assert(artal:ink(nil,2) == 1 , "File must be a .psd")
	artal.count = artal.count + 6 --Reserved space
	artal:ink("channels",2)
	artal:ink("height",4)
	artal:ink("width",4)
	artal:ink("depth",2) -- assert 8
	artal:ink("colorMode",2) -- assert 3

	--Color Mode
	artal:ink("colorModeLength",4)
	assert(artal.colorModeLength == 0 ,"colorModeLength is not 0 as expected")


	--Image Resources Section
	artal:ink("imageResourcesLength",4)
	artal.startPoint.layerMask = artal.count + artal.imageResourcesLength
	assert(artal:inkString(nil,4) == "8BIM" , "imageResourcesSign is not correct")
	artal:ink("imageResourcesID",2)
	-- Stub



	--Layer and Mask
	artal.count = artal.startPoint.layerMask
	--Layer and mask information section
	artal:ink("layerLength",4)
	artal.startPoint.imageData = artal.count + artal.layerLength
	--Layer info
	artal:ink("layerTotalLength",4)
	artal:ink("layerTotalCount",2)-- Don't really know why this can be a negative number.
	if artal.layerTotalCount > 2^15 then -- int-ify
		artal.layerTotalCount = artal.layerTotalCount -2^16
	end

	artal.layer = {}
	--print(artal.layerTotalCount)

	for LC = 1 , math.abs(artal.layerTotalCount) do
		artal.layer[LC] = directFileReader(file,"big")
		artal.layer[LC].count = artal.count
		--print("artal.layer["..LC.."]-------------------------------")

		--Layer records
		artal.layer[LC]:ink("top",4)
		artal.layer[LC]:ink("left",4)
		artal.layer[LC]:ink("bottom",4)
		artal.layer[LC]:ink("right",4)

		if artal.layer[LC].top > 2^31 then artal.layer[LC].top = artal.layer[LC].top - 2^32 end
		if artal.layer[LC].left > 2^31 then artal.layer[LC].left = artal.layer[LC].left - 2^32 end
		if artal.layer[LC].bottom > 2^31 then artal.layer[LC].bottom = artal.layer[LC].bottom - 2^32 end
		if artal.layer[LC].right > 2^31 then artal.layer[LC].right = artal.layer[LC].right - 2^32 end

		artal.layer[LC]:ink("channelCount",2)
		assert(artal.layer[LC].channelCount == 4 or artal.layer[LC].channelCount == 3 , "psd loader only supports 3 or 4 channels" )

		artal.layer[LC].channel = {}


		for CC = 1 , artal.layer[LC].channelCount do
			artal.layer[LC].channel[CC] = directFileReader(file,"big" )
			artal.layer[LC].channel[CC].count = artal.layer[LC].count

			artal.layer[LC].channel[CC]:ink("id",2)
			artal.layer[LC].channel[CC]:ink("length",4)

			artal.layer[LC].count = artal.layer[LC].channel[CC].count
		end


		assert(artal.layer[LC]:inkString(nil,4) == "8BIM" , "LayerSign is not correct")
		artal.layer[LC]:inkString("blend",4)
		artal.layer[LC]:ink("opacity",1)
		artal.layer[LC]:ink("clipping",1)
		artal.layer[LC]:ink("flags",1)	--Prehaps make a inkBits that expose the 8 bits in a hex
		artal.layer[LC].count = artal.layer[LC].count + 1 -- Pad
		artal.layer[LC]:ink("additionalLength",4)

		--Layer mask / adjustment layer data
		artal.layer[LC]:ink("maskAdjustment",4)
		assert(artal.layer[LC].maskAdjustment == 0, "maskAdjustment is not 0 as expected")
		--Layer blending ranges data
		artal.layer[LC]:ink("blendingRangeLength",4) -- Jumping over this
		artal.layer[LC].count = artal.layer[LC].count + artal.layer[LC].blendingRangeLength
		--Layer Name
		artal.layer[LC]:ink("nameLength",1)
		artal.layer[LC]:inkString("name",artal.layer[LC].nameLength)

		--Pacal String padding
		if ((artal.layer[LC].nameLength+1)/4) ~= math.floor((artal.layer[LC].nameLength+1)/4) then
			artal.layer[LC].count = artal.layer[LC].count + math.ceil((artal.layer[LC].nameLength+1)/4)*4 - ((artal.layer[LC].nameLength+1)/4)*4
		end


		-- Additional Layer Information
		while artal.layer[LC]:inkString(nil , 4) == "8BIM" do
			local key = artal.layer[LC]:inkString(nil,4)
			local length = artal.layer[LC]:ink(nil,4)
			--print("key: "..key.." , Length: "..length)


			if key == "luni" then
				artal.layer[LC]:inkString("luniName",length)
			elseif key == "lnsr" then
				artal.layer[LC]:inkString("layerID",4)
			elseif key == "lyid" then
				artal.layer[LC]:ink("lyid",4) -- Seems errorious
			elseif key == "clbl" then
				artal.layer[LC]:ink("blendClippedElements",1) -- true == 1 / false == 0
				artal.layer[LC].count = artal.layer[LC].count + 3
			elseif key == "infx" then
				artal.layer[LC]:ink("blendInteriorElements",1) -- true == 1 / false == 0
				artal.layer[LC].count = artal.layer[LC].count + 3
			elseif key == "knko" then
				artal.layer[LC]:ink("knockoutSetting",1) -- true == 1 / false == 0
				artal.layer[LC].count = artal.layer[LC].count + 3
			elseif key == "lspf" then
				artal.layer[LC]:ink("protectionFlags",4)
			elseif key == "lclr" then
				artal.layer[LC]:ink("sheetColorSetting",4) 
				artal.layer[LC].count = artal.layer[LC].count + 4 -- Pad
			elseif key == "shmd" then
				artal.layer[LC].count = artal.layer[LC].count + length -- Undocumented
			elseif key == "fxrp" then
				artal.layer[LC]:ink("referencePoint1",4)
				artal.layer[LC]:ink("referencePoint1big",4)
				artal.layer[LC]:ink("referencePoint2",4)
				artal.layer[LC]:ink("referencePoint2big",4)
			elseif key == "lsct" then
				artal.layer[LC]:ink("folder",4)
				if length >= 12 then
					assert(artal.layer[LC]:inkString(nil,4) == "8BIM" , "lsct sign is not correct")
					artal.layer[LC]:inkString("sectionDividerBlend",4)
				end
				if length >= 16 then
					artal.layer[LC]:ink("sectionDividerType",4)
				end
			elseif key == "lyvr" then
				artal.layer[LC]:ink("layerVersion",4)
			elseif key == "lfx2" then
				assert(artal.layer[LC]:ink(nil,4) == 0 , "objectivVersion is not 0 as expected")
				artal.layer[LC]:ink("descriptorVersion",4)
				--Stub
				artal.layer[LC].count = artal.layer[LC].count - 8 + length
			elseif key == "lrFX" then
				--Stub
				artal.layer[LC].count = artal.layer[LC].count + length

			else
				artal.warnings[key] = "Key: \""..key.."\" is not yet handled."
				artal.layer[LC].count = artal.layer[LC].count + length
				--assert(false,"Key: \""..key.."\" is not yet handled.")
			end

		end

		-- Back up the last false while loop 
		artal.layer[LC].count = artal.layer[LC].count - 4 
		

		artal.count = artal.layer[LC].count
	end




	artal:ink("channelCompression",2)
	assert(artal.channelCompression == 1 , "image compression type is unsupported")


	for LC = 1 , math.abs(artal.layerTotalCount) do
		local totalHeight = artal.layer[LC].bottom - artal.layer[LC].top
		local totalWidth = artal.layer[LC].right - artal.layer[LC].left


		local layerEnd = artal.count

		local offset = {}
		local count = {}
		local rawPixel = {}
		local bytesPerLine = {}
		for CC = 1 , artal.layer[LC].channelCount do
			layerEnd = layerEnd + artal.layer[LC].channel[CC].length
			if CC ~= 1 then
				offset[CC] = offset[CC-1] + artal.layer[LC].channel[CC-1].length
			else
				offset[CC] = 0
			end
			count[CC] = artal.count + offset[CC] + totalHeight * 2
			rawPixel[CC] = {}
		end
		
		if totalHeight ~= 0 or totalWidth ~= 0 then 

		
			artal.layer[LC].imageData = love.image.newImageData(totalWidth,totalHeight)
			--artal.layer[LC].imageDataString = "" -- Might be better to construct a string directly in LOVE 0.10.0

			for LINE = 1 , totalHeight do

				local tempCounterValue = artal.count
				local bytesPerLine = {}
				for CC = 1 , artal.layer[LC].channelCount do
					artal.count = tempCounterValue + offset[CC]
					bytesPerLine[CC] = artal:ink(nil,2,"don't count")
				end
				
				for CC = 1,artal.layer[LC].channelCount do
					local countEnd = count[CC] + bytesPerLine[CC]
					local ROW = 1
					artal.count = count[CC]
					

					
					while count[CC] ~= countEnd do
						local headByte = artal:ink(nil,1,"int")
						count[CC] = count[CC]+1
						--print("headByte: "..headByte)
						
							
						if headByte >= 0 then
							for i = 1, 1 + headByte do
								local pixelValue = artal:ink(nil,1)
								count[CC] = count[CC]+1
								--print(pixelValue)
								rawPixel[CC][ROW] = pixelValue
								ROW = ROW + 1
							end

						elseif headByte > -128 then
							local pixelValue = artal:ink(nil,1)
							count[CC] = count[CC]+1
							for i = 1 , 1 - headByte do
								--print(pixelValue)
								rawPixel[CC][ROW] = pixelValue
								ROW = ROW + 1
							end

						else
							assert(false , "Currently does not handle header byte -128, It seems stupid")
						end

						--print("count[CC]: "..count[CC],countEnd)
					end
				end

				if artal.layer[LC].channelCount == 4 then
					for ROW = 1 , totalWidth do
						artal.layer[LC].imageData:setPixel(
							ROW-1,
							LINE-1,
							rawPixel[2][ROW],
							rawPixel[3][ROW],
							rawPixel[4][ROW],
							rawPixel[1][ROW])
					end
				else
					for ROW = 1 , totalWidth do
						artal.layer[LC].imageData:setPixel(
							ROW-1,
							LINE-1,
							rawPixel[1][ROW],
							rawPixel[2][ROW],
							rawPixel[3][ROW],
							255)
					end
				end
				artal.count = tempCounterValue + 2	
			end

			artal.layer[LC].image = love.graphics.newImage(artal.layer[LC].imageData)
			artal.layer[LC].imageData = nil
		end
		artal.count = layerEnd
	end

	local imageTable = {
		width = artal.width,
		height = artal.height,
		warnings = artal.warnings
	}

	local function imageInsert(i)

		local layer = {}
		layer.type = "image"

		-- Layer name
		layer.name = artal.layer[i].name
		-- imageData
		layer.image = artal.layer[i].image
		-- Layer offset if you want to draw the layer as a single image with rotation put these offset into the "ox" and "oy" offset in love.graphics.draw
		-- love.graphics.draw( drawable, x, y, r, sx, sy, ox, oy, kx, ky )
		if artal.layer[i].bottom - artal.layer[i].top ~= 0 and
			artal.layer[i].right - artal.layer[i].left ~= 0 then
			layer.offsetX = -artal.layer[i].left
			layer.offsetY = -artal.layer[i].top
		end
		-- not usefull currently -- grep put in info on how to use
		layer.blend = artal.layer[i].blend
		layer.opacity = artal.layer[i].opacity
		if artal.layer[i].clipping == 0 then
			layer.clipping = false
		else
			layer.clipping = true
		end
		return layer
	end

	local function folderInsert(i)

		local layer = {}
		layer.type = "folder"
		-- not usefull currently -- grep put in info on how to use
		layer.blendMode = artal.layer[i].blend
		layer.opacity = artal.layer[i].opacity
		if artal.layer[i].clipping == 0 then
			layer.clipping = false
		else
			layer.clipping = true
		end
		return layer
	end
	
	local POS = 1
	local currentTable = imageTable
	local prevPos = {}
	local prevTable = {}
	for i = 1 , math.abs(artal.layerTotalCount) do

		if flag == nil or flag == "plain" then
			currentTable[POS] = imageInsert(i)
			POS = POS + 1
		elseif  flag == "folders" then
			if artal.layer[i].folder == 3 then
				-- This puts the layerData into a new table as a "folder" of sorts
				currentTable[POS] = folderInsert(i)
				table.insert(prevTable,currentTable)
				currentTable = currentTable[POS]
				table.insert(prevPos,POS)
				POS = 1
			elseif artal.layer[i].folder == 1 or artal.layer[i].folder == 2 then
				-- This returns to the previous table
				currentTable.name = artal.layer[i].name
				currentTable.layers = POS - 1
				currentTable = prevTable[#prevTable]
				POS = prevPos[#prevPos] + 1
				table.remove(prevTable)
				table.remove(prevPos)
			else
				currentTable[POS] = imageInsert(i)
				POS = POS + 1
			end
		end
	end
	imageTable.layers = POS - 1

	return imageTable
end

--[[
Synopsis
imageTable = heart.graphics.newPSD(filename)

Arguments
--string filename
The filename of the image file.

--string flag ("plain")
Decide whether the layerData should be organized in tables using "folders".
Or as a single table with all layerData "plain"

Returns
--table data
A table containing the relevant ".psd" info as layers

	--number width
	Width of the composed image.
	
	--number height
	Height of the composed image.

	--number layers
	Number of layers in the folder. (If flag is set to plain this is the total count of layers)

	--table layerData
	A table with the following layerdata

		--string name
		Name of the layer.

		--string type
		"image" or "folder"

		--string blend
		String representing the blend mode used by the layer. -- grep types, url ???

		--number opacity
		Global opacity of the layer.

		--boolean clipping
		True if this is a clipping layer. normally false.

		If the layerData type is "image" and the layer isn't blank then the following is present.

			--imagedata data
			Raw imageData for the layer.

			--number offsetX
			Offset for the layer data from the left position.

			--number offsetY
			Offset for the layer data from the top position.

		If the layerData type is "folder" then the following is present.
		(Only present when the "flag" argument is set to "folders")

			--table layerData
			It contains its own table that hold layerdata.

			--number layers
			Number of layers in the folder.


--http://www.adobe.com/devnet-apps/photoshop/fileformatashtml/
--]]


function heart.graphics.drawPSD(psdTable,index,x,y,r,sx,sy,ox,oy,kx,ky)
	assert( not (index == nil) , "index of image is nil" )
	assert(type(index) == "number" , "index is not a number")
	assert(index >= 1 and index <= #psdTable , "index must be in range of layers")
	assert(psdTable[index].type == "image" , "index not an image")
	if ox == nil then
		ox = 0
	end
	if oy == nil then
		oy = 0
	end
	if psdTable[index].offsetX ~= nil then
		love.graphics.draw(psdTable[index].image,
			x,y,r,
			sx,sy,
			ox+psdTable[index].offsetX,
			oy+psdTable[index].offsetY,
			kx,ky)
	end
end


-- test1.psd
-- test2.psd
-- igavania.psd
-- igavaniasai.psd
-- s5e9.psd
-- flutterbelle.psd

--[[
local aoifjei = love.timer.getTime()
cred = heart.graphics.newPSD("flutterbelle.psd","plain")
local aoifjeiE = love.timer.getTime()-aoifjei
print(aoifjeiE)

local numPixels = 0
for i = 1 , cred.layers do
	if cred[i].offsetX ~= nil then
		numPixels = numPixels + cred[i].image:getWidth() * cred[i].image:getHeight()
	end
end
print(numPixels/1000/1000)
print((numPixels/1000/1000)/ aoifjeiE )
--]]


--example
function PSDprintdrawTEST()
	
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill",0,0,1920,1080)
	for i = 1 , cred.layers do
		if cred[i].blend == "over" then
			heart.graphics.drawPSD(cred,i,0,0,0,0.5)
		else
			heart.graphics.drawPSD(cred,i,0,0,0,0.5)
		end
	end
end

