tile = {}

tile.width = 20 -- undefinend what these 2 will end up as.
tile.height = 15

for x = 1, tile.width do
	tile[x] = {}
	for y = 1, tile.height do
		tile[x][y] = {collision = 0x0} -- Add stuff in here as needed
	end
end

--tile[1][5].collision = 0xf -- Change the tile collision to all walls.