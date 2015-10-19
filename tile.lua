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

--tile[1][5].collision = 0xf -- Change the tile collision to all walls.