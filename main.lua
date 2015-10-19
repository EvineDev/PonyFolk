--require "programwalk"
--programwalk.start()

do -- Default
	heart = heart or {}
	--external libs
	require "imagedataffilib"
	require "vector"
	if heart.init == nil then

		_TableDefault = {}

		heart.timer = {}
		heart.debug = {}
		heart.hotLoadNameTable = {}
		heart.graphics = {}
		heart.hotLoadNameTable["main.lua"] = love.filesystem.getLastModified("main.lua")

		_TimeStart = love.timer.getTime()
		_Time = 0
		_TimeF = 0
		_RealDir = love.filesystem.getRealDirectory("main.lua").."/"
		_toSleep = false


		love.filesystem.load("debug.lua") ()
		love.filesystem.load("shader.lua") ()

		-- Above and debug.lua is considered Default _G value.
		-- Move "love.filesystem.load("debug.lua") ()" below to consider debug.lua nondefault.
		for k , v in pairs(_G) do
			_TableDefault[k] = true
		end

		love.filesystem.load("window.lua") ()
		window.start()

		heart.init = true
	end


	local _TableApproved =
	{
		--Evine approved
		"_Loaded",
		"_ERRMSG",
		"ui",
		"tile",
		"dt",
		"viewport",
		"memcheck",
		"keyboard",
		"asset",
		"translateToScreen",
		"translateToIso",
		"grid",
		"window",
		"filter",
		"mouse",
		"blendMode",
		"PSDprintdrawTEST",
		"blendModeDrawingsTEST",


		--Temporary
		"path",
		"drawTileWraped",
		"drawWallWraped",
		"drawTileDirect",
		"drawWallDirect",
		"drawFlatTile",
		"drawFlatWall",
		"drawPolygonTile",
		"renderTranslateToScreen",
		"drawAndInk",
		"removeIndexes",
		"isocircleRender",
		"isocircle",
		"insert2d",
	}

	for i = 1, #_TableApproved do
		_TableDefault[_TableApproved[i]] = true
	end


	function heart.renderInfo()
		local stats = love.graphics.getStats( )
		--printv("Texturememory MB",math.floor(stats.texturememory/1024/1024))
		printv("Canvas Swaps",stats.canvasswitches)
		printv("Images Loaded", stats.images)
		printv("Draw Calls",stats.drawcalls-heart.debug.drawCalls)
		--printv("Debug Draw Calls",heart.debug.drawCalls)

		--printv("PrintOutput" , #heart.debug.printOutput)
		printv("Time",_TimeF)
		printv("Lua memory MB",math.floor(collectgarbage("count")/1024*1000)/1000)	
	end
end


-- Requireing a new file causes loads a frame late. Thus unessasery error on load
function heart.require()
	shader.hotLoad()

	_Loaded = false
	-- Should assert on nonexist file???

	heart.hotLoad("debug.lua")
	-- Require files
	heart.hotLoad("main.lua")
	heart.hotLoad("memcheck.lua")
	heart.hotLoad("shader.lua")
	heart.hotLoad("utility.lua")
	heart.hotLoad("loadimage.lua")

	heart.hotLoad("blendmodes.lua")
	heart.hotLoad("filter.lua")

	heart.hotLoad("window.lua")
	heart.hotLoad("viewport.lua")
	heart.hotLoad("keyboard.lua")

	heart.hotLoad("ui.lua")
	heart.hotLoad("mouse.lua")

	heart.hotLoad("tile.lua")
	heart.hotLoad("grid.lua")
	heart.hotLoad("asset.lua")
	heart.hotLoad("path.lua")
	heart.hotLoad("entity.lua")
end


function heart.load(argument)
	--love.mouse.setVisible(false)
	love.graphics.setBackgroundColor(22,17,15)
	love.keyboard.setKeyRepeat(true)

	heart.font = love.graphics.setNewFont("font/nyala.ttf",72)
	heart.fontSmall = love.graphics.setNewFont("font/nyala.ttf",24)
	heart.fontMedium = love.graphics.setNewFont("font/nyala.ttf",40)
	heart.debug.load()
	viewport.load()
end


function love.quit()
	asset.quit()
end


function love.keypressed(key,isRepeat)
	if isRepeat == false then
		heart.debug.keypressed(key)
		window.keypressed(key)
	end
end


function love.keyreleased(key)
	heart.debug.keyreleased(key)
	window.keyreleased(key)
end


function love.mousepressed(x , y , button)
	heart.debug.mousepressed(x , y , button)
	mouse.pressed(button)

	grid.mousepressed(button)
	
end


function love.mousereleased(x,y,button)
	mouse.released(button)
	--asset.mousereleased(button)
end


function heart.update()

	keyboard.update()
	mouse.update()
	grid.mouseupdate()

	viewport.push()
	--Background Color
	love.graphics.setColor(230,230,215)
	love.graphics.rectangle("fill",0,0,1920,1080)
	
	love.graphics.setColor(255,255,255)
	--PSDprintdrawTEST()
	--mouse.draw()

	grid.update()

	--asset.draw()

	--filter.draw()

	--blendModeDrawingsTEST()

	viewport.screenshot()
	viewport.pop()

end


do  --Default
	function heart.runningTimer()
		_Time = love.timer.getTime() - _TimeStart
		_TimeF = math.floor(_Time)
	end

	function heart.hotLoad(fileName, force)
		assert(love.filesystem.exists(fileName),"File does not exists")
		local ok , hotData , err
		if heart.hotLoadNameTable[fileName] ~= love.filesystem.getLastModified(fileName) or force then
			heart.hotLoadNameTable[fileName] = love.filesystem.getLastModified(fileName)
			if _Debug then
				ok , hotData = pcall(love.filesystem.load ,fileName)  -- Load program
				if ok then
					_Loaded = true -- I want to set this true before loading the program, but I need to prevent it from being set to true forever.
					ok,err = xpcall(love.filesystem.load(fileName),heart.hotLoadHandler) -- Execute program
					if ok then
						print("Time: ".._TimeF..", Loaded: "..fileName)
						_ERRMSG = nil
						heart.debug.loadError = ""
					else
						heart.debug.loadError = "Execute error"
					end
				else
					print("\nTime: ".._TimeF..", Syntax Error: \n"..fileName.." "..hotData.."\n"..debug.traceback())
					heart.debug.loadError = "Syntax error"
				end


			else
				love.filesystem.load(fileName) ( )
			end

			
		end

	end

	function heart.hotLoadHandler(msg)
		print("\nTime: ".._TimeF..", Execute Load Error: \n"..msg.."\n"..debug.traceback().."\n\n".."Unresolved Push Error: "..heart.pushSAFETY.."\n")
		while heart.pushSAFETY > 0 do
			heart.pop()
		end
	end
	
	function heart.updateHandler(msg)
		if _ERRMSG ~= msg then
			print("\nTime: ".._TimeF..", Run Error: \n"..msg.."\n"..debug.traceback().."\n\n".."Unresolved Push Error: "..heart.pushSAFETY.."\n")
			_ERRMSG = msg
		end
		while heart.pushSAFETY > 0 do
			heart.pop()
		end
		if viewport.pushed > 0 then
			viewport.pop()
		end
	end

	-- Can't be updated during runtime
	function love.run()
		love.math.setRandomSeed(os.time())
		for i=1,3 do love.math.random() end
			love.event.pump()
		if heart.require then heart.require() print("All files loaded") end
		if heart.load then heart.load(arg) end
		-- We don't want the first frame's dt to include time taken by love.load.
		love.timer.step()
		dt = 0.016

		print("Load Time:",math.floor((love.timer.getTime() - _TimeStart)*1000)/1000)
		-- Main loop time.
		while true do
			-- Process events.
			
			mouse.reset()
			for e,a,b,c,d in love.event.poll() do
				if e == "quit" then
					if not love.quit or not love.quit() then
						if love.audio then
							love.audio.stop()
						end
					return
					end
				end
				love.handlers[e](a,b,c,d)
			end
			heart.run()
			
		end
	end

	function heart.run()
		
		if _toSleep then
			love.timer.sleep(1)
		end

		do
			love.timer.step()
			dt =  love.timer.getDelta()
			if dt > 0.04 then
				dt = 0.04 -- Clamp dt
			end
		end
	    
		-- Require files
		if heart.require then heart.require() end

		love.graphics.clear()
		love.graphics.origin()

		heart.runningTimer()
		if _Debug then
			xpcall(heart.update,heart.updateHandler)
		else
			heart.update()
		end

		love.graphics.origin()
		heart.pushUpdate()

		heart.debug.update()

		if not _Debug then
			love.timer.sleep(0.001)
		end
		heart.renderInfo() -- Do NOT draw anything between this and love.graphics.present.

		love.graphics.present()
		
		--programwalk.stop()



		love.event.pump()

		debug.sethook()

		
	end
end
