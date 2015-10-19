--[[
	Priority Queue implemented using binary heap.

	You can pass your own compare function if you want to use something else than the objects
	relational operators <= > ==. Like compare using a different field, or prioritize the
	biggest value rather than the smallest.

	The function prototype should look like this
		compare(obj1, obj2)
	and return 
		- a negative number if obj1 is smaller than obj2
		- a positive number if obj1 is bigger than obj2
		- a zero number if obj1 is equal obj2
	

	Example:
		local compare = function(num1, num2) {
			return num1 - num2
		}
		local pw = PriorityQueue:new(compare)
]]


-- Simple run test on load
--[[
for i = 1, 1000 do
	PriorityQueue.test()
end
]]

PriorityQueue = {}


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

-- Default compare function. Uses the objects own relational metamethods: __eq(), __le(), etc...
local function compareDefault(obj1, obj2)
	if obj1 < obj2  then
		return -1
	elseif obj1 == obj2 then
		return 0
	else
		return 1
	end
end

-- PriorityQueue constructor.
function PriorityQueue:new(compare)
	pw = {}
	pw.heap = {}
	pw.size = 0
	pw.compare = (compare or compareDefault)
	setmetatable(pw, self)
	self.__index = self
	return pw
end

-- Adds the object to the priority queue.
function PriorityQueue:insert(object)
	table.insert(self.heap, object)
	self.size = self.size + 1
	percolateUp(self, self.size)
end

-- Removes and returns the smallest element from the queue based on the method compare.
function PriorityQueue:remove()
	local object = self.heap[1]
	self.heap[1] = self.heap[self.size]
	self.heap[self.size] = nil
	self.size = self.size - 1
	percolateDown(self, 1)
	return object
end

-- Removes a specific element from the queue, nil if it doesn't exist.
function PriorityQueue:remove(object)
	local obj = nil
	for i=1, self.size, 1 do
		if self.heap[i] == object then
			obj = self.heap[i]
			self.heap[i] = self.heap[self.size]
			self.heap[self.size] = nil
			self.size = self.size - 1
			percolateDown(i)
		end
	end
	return obj
end

-- Returns the smallest element from the queue based on the method compare without removing it.
function PriorityQueue:peek()
	return self.heap[1]
end

-- This function is used to check if the PriorityQueue is correctly implemented.
function PriorityQueue.test()
	local fails = 0

	local compare = function(num1, num2)
			return num1 - num2
	end

	local pw = PriorityQueue:new(compare)

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

	assert(fails == 0 , "There was "..fails.." errors.") 
end
