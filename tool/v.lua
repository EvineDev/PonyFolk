v = {}

function v.add(xA,yA,xB,yB)
	return xA + xB , yA + yB 
end

function v.sub(xA,yA,xB,yB)
	return xA - xB , yA - yB 
end

function v.mul(xA,yA,xB,yB)
	return xA * xB , yA * yB 
end

function v.div(xA,yA,xB,yB)
	return xA / xB , yA / yB 
end

function v.length(x,y)
	return math.sqrt(x^2+y^2)
end

function v.angle(x,y)
	local result = math.atan2(y,x)
    if result < 0 then result = result + math.pi*2 end
    return result
end

function v.rotate(x,y,angle)
	local length = v.length(x,y)
	angle = v.angle(x,y) + angle
	return math.cos(angle)*length , math.sin(angle)*length
end

function v.normal(x,y)
	local length = v.length(x,y)
	return x / length , y / length
end

function v.new(angle,length)
	return math.cos(angle)*length, math.sin(angle)*length
end
