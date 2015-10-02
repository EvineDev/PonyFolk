gameplay = gameplay or {}
player = player or {}

if player.init == nil then
	player.pos = v2.new(80,840)
	player.vel = v2.new(0,0)
	player.acc = v2.new(0,0)
	
	player.init = true
end
player.maxSpeed = 350
player.friction = 12
player.accAdded = player.maxSpeed*player.friction

player.jump = 1000

player.form = 
{
	141,349,
	175,265,
	231,367,
}

enemy = {}
enemy.pos = v2.new(1000,840)

enemy.form = 
{
	-337,181,
	-269,77,
	-239,183,
}

player.atk = {}

player.atk.timer = 0
player.atk.animation = 0

player.atk.form = 
{
	-265,-109,
	-185,-127,
	-211,-113,
	-133,-129,
	-163,-115,
	-95,-131,
	-159,-103,
	-151,-111,
	-189,-103,
	-191,-111,
	-225,-97,
	-215,-113,
}

function gameplay.keypressed(key)
	if key == " " and player.atk.timer <= 0 then
		player.atk.timer = 0.3
		player.atk.animation = 0.4
		if player.pos.x < enemy.pos.x and player.pos.x > enemy.pos.x -200 then
			print("Kill")
		end
	end
end


function gameplay.drawCharacter(form,pos,offsetX,offsetY)
	love.graphics.push()
	love.graphics.translate(offsetX+pos.x,offsetY+pos.y)
	local inColor = {love.graphics.getColor()}
	local triangForm = love.math.triangulate(form)
	for i = 1 , #triangForm do
		love.graphics.setColor(inColor)
		love.graphics.polygon("fill",triangForm[i])
		love.graphics.setColor(0,0,0)
		love.graphics.polygon("line",triangForm[i])
	end
	love.graphics.setColor(inColor)
	love.graphics.pop()
end


function gameplay.update()
	love.graphics.translate(960,540)
	gameplay.drawMISC()
	love.graphics.translate(-960,-540)

	love.graphics.setColor(0,255,0)
	gameplay.drawCharacter(enemy.form,enemy.pos,280,-140)
	

	



	player.acc = v2.new(0,0)

	if keyboard.up then
		player.acc = player.acc + v2.new(0,-player.accAdded)
	end
	if keyboard.down then
		player.acc = player.acc + v2.new(0,player.accAdded)
	end

	if keyboard.right then
		player.acc = player.acc + v2.new(player.accAdded,0)
	end
	if keyboard.left then
		player.acc = player.acc + v2.new(-player.accAdded,0)
	end


	player.acc = player.acc + -player.friction*player.vel

	player.pos = 0.5*player.acc*dt^2 + player.vel*dt + player.pos
	player.vel = player.acc*dt + player.vel

	--love.graphics.print(tostring(player.pos).."\n"..tostring(player.vel).."\n"..tostring(player.acc))

	if player.pos.y < 0 then
		player.pos.y = 0
		player.vel.y = 0
	end
	if player.pos.y > 1080 then
		player.pos.y = 1080
		player.vel.y = 0
	end
	if player.pos.x < 0 then
		player.pos.x = 0
		player.vel.x = 0
	end
	if player.pos.x > 1920 then
		player.pos.x = 1920
		player.vel.x = 0
	end

	love.graphics.setColor(0,0,0)
	love.graphics.line(0,840,1920,840)

	love.graphics.setColor(255,0,0)

	local const = _Time*2
	player.form = 
	{
		141+math.cos(const*0.9)*5,349+math.sin(const)*5,
		175+math.sin(const*1.4)*5,265+math.cos(const*1.3)*5,
		231+math.sin(const)*5,367+math.sin(const*0.5)*5,
	}

	gameplay.drawCharacter(player.form,player.pos,-175,-325)

	player.atk.timer = player.atk.timer - dt
	player.atk.animation = player.atk.animation - dt

	love.graphics.setColor(heart.hsv(180,1,1))
	if player.atk.animation > 0 then
		gameplay.drawCharacter(player.atk.form,player.pos,280,80)
	end
	
	love.graphics.print(mouse.x.." , "..mouse.y)
	
	
end
function gameplay.drawMISC()
	--for i = 1 , #pyramid.drawing  do
	--	local fin = love.math.triangulate(pyramid.drawing[i])
	--	for index = 1 , #fin do
	--		love.graphics.setColor(heart.hsv(180,1-i*0.15,1))
	--		love.graphics.polygon("fill",fin[index])
	--		love.graphics.setColor(0,0,0)
	--		love.graphics.polygon("line",fin[index])
	--	end
	--end
end
