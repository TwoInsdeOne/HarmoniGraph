Vector = {}

function Vector:new(x, y)
    local o = {}
    o.x = x or 0
    o.y = y or 0
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Sobrecarga do operador +
function Vector.__add(v1, v2)
    return Vector:new(v1.x + v2.x, v1.y + v2.y)
end

-- Sobrecarga do operador - (subtração)
function Vector.__sub(v1, v2)
    return Vector:new(v1.x - v2.x, v1.y - v2.y)
end

-- Sobrecarga do operador * (multiplicação escalar)
function Vector.__mul(v, escalar)
    if type(v) == "number" then
        v, escalar = escalar, v
    end
    return Vector:new(v.x * escalar, v.y * escalar)
end

-- Sobrecarga do operador / (divisão escalar)
function Vector.__div(v, escalar)
    return Vector:new(v.x / escalar, v.y / escalar)
end

-- Sobrecarga do operador == (igualdade)
function Vector.__eq(v1, v2)
    return v1.x == v2.x and v1.y == v2.y
end

function Vector.__lt(v1, v2)
    return v1:getMagnitude() < v2:getMagnitude()
end

function Vector.__le(v1, v2)
    return v1:getMagnitude() <= v2:getMagnitude()
end

-- Sobrecarga do tostring para print()
function Vector.__tostring(v)
    return "[" .. v.x .. ", " .. v.y .. "]"
end
function Vector.__name(v)
    return "Vector"
end

function Vector:distance(v2)
    local v_ = self - v2
    return v_:getMagnitude()
end

function Vector:getMagnitude()
    return math.sqrt(self.x*self.x + self.y*self.y)
end

function Vector:normalize()
    self.x, self.y = self:getNormalized()
end

function Vector:getNormalized()
    return self.x/self:getMagnitude(), self.y/self:getMagnitude()
end

function Vector:dotProduct(v2)
    return self.x*v2.x + self.y*v2.y
end

function Vector:getTransformation(matrix) -- matrix has to be in the form of:  {{a, b}, {c, d}}
    return self.x*matrix[1][1] + self.y*matrix[1][2], self.x*matrix[2][1] + self.y*matrix[2][2]
end

function Vector:rotateVector(angle)
    self.x, self.y = self.x*math.cos(angle) - self.y*math.sin(angle), self.y*math.cos(angle) + self.x*math.sin(angle)
end

function Vector:getRotatedVector(angle)
    return Vector:new(self.x*math.cos(angle) - self.y*math.sin(angle), self.y*math.cos(angle) + self.x*math.sin(angle))
end

function Vector:linearCombination(v2, t)
    return Vector:new(self.x*(1-t) + v2.x*t, self.y*(1-t) + v2.y*t )
end