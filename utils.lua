

function hexToColor(hexCode)
    local rh = string.sub(hexCode, 1, 2)
    local gh = string.sub(hexCode, 3, 4)
    local bh = string.sub(hexCode, 5, 6)
    local ah = "FF"
    if string.len(hexCode) == 8 then
        ah = string.sub(hexCode, 7, 8)
    end
    local r, g, b, a = tonumber(rh, 16), tonumber(gh, 16), tonumber(bh, 16), tonumber(ah, 16)
    return {love.math.colorFromBytes(r, g, b, a)}
end

colors = {}
colors.white = {1, 1, 1}
colors.black = {0, 0, 0}
colors.red = {1, 0, 0}
colors.orange = {1, 0.5, 0}
colors.yellow = {1, 1, 0}
colors.lemon = {0.5, 1, 0}
colors.green = {0, 1, 0}
colors.teal = {0, 1, 0.5}
colors.turqueza = {0, 1, 1}
colors.cyan = {0, 0.5, 1}
colors.blue = {0, 0, 1}
colors.purple = {0.5, 0, 1}
colors.pink = {1, 0, 1}
colors.rosa = {1, 0, 0.5}
colors.lightrosa = {1, 0.5, 0.75}
colors.celadon = hexToColor("B2EDC5")
colors.feldgraw = hexToColor("3E6259")
colors.lightorange = hexToColor("FCD0A1")
colors.mintcream = hexToColor("EFF7F6")
colors.grey1 = {0.2, 0.2, 0.2}
colors.grey2 = {0.4, 0.4, 0.4}
colors.grey3 = {0.55, 0.55, 0.55}
colors.grey4 = {0.7, 0.7, 0.7}
colors.grey6 = {0.85, 0.85, 0.85}
colors.grey7 = {0.93, 0.93, 0.93}

function distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx^2 + dy^2)
end

function distanceToCursor(x1, y1, camera)
    local mouseX, mouseY = love.mouse.getPosition()
    local worldX = (mouseX - camera.x) / camera.scale
    local worldY = (mouseY - camera.y) / camera.scale
    return distance(x1, y1, worldX, worldY)
end

function screenToWorldPosition(x, y, camera) --recebe coordenada da tela e converte em coordenada do mundo
    local wx = (x - camera.x)/camera.scale
    local wy = (y - camera.y)/camera.scale
    return wx, wy
end

function convertStringToTable(string)
    local tabela = {}
    
    -- Percorre cada número na string separada por vírgulas
    for num in string:gmatch("([^,]+)") do
        table.insert(tabela, tonumber(num)) -- Converte para número e adiciona à tabela
    end

    return tabela
end

function TabletoString(t)
    local s = ""
    for i = 1, #t do
        s = s .. t[i] .. ", "
    end
    return s
end

function copyTable(t)
    local t_ = {}
    for i = 1, #t do
        table.insert(t_, t[i])
    end
    return t_
end

function deepCopy(t)
    local t_ = {t[1]}
    for i = 2, #t do
        table.insert(t_, copyTable(t[i]))
    end
    return t_
end

notesColors = {
    {1, 0, 0},
    {1, 0.5, 0},
    {1, 1, 0},
    {0.7, 1, 0},
    {0, 1, 0},
    {0, 1, 0.8},
    {0, 0.8, 1},
    {0, 0.5, 1},
    {0, 0, 1},
    {0.5, 0, 1},
    {1, 0, 1},
    {1, 0, 0.5},
    {0.9, 0.9, 0.9}
}

Theme = {}
function Theme:new(bg, nl, arrow, acp, pbg)
    local o = {}
    o.backgroundColor = bg
    o.nodeLineColor = nl
    o.arrowColor = arrow
    o.arrowControlPointColor = acp
    o.paletteBg = pbg

    setmetatable(o, self)
    self.__index = self
    return o
end

themes = {
    light = Theme:new({0.8, 0.85, 0.9}, {0, 0, 0}, {0, 0, 0}, {0, 0.6, 1}, {0.75, 0.78, 0.83}),
    dark = Theme:new({0.1, 0.12, 0.15}, {0.7, 0.8, 0.9}, {0.7, 0.76, 0.87}, {0, 0.6, 1}, {0.14, 0.18, 0.2}),
    dark2 = Theme:new({0.0, 0.12, 0.15}, {0.9, 0.7, 0.7}, {0.9, 0.8, 0.7}, {1, 0.6, 0}, {0.12, 0.08, 0.07})
}
function scalarProduct(p1, s)
    return {p1[1]*s, p1[2]*s}
end

function dotProduct(p1, p2)
    return p1[1]*p2[1] + p1[2]*p2[2] 
end

function dotProductNormalized(p1, p2)
    local mag = math.sqrt(p1[1]*p1[1] + p1[2]*p1[2])
    local p1_ = normalize(p1)
    local p2_ = scalarProduct(p2, 1/mag)
    return p1_[1]*p2_[1] + p1_[2]*p2_[2] 
end

function linearCombination(p1, p2, t)
    return (1-t)*p1[1] + t*p2[1], (1-t)*p1[2] + t*p2[2]
end

function normalize(p1)
    local mag = math.sqrt(p1[1]*p1[1] + p1[2]*p1[2])
    return scalarProduct(p1, 1/mag)
end

function numberArrayToString(array)
    if #array == 0 then
        return "[]"
    end
    local s = "["
    for i = 1, #array - 1 do
        s = s .. array[i] .. ", "
    end
    s = s .. array[#array] .. "]"
    return s
end

function transformation(v1, v2)


end

function rotateVector(v, angle)
    local vx, vy = v[1]*math.cos(angle) - v[2]*math.sin(angle), v[2]*math.cos(angle) + v[1]*math.sin(angle)
    return vx, vy
end

function scaleVector(v, amount)
    return v[1]*amount, v[2]*amount
end