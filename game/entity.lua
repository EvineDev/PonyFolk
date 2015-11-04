
--[[

entity = {{},{},{},{},{}}

entity.count = 0--entity.count or 0
entity.count = math.max(entity.count , #entity)


heart.insertSparse(entity,"Right here")



entity.count = math.max(entity.count , table.maxn(entity))

for i = 1, 10 do
	
	print(i, "::::" ,entity[i])
end

print(#entity , "--" , entity.count)




for x = 1, tile.width do
	for y = 1, tile.height do
		if tile[x][y].entityIndex ~= 0 then
			print(tile[x][y].entityIndex)
		end
	end
end
--]]
entity = {}
entity.count = 0