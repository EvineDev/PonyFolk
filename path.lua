require "bit32"

path = path or {}

local function updateTile(frontier,explored,t,new_cost)
	if not explored:contains(t) then
		if not frontier:contains(t) then
			frontier:insert(t)
		elseif t.cost > new_cost then
			frontier:remove(t)
			t.cost = new_cost
			frontier:insert(t)
		end
	end
end


local function traversePath(gpath, tile)
	if tile.prev ~= nil then
		traversePath(gpath, tile.prev)
	end
	table.insert(gpath, tile)
end

-- Finds the shortest path from the tile coordinates (x0,y0) to (x1,y1).
-- Returns an empty table if no path could be found.
function path.find(x0,y0,x1,y1)
	local frontier = PriorityQueue:new(function(tile1, tile2)
			return tile1.cost - tile2.cost
		end)

	local explored = Set.new()
	local start = tile[x0][y0]
	local goal = tile[x1][y1]
	local node = nil

	start.cost = 0
	start.prev = nil
	frontier:insert(start)

	while true do
		node = frontier:remove()
		if node == goal or node == nil then
			break
		end
		explored:insert(node)

		local new_cost = node.cost + 1

		local t = nil
		if not bit32.btest(node.collision, 0x01) then
			t = tile[node.x][node.y+1] --north-west
			updateTile(frontier,explored,t,new_cost)
		end

		if not bit32.btest(node.collision, 0x02) then
			t = tile[node.x+1][node.y] --north-east
			updateTile(frontier,explored,t,new_cost)
		end

		if not bit32.btest(node.collision, 0x04) then
			t = tile[node.x-1][node.y] --south-west
			updateTile(frontier,explored,t,new_cost)
		end

		if not bit32.btest(node.collision, 0x08) then
			t = tile[node.x][node.y-1] --south-east
			updateTile(frontier,explored,t,new_cost)
		end
	end

	local gpath = {}
	if node ~= nil then
		gpath = traversePath({}, node)
	end

	return gpath
end
