require "bit"

tile = {}

tile.width = 200 -- undefinend what these 2 will end up as.
tile.height = 200

tile.NORTH_WEST = 1
tile.NORTH_EAST = 2
tile.SOUTH_WEST = 4
tile.SOUTH_EAST = 8

for x = 1, tile.width do
	tile[x] = {}
	for y = 1, tile.height do
		tile[x][y] = -- Add stuff in here as needed
		{
			entityIndex = 0, -- Where in the entity it belongs


			
			objectMark = {},
			wallLeft = false,
			wallRight = false,

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

--tile[1][5].collision = 0xf -- Change the tile collision to all walls.