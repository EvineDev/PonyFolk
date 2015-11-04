if keyboard == nil then
	keyboard = {}
end

function keyboard.update(  )
	keyboard.up = love.keyboard.isDown("up")
	keyboard.down = love.keyboard.isDown("down")
	keyboard.left = love.keyboard.isDown("left")
	keyboard.right = love.keyboard.isDown("right")
	keyboard.space = love.keyboard.isDown(" ")
end