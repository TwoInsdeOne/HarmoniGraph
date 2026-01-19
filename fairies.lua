Fairy = {}

function Fairy:new(delay, rootNodeID)
    local o = {}
    o.current = {rootNodeID}
    o.rootNode = rootNodeID
    o.historic = {}
    o.delay = delay
    o.lastChange = 0
    o.timer = 0
    o.fairy_img = love.graphics.newImage("fairy/fairy_"..current_theme.quality.."_00001.png")
    o.rotation = 0
    o.mode = "ordered"
    o.ordering = {}
    o.currentOrdering = 1
    setmetatable(o, self)
    self.__index = self
    return o
end
function Fairy:update(dt)
    self.rotation = self.rotation + dt*0.2
    self.timer = self.timer + dt
    if self.timer - self.lastChange > self.delay then
        self:playNext()
        self.lastChange = self.timer
    end
end

function Fairy:playNext()
    if self.mode == "split" then
        local next = {}
        for i = 1, #self.current do
            local currentNode = Graph.nodes[self.current[i]]
            currentNode:Play()
            self:addToHistoric(self.current[i])
            
            for j = 1, #currentNode.nextNodes do
                table.insert(next, currentNode.nextNodes[j])
            end
            
        end
        self.current = {}
        for i = 1, #next do
            table.insert(self.current, next[i])
        end
    end
    if self.mode == "ordered" then
        
        
        local currentNode = Graph.nodes[self.current[1]]
        currentNode:Play()
        
        
        self.current[1] = currentNode.nextNodes[currentNode.currentOrdering]
        currentNode:incrementCurrentOrdering()
    end
end

function Fairy:draw()
    love.graphics.setColor(current_theme.nodeLineColor)
    --love.graphics.print(numberArrayToString(self.current), 0, 140)
    if #self.current > 0 then
        love.graphics.setColor(colors.white)
        local scale = Graph.nodeSize/self.fairy_img:getHeight()
        local origin = self.fairy_img:getHeight()/2
        for i = 1, #self.current do
            local nx, ny = Graph.nodes[self.current[i]].pos.x, Graph.nodes[self.current[i]].pos.y
            love.graphics.draw(self.fairy_img, nx, ny, self.rotation, scale*6, scale*6, origin, origin)
        end
    end
    
    

end

function Fairy:addToHistoric(nodeID)
    local found = false
    for i = 1, #self.historic do
        if self.historic[i] == nodeID then
            found = true
            break
        end
    end
    if not found then
        table.insert(self.historic, nodeID)
    end
end

function Fairy:updateTheme()
    self.fairy_img = love.graphics.newImage("fairy/fairy_".. current_theme.quality.."_00001.png")
end

Fairies = {}
Fairies.list = {}
Fairies.delay = 0.3

function Fairies:addFairy(nodeList)
    for i = 1, #nodeList do
        table.insert(self.list, Fairy:new(self.delay, Graph.nodes[nodeList[i]].id))
    end
end

function Fairies:update(dt)
    for i = 1, #self.list do
        self.list[i]:update(dt)
    end
end
function Fairies:updateTheme()
    for i = 1, #self.list do
        self.list[i]:updateTheme()
    end
end

function Fairies:draw()
    for i = 1, #self.list do
        self.list[i]:draw()
    end

end