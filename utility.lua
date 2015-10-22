-- Needed for utility ?
--if heart.utility == nil then
--	heart.utility = {}
--end

heart.pushSAFETY = heart.pushSAFETY  or 0


function math.round(value)
	return math.floor(value+0.5)
end


function math.wrap(value,limit)
	return value - math.floor(value/limit)*limit
end


function math.clamp(value,limitOne,limitTwo)
	if limitOne < limitTwo then

		if value < limitOne then
			value = limitOne
		elseif value > limitTwo then
			value = limitTwo
		end

	else

		if value < limitTwo then
			value = limitTwo
		elseif value > limitOne then
			value = limitOne
		end

	end
	return value
end


function math.minAngle(inputValA , inputValB)
	inputValA = math.wrap(inputValA , math.pi*2)
	inputValB = math.wrap(inputValB , math.pi*2)

	local result
	if inputValA < inputValB then
		if inputValB - inputValA > math.pi then
			result = (inputValB-math.pi*2) - inputValA
		else
			result = inputValB - inputValA
		end
	else
		if inputValA - inputValB > math.pi then
			result = inputValB + (math.pi*2-inputValA)
		else
			result = inputValB - inputValA 
		end
	end

	return result
end


function math.dir(value , tolerance)
	tolerance = tolerance or 0
	assert(tolerance >= 0, "tolerance cant be negative")
	if value <= tolerance and value >= -tolerance then
		return 0
	elseif value > tolerance then
		return 1
	elseif value < -tolerance then
		return -1
	end
	assert(false,"Passed in invalid value to math.dir. Value: "..tostring(value))
end


-- limit is index/table length
-- and it returns values
-- starting from 1 to limit

-- Don't return value on self
-- WRONG: (This will increment timer by 1 each frame)
-- timer = timer + dt
-- timer = math.wrapIndex( timer , limit )
-- animation.state[timer]

-- CORRECT:
-- timer = timer + dt
-- index = math.wrapIndex( timer , limit )
-- animation.state[index]
function math.wrapIndex(value,limit)
	return math.floor(1+math.wrap(value,limit))
end


--[[ If the hue is sepperated into 1530 values then the r,g,b steplength is 1
Beware of rounding errors then
Perfect worst case drawing loop. Steplength 1 in hue is 4.25 in the r,g,b space
for i = 0 , 1530 do
	local r,g,b = heart.hsv(i/4.25,1,1)
	love.graphics.setColor(math.round(r),math.round(g),math.round(b))
	love.graphics.rectangle("fill",i-1,200,1,200)
end
--]]


function heart.hsv(h,s,v,a)
	assert(type(h) == "number" and type(s) == "number" and type(v) == "number" , 
		"heart.hsv(h,s,v) values is not passed in as numbers")
	

	s = math.clamp(s,0,1)
	v = math.clamp(v,0,1)

	a = a or 1

	if s == 0 then
		return v*255,v*255,v*255,a*255
	end

	h = math.wrap(h / 60 , 6)

	local index = math.floor(h)
	local f = h - index
	local p = v * ( 1 - s )
	local q = v * ( 1 - s * f )
	local t = v * ( 1 - s * ( 1 - f ) )



	local r,g,b
	if index == 0 then
		r,g,b = v,t,p		
	elseif index == 1 then
		r,g,b = q,v,p
	elseif index == 2 then
		r,g,b = p,v,t
	elseif index == 3 then
		r,g,b = p,q,v
	elseif index == 4 then
		r,g,b = t,p,v
	else
		r,g,b = v,p,q
	end

	--if a then
		return r*255,g*255,b*255,a*255
	--else
	--	return r*255,g*255,b*255
	--end
end


function heart.sethsv(r,g,b,a)
	love.graphics.setColor(heart.hsv(r,g,b,a))
end


function heart.normalize(value,min,max)
	return (value-min)/(max-min)
end


function heart.interpolate(input, range)
	assert(input ~= nil, "1st argument to interpolate is missing")
	assert(range < 2, "input to interpolate is to large")
	range = range or 1
	if range == 0 then
		return 0.5
	end
	local major = ((-math.cos(((1-0.5)*range+0.5)*math.pi))+1)*0.5
	local minor = 1-major

	local result = ((-math.cos(((input-0.5)*range+0.5)*math.pi))+1)*0.5

	result = heart.normalize(result,minor,major)
	return result
end


function heart.circle(x,y,od,id,segments)
	if id == nil or id <= 0 then
		love.graphics.circle("fill",x,y,od,segments)
	else
		heart.push("all")
		love.graphics.setLineWidth(od-id)
		love.graphics.setLineJoin("bevel")
		love.graphics.circle("line",x,y,(od+id)/2,segments)
		heart.pop()
	end
end


function heart.pushUpdate()
	printv("Unresolved Push",heart.pushSAFETY)
	while heart.pushSAFETY > 0 do
		heart.pop()
	end
end


function heart.push(...)
	heart.pushSAFETY = heart.pushSAFETY + 1
	love.graphics.push(...)
end


function heart.pop()
	heart.pushSAFETY = heart.pushSAFETY - 1
	love.graphics.pop()
end


function heart.clearTable(inTable)
	for k, v in pairs(inTable) do
		inTable[k] = nil
	end
end


function heart.clearArray(inTable)
	for i = 1, #inTable do
		inTable[i] = nil
	end
end


function heart.insertSparse(tableTo,item)
	local i = 1
	while tableTo[i] ~= nil do
		i = i+1
	end
	tableTo[i] = item
end

function heart.lengthSparse(tableTo)
	local i = 1
	while tableTo[i] ~= nil do
		i = i+1
	end
	return i-1
end