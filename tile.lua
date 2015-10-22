
tile = {}

tile.width = 200 -- undefinend what these 2 will end up as.
tile.height = 200

tile.NORTH_WEST = 1 -- should be 0?
tile.NORTH_EAST = 2
tile.SOUTH_WEST = 4
tile.SOUTH_EAST = 8

for x = 1, tile.width do
	tile[x] = {}
	for y = 1, tile.height do
		tile[x][y] = -- Add stuff in here as needed
		{
			entityIndex = 0, -- Where in the entity it belongs
			entityWallLeft = 0, -- Wall left and right can also stay on the same tile
			entityWallRight = 0,



			objectMark = {},

			x = x,
			y = y,
			collision = 0x0,

			-- Used for path-finding
			cost = 0,
			prev = nil
		}
	end
end


function tile.addCollision(ttile, direction)
	ttile.collision = bit.bor(ttile.collision, direction)
end


function tile.removeCollision(ttile, direction)
	ttile.collision = bit.band(ttile.collision, bit.bnot(direction))
end


function tile.addWall(ttile, direction)
	tile.addCollision(ttile, direction)
	local otile = nil
	if direction == tile.NORTH_WEST then
		otile = tile[ttile.x-1][ttile.y]
		tile.addCollision(otile, tile.SOUTH_EAST)

	elseif direction == tile.NORTH_EAST then
		otile = tile[ttile.x][ttile.y-1]
		tile.addCollision(otile, tile.SOUTH_WEST)

	elseif direction == tile.SOUTH_WEST then
		otile = tile[ttile.x][ttile.y+1]
		tile.addCollision(otile, tile.NORTH_EAST)

	elseif direction == tile.SOUTH_EAST then
		otile = tile[ttile.x+1][ttile.y]
		tile.addCollision(otile, tile.NORTH_WEST)
	end
end


function tile.removeWall(ttile, direction)
	tile.removeCollision(ttile, direction)
	local otile = nil
	if direction == tile.NORTH_WEST then
		otile = tile[ttile.x-1][ttile.y]
		tile.removeCollision(otile, tile.SOUTH_EAST)

	elseif direction == tile.NORTH_EAST then
		otile = tile[ttile.x][ttile.y-1]
		tile.removeCollision(otile, tile.SOUTH_WEST)

	elseif direction == tile.SOUTH_WEST then
		otile = tile[ttile.x][ttile.y+1]
		tile.removeCollision(otile, tile.NORTH_EAST)

	elseif direction == tile.SOUTH_EAST then
		otile = tile[ttile.x+1][ttile.y]
		tile.removeCollision(otile, tile.NORTH_WEST)
	end
end


for x=1, tile.width, 1 do
	tile.addCollision(tile[x][1], tile.NORTH_EAST)
end

for x=1, tile.width, 1 do
	tile.addCollision(tile[x][tile.height], tile.SOUTH_WEST)
end

for y=1, tile.width, 1 do
	tile.addCollision(tile[1][y], tile.NORTH_WEST)
end

for y=1, tile.width, 1 do
	tile.addCollision(tile[tile.width][y], tile.SOUTH_EAST)
end


--Hack
require "path"
-- The actual collisions
tile.addWall(tile[6][5], tile.SOUTH_WEST)
tile.addWall(tile[7][5], tile.SOUTH_WEST)
tile.addWall(tile[8][5], tile.SOUTH_WEST)
tile.addWall(tile[9][5], tile.SOUTH_WEST)
	
tile.addWall(tile[5][6], tile.SOUTH_EAST)
tile.addWall(tile[5][7], tile.SOUTH_EAST)
tile.addWall(tile[5][8], tile.SOUTH_EAST)
tile.addWall(tile[5][9], tile.SOUTH_EAST)

tilecolworighreiogj = path.find(2, 2, 6, 6)

function repgjwpwe()
	-- (x,y,direction)
	grid.mark("wallleft",6,5)-- These functions will place walls at lower left if the direction argument is 1
	grid.mark("wallleft",7,5)-- and lower right if the argument is -1.
	grid.mark("wallleft",8,5)
	grid.mark("wallleft",9,5)

	grid.mark("wallright",5,6)
	grid.mark("wallright",5,7)
	grid.mark("wallright",5,8)
	grid.mark("wallright",5,9)
end
--if grid then repgjwpwe() end


