--[[
	Priority Queue implemented using binary heap.

	It's important you pass a function compare(obj1, obj2) to the constructor when making
	a PriorityQueue. It should return a positive number if obj1 > obj2, zero if obj1 == obj2,
	and a negative number if obj1 < obj2. The queue will always return the smallest object
	based on the compare function. If the priority queue should return the biggest object,
	then simply reversing the compare function should fix that.
	
	Example of making a PriorityQueue: 

		pw = PriorityQueue:new({
			compare = function(obj1, obj2)
		    	      	return obj1 - obj2
		        	  end
		})
]]


PriorityQueue = {
	compare = nil,
	heap = {},
	size = 0
}

-- PriorityQueue constructor.
function PriorityQueue:new(pw)
	pw = pw or {}
	setmetatable(pw, self)
	self.__index = self
	return pw
end

-- Adds the object to the priority queue.
function PriorityQueue:insert(object)
	table.insert(self.heap, object)
	self.size = self.size + 1
	self:percolateUp(self.size)
end

-- Removes and returns the smallest element from the queue based on the method compare.
function PriorityQueue:remove()
	local object = self.heap[1]
	self.heap[1], self.heap[self.size] = self.heap[self.size], nil
	self.size = self.size - 1
	self:percolateDown(1)
	return object
end

-- Returns the smallest element from the queue based on the method compare without removing it.
function PriorityQueue:peek()
	return self.heap[1]
end

-- Private, don't use directly. It's meant to be called from insert().
function PriorityQueue:percolateUp(index)
	if index <= 1 then
		return
	end
	
	local parent = math.floor(index/2)
	if self.compare(self.heap[index], self.heap[parent]) < 0 then
		self.heap[index], self.heap[parent] = self.heap[parent], self.heap[index]
		self:percolateUp(parent)	
	else
		return
	end
end

-- Private, don't use directly. It's meant to be called from remove().
function PriorityQueue:percolateDown(index)
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
		self:percolateDown(largest)
	end
end

-- This function is used to check if the PriorityQueue is correctly implemented. Returns true
-- if all tests passed and false if any of the tests failed.
function PriorityQueue.test()
	local fails = 0

	local pw = PriorityQueue:new({
		compare = function(left, right)
		          	return left - right
		          end
	})

	local data = {8, 5, 3, 5, 7, 4, 1, 9}
	local target = {1, 3, 4, 5, 5, 7, 8, 9}

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

	if fails > 0 then
		return false
	else 
		return true
	end
end