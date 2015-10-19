tile = {}

tile.width = 200 -- undefinend what these 2 will end up as.
tile.height = 200

for x = 1, tile.width do
	tile[x] = {}
	for y = 1, tile.height do
		tile[x][y] = -- Add stuff in here as needed
		{
			entityIndex = 0, -- Where in the entity it belongs

			collision = 0x0,
			objectMark = {},
			wallLeft = false,
			wallRight = false,
		}
	end
end

--tile[1][5].collision = 0xf -- Change the tile collision to all walls.