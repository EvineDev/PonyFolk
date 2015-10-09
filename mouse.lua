mouse = mouse or {}


mouse.x = 0
mouse.y = 0

mouse.left = false
mouse.right = false
mouse.beenPressed = {}
mouse.beenReleased = {}

mouse.beenPressed.left = false
mouse.beenReleased.left = false


function mouse.pressed(button)
	if button == "l" then
		mouse.beenPressed.left = true
	end
end


function mouse.released(button)
	if button == "l" then
		mouse.beenReleased.left = true
	end
end


function mouse.reset()
	mouse.beenReleased.left = false
	mouse.beenPressed.left = false
end


function mouse.update()
	if love.mouse.isDown("l") then
		mouse.left = true
	else
		mouse.left = false
	end
	if love.mouse.isDown("r") then
		mouse.right = true
	else
		mouse.right = false
	end
	mouse.x = 1 + (love.mouse.getX()-viewport.translateX)*(1/viewport.scale)
	mouse.y = 1 + (love.mouse.getY()-viewport.translateY)*(1/viewport.scale)
end


function mouse.draw()
	love.graphics.setColor(0,0,0)

	love.graphics.print(
		"X: "..mouse.x..
		"\nY: "..mouse.y)
end

