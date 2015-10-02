if not heart.debug.init then
	heart.debug.printOutput = {}
	heart.debug.valueOutput = {}
	for i = 1 , 61 do
		heart.debug.printOutput[i] = ""
	end
	heart.debug.scrollPos = 0

	heart.timer.avgDT = {}
	for i = 1, 60*15 do
		heart.timer.avgDT[i] = 0
	end
	heart.debug.init = true
end

heart.debug.printValue = heart.debug.printValue or {}

function heart.debug.load()
	if love._os == "Windows" then
		heart.debug.font = love.graphics.newFont(12)
		heart.debug.fontSmall = love.graphics.newFont(10)
	elseif love._os == "OS X" then
		heart.debug.font = love.graphics.newFont(20)
		heart.debug.fontSmall = love.graphics.newFont(14)
	end
	heart.debug.drawCalls = 0
end


function heart.debug.mousepressed(x , y , button)
	if button == "wd" then
		heart.debug.scrollPos = heart.debug.scrollPos + 1
	end
	if button == "wu" then
		heart.debug.scrollPos = heart.debug.scrollPos - 1
	end
end


function heart.debug.keypressed(key,isHeld)
	if key == "escape" then
		love.event.quit()
	end
	if key == "d" then -- Disable for release ----------------------------------
		keyboard.TimeSincePressedTheD = love.timer.getTime()
	end
	if _Debug then
		if key == "i" then
			love.system.openURL("file://".._RealDir)
		end
		if key == "o" then
			love.system.openURL("file://"..love.filesystem.getSaveDirectory())
		end
		if key == "p" then
			love.system.openURL("file://C:/Users/Evine/AppData/Roaming/Sublime Text 2/Packages/Lua")
		end
		if key == "g" then
			local garbage = collectgarbage("count")
			for i = 1,100 do
				collectgarbage()
			end
			print("Garbage MB: "..(garbage-collectgarbage("count"))/1024 )
		end
		if key == "m" then
			_toSleep = not _toSleep
		end
	end
	
end

function heart.debug.keyreleased(key)
	if key == "d" then -- Disable for release ----------------------------------
		if love.timer.getTime() - keyboard.TimeSincePressedTheD < 0.4 or not _Debug then
			_Debug = not _Debug
		else
			_Debug = true
			window.start()
		end
	end
end

function heart.debug.update()
	

	if _Debug then
		love.graphics.push("all")
		heart.debug.drawCalls = love.graphics.getStats().drawcalls

		love.graphics.setFont(heart.debug.font)
		love.graphics.setColor(255,200,200)
		
		local printLength
		local fontSpacing
		local fontSpacingSmall
		if love._os == "Windows" then
			printLength = 60
			fontSpacing = 14
			fontSpacingSmall = 10
		elseif love._os == "OS X" then
			printLength = 42
			fontSpacing = 22
			fontSpacingSmall = 14
		end

		if love.keyboard.isDown("pageup") then
			heart.debug.scrollPos = -#heart.debug.printOutput+printLength*2
		end
		if heart.debug.scrollPos > 0 or love.keyboard.isDown("pagedown") then
			heart.debug.scrollPos = 0
		end
		if heart.debug.scrollPos < -#heart.debug.printOutput+printLength+1 then
			heart.debug.scrollPos = -#heart.debug.printOutput+printLength+1
		end

		if true then -- DT output
			heart.timer.avgDT[1] = dt
			for i = 60*15, 2 , -1 do
				heart.timer.avgDT[i] = heart.timer.avgDT[i-1]
			end
			ui.graph(heart.timer.avgDT , 5 , 5 , love.graphics.getWidth()-10 , 120 , 0 , 0.04 , 0.0167 , 0.0333 )
		end

		if true then -- print output
			for i = 1,printLength-10 do
				love.graphics.printf( heart.debug.printOutput
					[#heart.debug.printOutput-(i-1)+heart.debug.scrollPos] ,
				0,
				fontSpacing*printLength - fontSpacing*i,
				love.graphics.getWidth() - 19,
				"right")
			end
		end
		if true then -- printValue
			for i = 1,#heart.debug.printValue do
				love.graphics.printf( heart.debug.printValue[i] ,
				12,
				fontSpacing*printLength - fontSpacing*i,
				love.graphics.getWidth() ,
				"left")
			end

			--local i = 1
			--for k , v in pairs(heart.debug.valueOutput) do
--
			--	love.graphics.printf(heart.debug.valueOutput[k],
			--		5,
			--		fontSpacing*printLength - fontSpacing*i,
			--		love.graphics.getWidth(),
			--		"left")
			--	i = i + 1
			--end
		end
		heart.debug.printValue = {}

		love.graphics.setFont(heart.debug.fontSmall)
		if false then -- Global variables
			local i = 0
			for k,v in pairs(_G) do
				if not _TableDefault[k] then
					if type(v) == "table" or type(v) == "function" then
						love.graphics.setColor(180,255,180)
					elseif type(v) == "userdata" then
						love.graphics.setColor(255,140,140)
					else
						love.graphics.setColor(255,255,160)
					end

					local x = 0
					local ishift = 0
					local printLength
					if love._os == "Windows" then
						printLength = 60
					else
						printLength = 40
					end
					if i > printLength then
						x,ishift = fontSpacingSmall*30,-printLength-1
					end

					love.graphics.print(type(v),
						5+x,
						fontSpacingSmall* (i+ishift) +130)
					love.graphics.print(tostring(k),
						85+x,
						fontSpacingSmall* (i+ishift) +130)
					i = i + 1
				end
			end
			love.graphics.setColor(255,200,200)
		end

		love.graphics.setFont(heart.font)
		love.graphics.print("Task Curently:\nSorting of sprites",150,120)		

		heart.debug.drawCalls = love.graphics.getStats().drawcalls - heart.debug.drawCalls
		love.graphics.pop()
	end
	
end


-- Note: Long wraping strings messes this up
if true then 
	function print(...)
		local vararg = {...}
		local varargLength = select("#" , ...)
		local stringPrint
		if varargLength == 0 then
			table.insert(heart.debug.printOutput,"")
		else
			--Vararg has contents
			stringPrint = tostring(vararg[1])
			for i = 2 , varargLength do
				stringPrint = stringPrint.." "..tostring(vararg[i])
			end

			local j = 0
			local i = 0
			while true do
	      		j = string.find(stringPrint, "\n", j+1)
		      	table.insert(heart.debug.printOutput, string.sub(stringPrint , i+1 , j )      )
		      	if j == nil then break end
	      		i = j
	    	end
		end
	end
end

function printv(...)
	local vararg = {...}
	local varargLength = select("#" , ...)
	local stringPrint
	if varargLength == 0 then
		table.insert(heart.debug.printValue,"")
	else
		--Vararg has contents
		stringPrint = tostring(vararg[1])
		for i = 2 , varargLength do
			stringPrint = stringPrint.." "..tostring(vararg[i])
		end

		local j = 0
		local i = 0
		while true do
      		j = string.find(stringPrint, "\n", j+1)
	      	table.insert(heart.debug.printValue, string.sub(stringPrint , i+1 , j )      )
	      	if j == nil then break end
      		i = j
    	end
	end
end

function printv__OLD(...)
	assert(select("#" , ...) == 2,"printv only take 2 arguments\nThere is "..select("#" , ...).." Arguments")
	local key , value = ...
	if type(key) == "string" then
		heart.debug.valueOutput[key] = tostring(key)..": "..tostring(value)
	else
		print("err")
	end
end

function printvR__OLD(key) -- Remove a printv variable.
	heart.debug.valueOutput[key] = nil
end

function printo(...) -- print once (only on load)
	if _Loaded then print(...) end
end

-- Not functional
function heart.debug.hook(fir , sec)

	local stringThing = string.find(debug.traceback(), "main.lua" ) 
	local stringLine = string.sub( debug.traceback() , 0)--stringThing+9 ,200   ) -- THIS LINE SHOLD BE PRINTED
	--stringLine = tonumber(stringLine)
	--[[
	if type(tonumber(stringLine)) == "number" then
		local charCount = 0
		for lineCount = 1 , stringLine-1 do 
			charCount = select(2 , string.find(mainluaFILEASSTRING , "\n" , charCount))+1
		end
		local file = string.sub( mainluaFILEASSTRING ,charCount  )
		local lineEnd = string.find(file,"\n")
		local file = string.sub(file , 0 , lineEnd )
		print(  file )
	else
		if asfsafasf == asfsafasfRES then
			print("ERROR not number: ",stringLine)
		end

	end
	print(stringLine)]]

	-- Still needs to present and render.

	-- Stop code
	while false do
		--Linestep
		if love.keyboard.isDown("0") then
			break	
		end
		--Resume
		if love.keyboard.isDown("9") then
			debug.sethook()
			break
		end
		--Exit program
		if love.keyboard.isDown("escape") then
			debug.sethook()
			-- love.event.quit is implicit in
			-- love.keyboard.isDown("escape")
			break
		end
		love.event.pump()
        love.timer.sleep(0.01)
        print(debug.traceback(), "main.lua" )
    end
    

	--asfsafasf = asfsafasf + 1
	
	
	--love.keypressed = love.keypressedOLD
end

--Printable file , Not fuctional.
function heart.debug.fileRead()
	mainluaFILEASSTRING = love.filesystem.read("main.lua")
	heart.debug["main.lua"] = {}
	for line in love.filesystem.lines("main.lua") do
		table.insert(heart.debug["main.lua"] , line)
		
	end
	for i = 1, #heart.debug["main.lua"] do
		--print(i..": "..heart.debug["main.lua"][i])
	end
end

-- run the normal loop in heart.debug.hook

--debug.sethook(heart.debug.hook,"l") -- "l" for line , "c" for function , "r" for returns/break??



