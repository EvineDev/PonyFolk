v2 = {}
v2.__index = v2

-- Fix tables

function v2.__add(a, b)
    if type(a) == "number" then
        return v2.new(b.x + a, b.y + a)
    elseif type(b) == "number" then
        return v2.new(a.x + b, a.y + b)
    else
        return v2.new(a.x + b.x, a.y + b.y)
    end
end


function v2.__sub(a, b)
    if type(a) == "number" then
        return v2.new(a - b.x, a - b.y)
    elseif type(b) == "number" then
        return v2.new(a.x - b, a.y - b)
    else
        return v2.new(a.x - b.x, a.y - b.y)
    end
end


function v2.__mul(a, b)
    if type(a) == "number" then
        return v2.new(b.x * a, b.y * a)
    elseif type(b) == "number" then
        return v2.new(a.x * b, a.y * b)
    else
        return v2.new(a.x * b.x, a.y * b.y)
    end
end


function v2.__div(a, b)
    if type(a) == "number" then
        return v2.new(a / b.x, a / b.y)
    elseif type(b) == "number" then
        return v2.new(a.x / b, a.y / b)
    else
        return v2.new(a.x / b.x, a.y / b.y)
    end
end


function v2.__eq(a, b)
    return a.x == b.x and a.y == b.y
end


function v2.__lt(a, b)
    return a.x < b.x or (a.x == b.x and a.y < b.y)
end


function v2.__le(a, b)
    return a.x <= b.x and a.y <= b.y
end


function v2.__tostring(a)
    return "vector: (" .. a.x .. ", " .. a.y .. ")"
end


function v2.new(x, y)
    return setmetatable({ x = x or 0, y = y or 0 }, v2)
end


function v2.newAngle(angle,length)
    angle ,length = angle or 0 , length or 1
    return setmetatable({ x = math.cos(angle)*length, y = math.sin(angle)*length }, v2)
end


function v2.distance(a, b)
    return (b - a):length()
end


function v2:clone()
    return v2.new(self.x, self.y)
end


function v2:unpack()
    return self.x, self.y
end


function v2:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end


function v2:angle()
    local result = math.atan2(self.y,self.x)
    if result < 0 then result = result +math.pi*2 end
    return result
end


function v2:lengthSq()
    return self.x * self.x + self.y * self.y
end


function v2:normal()
    return self / self:length()
end


function v2:rotate(pi)
    local angle = self:angle()
    local length = self:length()
    self.x,self.y = math.cos(angle+pi)*length , math.sin(angle+pi)*length
end


--[[ untested
function v2:perpendicular()
    return v2.new(-self.y, self.x)
end

function v2:projectOn(other)
    return (self * other) * other / other:lenSq()
end

function v2:cross(other)
    return self.x * other.y - self.y * other.x
end
--]]


function v2:type()
    return "v2"
end

setmetatable(v2, { __call = function(_, ...) return v2.new(...) end })

--https://gist.github.com/johannesgijsbers/880372fc8800e5d5f3e4