window = window or {}

if window.init == nil then
	local checkFile = pcall(function() require "personalwindow" end)

	if checkFile then
		window.magicValue = require "personalwindow"
	else
		window.magicValue = {y = 0,taskbarHeight = 40}
	end



	window.desktop = {love.window.getDesktopDimensions()}
	if love._os == "Windows" then
		window.width = 960
		window.height = window.desktop[2] - window.magicValue.taskbarHeight
	elseif love._os == "OS X" then
		window.width = 720
		window.height = window.desktop[2] - 23
	end
	
	window.init = true
end



function window.start()
	local width , height ,flag
	if _Debug then
		width , height = window.width , window.height
		flag = {}
		flag.x = window.desktop[1] - width
		flag.y = window.magicValue.y
		flag.borderless = true
		flag.resizable = false
		flag.highdpi = true
		flag.fsaa = 0
		flag.vsync = false
	else
		--75% of screen in the smallest direction
		width , height = love.window.getDesktopDimensions()
		width , height = math.min(width/16,height/9)*12 , math.min(width/16,height/9)*6.75 
		flag = {}
		flag.fullscreen = false
		flag.fullscreentype = "desktop"
		flag.borderless = false
		flag.resizable = true
		flag.highdpi = true
		flag.fsaa = 0
		flag.vsync = false
	end
	love.window.setMode(width,height,flag)
end



function window.keypressed(key)
	if key == "q" then
		local w , h , s = love.window.getMode()
		s.vsync = not s.vsync
		love.window.setMode(w,h,s)
	end
	if key == "w" then
		local w , h , s = love.window.getMode()
		s.resizable = not s.resizable
		s.borderless = not s.resizable
		
		love.window.setMode(w,h,s)
	end
	if key == "f" then
		keyboard.TimeSincePressedTheF = love.timer.getTime()
	end
end

function window.keyreleased(key)
	if key == "f" then
		if love.timer.getTime() - keyboard.TimeSincePressedTheF < 0.4 then
			love.window.setFullscreen( not love.window.getFullscreen() , "desktop" )
		else
			local w , h , s = love.window.getMode()
			s.borderless = false
			s.resizable = false
			s.fullscreen = false
			s.x , s.y = nil , nil

			local desktop = {love.window.getDesktopDimensions()}
			if desktop[1] > 1920 and desktop[2] > 1080 then
				love.window.setMode(1920,1080,s)
			elseif desktop[1] == 1920 or desktop[2] == 1080 then
				love.window.setFullscreen( not love.window.getFullscreen() , "desktop" )
			else
				love.window.setMode(960,540,s)
			end
		end
	end
end

