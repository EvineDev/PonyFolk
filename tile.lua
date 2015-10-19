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

--Hack
tilecolworighreiogj = {{2,2},{2,3},{2,4},{2,5},{2,6},{2,7},{3,7},{4,7},{5,7}} -- Path, red is the first tile, purple is the last.
function repgjwpwe()
	grid.insertWall(5,5,1)-- (x,y,direction)
	grid.insertWall(6,5,1)-- These functions will place walls at lower left if the direction argument is 1
	grid.insertWall(7,5,1)-- and lower right if the argument is -1.
	grid.insertWall(8,5,1)

	grid.insertWall(4,6,-1)
	grid.insertWall(4,7,-1)
	grid.insertWall(4,8,-1)
	grid.insertWall(4,9,-1)
end
if grid then repgjwpwe() end