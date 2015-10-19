require "bit"
require "priorityqueue"
require "tile"
local Set = require "set"

path = path or {}

path.INFINITY = 2000000000

local function updateTile(frontier, explored, prev, t, new_cost)
	if t == nil then
		return
	end
	
	if not explored:contains(t) then
		print(new_cost .. " < " .. t.cost)
		if new_cost < t.cost then
			t.prev = prev
			t.cost = new_cost
			frontier:remove(t)
			frontier:insert(t)
		elseif not frontier:contains(t) then
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


local function btest(x, y)
  return bit.band(x, y) ~= 0
end

-- Finds the shortest path from the tile coordinates (x0,y0) to (x1,y1).
-- Returns an empty table if no path could be found.
function path.find(x0, y0, x1, y1)
	local frontier = PriorityQueue:new(function(tile1, tile2)
			return tile1.cost - tile2.cost
		end)

	for x = 1, tile.width do
		for y = 1, tile.height do
			tile[x][y].cost = path.INFINITY
		end
	end

	local explored = Set.new()
	local start = tile[x0][y0]
	local goal = tile[x1][y1]
	local node = nil

	start.cost = 0
	start.prev = nil
	frontier:insert(start)

	while true do
		node = frontier:removeMin()
		--print(node.x .. " || " .. node.y)
		if node == goal or node == nil then
			break
		end
		explored:insert(node)

		local new_cost = node.cost + 1

		local t = nil
		if not btest(node.collision, tile.NORTH_WEST) then
			t = tile[node.x-1][node.y] --north-west
			updateTile(frontier, explored, node, t, new_cost)
		end

		if not btest(node.collision, tile.NORTH_EAST) then
			t = tile[node.x][node.y-1] --north-east
			updateTile(frontier, explored, node, t, new_cost)
		end

		if not btest(node.collision, tile.SOUTH_WEST) then
			t = tile[node.x][node.y+1] --south-west
			updateTile(frontier, explored, node, t, new_cost)
		end

		if not btest(node.collision, tile.SOUTH_EAST) then
			t = tile[node.x+1][node.y] --south-east
			updateTile(frontier, explored, node, t, new_cost)
		end
	end

	local gpath = {}
	if node ~= nil then
		traversePath(gpath, node)
	end

	return gpath
end
