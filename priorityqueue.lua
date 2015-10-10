--[[
	Priority Queue implemented using binary heap.
	If you want to use a diffrent compare function, add a new compare function in this file and create a new flag in PriorityQueue:new()
	
	Example of making a PriorityQueue: 
	pw = PriorityQueue:new() -- lessthan is the default flag
]]


local function compareLessThan(obj1, obj2) -- Predeclared function
	return obj1 - obj2
end


-- Removes and returns the smallest element from the queue based on the method compare.
function PriorityQueue:remove()
	local object = self.heap[1]
	self.heap[1] = self.heap[self.size]
	self.heap[self.size] = nil
	self.size = self.size - 1
	self:percolateDown(1)
	return object
end

-- Private. It's meant to be called from insert().
local function percolateUp(self, index)
	if index <= 1 then
		return
	end
	
	local parent = math.floor(index/2)
	if self.compare(self.heap[index], self.heap[parent]) < 0 then
		self.heap[index], self.heap[parent] = self.heap[parent], self.heap[index]
		percolateUp(self, parent)	
	else
		return
	end
end


-- Private. It's meant to be called from remove().
local function percolateDown(self, index)
	local left = 2*index
	local right = 2*index+1
	local largest = index

	if left <= self.size and self.compare(self.heap[left], self.heap[largest]) < 0 then
		largest = left
	end
	if right <= self.size and self.compare(self.heap[right], self.heap[largest]) < 0 then
		largest = right
	end

	if largest ~= index then
		self.heap[index], self.heap[largest] = self.heap[largest], self.heap[index]
		percolateDown(self, largest)
	end
end


-- PriorityQueue constructor.
function PriorityQueue:new(flag)
	-- Always assert user defined input
	assert(flag == nil or flag == "lessthan", "flag is an invaild value")
	flag = flag or "lessthan"

	local pw = {}
	if flag == "lessthan" then
		pw.compare = compareLessThan
	end
	pw.heap = {} -- Inhereting a table means you get a Refrence to the table. Not a copy.
	pw.size = 0
	setmetatable(pw, self)
	self.__index = self
	return pw
end


-- Adds the object to the priority queue.
function PriorityQueue:insert(object)
	-- Always assert user defined input
	assert(type(object) == "number" , "Object is not a number") 
	table.insert(self.heap, object)
	self.size = self.size + 1
	percolateUp(self, self.size)
end


-- Removes and returns the smallest element from the queue based on the method compare.
function PriorityQueue:remove()
	local object = self.heap[1]
	self.heap[1], self.heap[self.size] = self.heap[self.size], nil
	self.size = self.size - 1
	percolateDown(self, 1)
	return object
end


-- Returns the smallest element from the queue based on the method compare without removing it.
function PriorityQueue:peek()
	return self.heap[1]
end


-- This function is used to check if the PriorityQueue is correctly implemented. Returns true
-- if all tests passed and false if any of the tests failed.
function PriorityQueue.test()
	local fails = 0

	local pw = PriorityQueue:new()

	local data = {}
	local target = {}
	for i = 1, love.math.random(1,200) do
		data[i] = love.math.random(-20,500)
		target[i] = data[i]
	end
	table.sort(target)

	for i = 1, #data, 1 do
		pw:insert(data[i])
	end
	
	local value = pw:peek()
	if value ~= target[1] then
		print("TestError (PriorityQueue): Expected " .. target[1] .. ", got " .. value)
		fails = fails + 1
	end

	for i = 1, #target, 1 do
		value = pw:remove()
		if value ~= target[i] then
			print("TestError (PriorityQueue): Expected " .. target[i] .. ", got " .. value)
			fails = fails + 1
		end
	end

	if #pw.heap ~= 0 then
		print("TestError (PriorityQueue): The queue was expected to be empty, but got " .. #pw.heap)
		fails = fails + 1 
	end

	if pw.size ~= 0 then
		print("TestError (PriorityQueue): Expected size 0, got " .. pw.size)
		fails = fails + 1 
	end

	-- Just crash, no need to return anything
	assert(fails == 0 , "There was "..fails.." errors.") 
end


-- Simple run test on load
--[[
for i = 1, 1000 do
	PriorityQueue.test()
end
--]]