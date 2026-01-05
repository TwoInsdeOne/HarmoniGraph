Node = {}

function Node:new(x, y)
    local o = {}
    o.pos = Vector:new(x, y)
    o.noteName = ""
    o.root = true
    o.fillColor = 12
    o.empty = true
    o.mouseOver = false
    o.drag = false
    o.dragOffset = {0, 0}
    o.id = 0
    o.nextNodes = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Node:update(dt, camera)
    if distanceToCursor(self.pos.x, self.pos.y, camera) < Graph.nodeSize*2 then
        self.mouseOver = true
    else
        self.mouseOver = false
    end
    if self.drag then
        local wx, wy = screenToWorldPosition(love.mouse.getX(), love.mouse.getY(), camera)
        self.pos.x = wx + self.dragOffset[1]
        self.pos.y = wy + self.dragOffset[2]
    end
end

function Node:draw(nodeSize)
    love.graphics.setLineWidth(4)
    if self.mouseOver then
        love.graphics.setColor(current_theme.arrowControlPointColor)
        love.graphics.circle("line", self.pos.x, self.pos.y, nodeSize+4, 100)
    end
    if self.empty then
        love.graphics.setColor(current_theme.nodeLineColor[1],
            current_theme.nodeLineColor[2],
            current_theme.nodeLineColor[3], 0.17)
    else
        love.graphics.setColor(notesColors[self.fillColor])
    end
    
    love.graphics.circle("fill", self.pos.x, self.pos.y, nodeSize)
    love.graphics.setColor(current_theme.nodeLineColor)
    love.graphics.circle("line", self.pos.x, self.pos.y, nodeSize, 100)
    if self.root then
        local rootSignSize = nodeSize/2
        local rootSignPoints = {self.pos.x, self.pos.y - nodeSize,
            self.pos.x - rootSignSize, self.pos.y - nodeSize - rootSignSize,
            self.pos.x + rootSignSize, self.pos.y - nodeSize - rootSignSize}
        love.graphics.polygon("fill", rootSignPoints)
        love.graphics.arc("fill", self.pos.x, self.pos.y - nodeSize - rootSignSize, rootSignSize/2, 0, -math.pi)
    end

end

function Node:insertNextNode(n)
    table.insert(self.nextNodes, n)
end

function Node:hasNextNode(n)
    for i = 1, #self.nextNodes do
        if self.nextNodes[i] == n then
            return true
        end

    end
    return false
end

Arrow = {}

function Arrow:new(node1, node2)
    local o = {}
    o.node1 = node1
    o.node2 = node2
    o.controlPoints = {node1.pos.x, node1.pos.y, (node1.pos.x+node2.pos.x)/2, (node1.pos.y+node2.pos.y)/2, node2.pos.x, node2.pos.y}
    o.curve = love.math.newBezierCurve(o.controlPoints)
    o.controlPointRadius = 12
    o.controlPointOver = false
    o.controlPointDrag = false
    o.controlPointOffset = {0, 0}
    o.p1 = 0
    o.p2 = 0.333
    o.p3 = 0.666
    o.color = {0, 0, 0}
    o.lastBasePoint = {0, 0}
    o.lastAngle = 0
    o.lastLength = 0
    setmetatable(o, self)
    self.__index = self
    return o
end

function Arrow:update(dt)
    self.controlPoints = {self.node1.pos.x, self.node1.pos.y,
        self.controlPoints[3], self.controlPoints[4],
        self.node2.pos.x, self.node2.pos.y}
    self.curve = love.math.newBezierCurve(self.controlPoints)

    self.p1 = self.p1 + dt
    if self.p1 >= 1 then
        self.p1 = 0
    end
    self.p2 = self.p2 + dt
    if self.p2 >= 1 then
        self.p2 = 0
    end
    self.p3 = self.p3 + dt
    if self.p3 >= 1 then
        self.p3 = 0
    end

    if distanceToCursor(self.controlPoints[3], self.controlPoints[4], camera) < self.controlPointRadius*2 then
        self.controlPointOver = true
    else
        self.controlPointOver = false
    end
    if self.controlPointDrag then
        local wx, wy = screenToWorldPosition(love.mouse.getX(), love.mouse.getY(), camera)
        self.controlPoints[3] = wx + self.controlPointOffset[1]
        self.controlPoints[4] = wy + self.controlPointOffset[2]

    end

    if Graph.dragNode == self.node2.id then
        local currentAngle = self:getAngle()
        
        local deltaAngle = currentAngle - self.lastAngle 
        local controlpoint_ = Vector:new(self.controlPoints[3], self.controlPoints[4])
        controlpoint_ = controlpoint_ - self.node1.pos
        controlpoint_:rotateVector(deltaAngle)
        controlpoint_ = controlpoint_ + self.node1.pos
        self.controlPoints[3], self.controlPoints[4] = controlpoint_.x, controlpoint_.y
        local scale = 1
        if self.lastLength > 0 then
            scale = self:getLength()/self.lastLength
        end
        controlpoint_ = Vector:new(self.controlPoints[3], self.controlPoints[4])
        controlpoint_ = controlpoint_ - self.node1.pos
        controlpoint_ = controlpoint_*scale
        controlpoint_ = controlpoint_ + self.node1.pos
        self.controlPoints[3], self.controlPoints[4] = controlpoint_.x, controlpoint_.y
        
    end
    if Graph.dragNode == self.node1.id then
        local currentAngle = self:getAngle()
        
        local deltaAngle = currentAngle - self.lastAngle 
        local controlpoint_ = Vector:new(self.controlPoints[3], self.controlPoints[4])
        controlpoint_ = controlpoint_ - self.node2.pos
        controlpoint_:rotateVector(deltaAngle)
        controlpoint_ = controlpoint_ + self.node2.pos
        self.controlPoints[3], self.controlPoints[4] = controlpoint_.x, controlpoint_.y
        local scale = 1
        if self.lastLength > 0 then
            scale = self:getLength()/self.lastLength
        end
        controlpoint_ = Vector:new(self.controlPoints[3], self.controlPoints[4])
        controlpoint_ = controlpoint_ - self.node2.pos
        controlpoint_ = controlpoint_*scale
        controlpoint_ = controlpoint_ + self.node2.pos
        self.controlPoints[3], self.controlPoints[4] = controlpoint_.x, controlpoint_.y
        
    end
    
end
function Arrow:draw()
    love.graphics.setColor(current_theme.arrowColor)
    
    love.graphics.line(self.curve:render())
    love.graphics.circle("fill", self.node1.pos.x, self.node1.pos.y, 8, 70)

    love.graphics.setColor(current_theme.arrowControlPointColor)
    

    if self.controlPointDrag then
        love.graphics.setColor(current_theme.arrowControlPointColor)
    else
        love.graphics.setColor(current_theme.backgroundColor[1],
            current_theme.backgroundColor[2],
            current_theme.backgroundColor[3], 0.4)
    end
    love.graphics.circle("fill", self.controlPoints[3], self.controlPoints[4], self.controlPointRadius)
    if self.controlPointDrag then
        love.graphics.setColor(current_theme.arrowControlPointColor)
    else
        love.graphics.setColor(current_theme.arrowColor[1], current_theme.arrowColor[2], current_theme.arrowColor[3], 0.4)
    end
    love.graphics.circle("line", self.controlPoints[3], self.controlPoints[4], self.controlPointRadius, 80)
    love.graphics.setColor(current_theme.arrowColor)
    love.graphics.circle("fill", self.node2.pos.x, self.node2.pos.y, 8, 70)
    
    local px, py = self.curve:evaluate(self.p1)
    love.graphics.circle("fill", px, py, 6)
    local p2x, p2y = self.curve:evaluate(self.p2)
    love.graphics.circle("fill", p2x, p2y, 6)
    local p3x, p3y = self.curve:evaluate(self.p3)
    love.graphics.circle("fill", p3x, p3y, 6)
end

function Arrow:getAngle()
    return math.atan2(self.node2.pos.y - self.node1.pos.y, self.node2.pos.x - self.node1.pos.x)
end

function Arrow:getLength()
    return self.node1.pos:distance(self.node2.pos)
end

function Arrow:getMidPoint()
    return (self.node1.pos.x + self.node2.pos.x)/2, (self.node1.pos.y + self.node2.pos.y)/2
end

function Arrow:getBasePoint()
    --this is the point C along the node1 and node2 segment that forms a rect triangle from the points node1, controlPoint and C.
    local p1, p2 = {self.node2.pos.x - self.node1.pos.x, self.node2.pos.y - self.node1.pos.y}, {self.controlPoints[3] - self.node1.pos.x, self.controlPoints[4] - self.node1.pos.y}
    local t = dotProductNormalized(p1, p2)
    local dx, dy = linearCombination({self.node1.pos.x, self.node1.pos.y}, {self.node2.pos.x, self.node2.pos.y}, t) -- eixo X
    return dx, dy
end

function Arrow:getControlPointVectorFromBase()
    local vx, vy = self:getBasePoint()
    local bx, by = vx - self.controlPoints[3], vy - self.controlPoints[4]
    return bx, by
end


Graph = {}
Graph.nodes = {}
Graph.arrows = {}
Graph.nodeSize = 24
Graph.creatingArrow = false
Graph.arrowCreationNode1 = 0
Graph.arrowCreationNode2 = 0
Graph.dragArrowControlPoint = 0
Graph.dragNode = 0
function Graph:newNode(x, y, camera)
    local wx, wy = screenToWorldPosition(x, y, camera)
    table.insert(self.nodes, Node:new(wx, wy))
    self.nodes[#self.nodes].id = #self.nodes 
end

function Graph:update(dt, camera)

    for i = 1, #self.arrows, 1 do
        self.arrows[i].lastAngle = self.arrows[i]:getAngle()
        self.arrows[i].lastLength = self.arrows[i]:getLength()
    end
    for i = 1, #self.nodes, 1 do
        self.nodes[i]:update(dt, camera)
    end
    for i = 1, #self.arrows, 1 do
        self.arrows[i]:update(dt)
    end
end

function Graph:draw()
    love.graphics.setColor(colors.blue)
    love.graphics.print(">"..#self.nodes, 0, 20)
    love.graphics.print(">"..#self.arrows, 0, 40)
    if self.creatingArrow then
        love.graphics.print("creating arrow: "..self.arrowCreationNode1.." -> "..self:GetMouseOverNode(), 0, 60)
    end
    --[[for i = 1, #self.nodes do
        love.graphics.print(numberArrayToString(self.nodes[i].nextNodes), 0, 20*i+80)
    end]]--
    for i = 1, #self.arrows, 1 do
        self.arrows[i]:draw()
    end
    for i = 1, #self.nodes, 1 do
        self.nodes[i]:draw(self.nodeSize)
    end
    
    if self.creatingArrow then
        local wx, wy = screenToWorldPosition(love.mouse.getX(), love.mouse.getY(), camera)

        love.graphics.setColor(current_theme.arrowColor[1], current_theme.arrowColor[2], current_theme.arrowColor[3], 0.65)
        love.graphics.line(self.nodes[self.arrowCreationNode1].pos.x,
            self.nodes[self.arrowCreationNode1].pos.y, wx, wy)
    end
end

function Graph:mousePressed(x, y, button)
    if button == 1 then
        local arrow = Graph:GetMouseOverArrow()
        if arrow == 0 then
            local node = Graph:GetMouseOverNode()
            if node == 0 then
                self:newNode(x, y, camera)
            else
                local wx, wy = screenToWorldPosition(love.mouse.getX(), love.mouse.getY(), camera)
                self.nodes[node].drag = true
                self.nodes[node].dragOffset = {self.nodes[node].pos.x - wx, self.nodes[node].pos.y - wy}
                self.dragNode = node
            end
        else
            local wx, wy = screenToWorldPosition(love.mouse.getX(), love.mouse.getY(), camera)
            self.arrows[arrow].controlPointDrag = true
            self.arrows[arrow].controlPointOffset = {self.arrows[arrow].controlPoints[3] - wx,
                self.arrows[arrow].controlPoints[4] - wy}
            self.dragArrowControlPoint = arrow
        end

    end
    if button == 2 then
        self:startArrow()

    end
end

function Graph:mouseReleased(x, y, button)
    if button == 1 then
        if self.dragArrowControlPoint ~= 0 then
            self.arrows[self.dragArrowControlPoint].controlPointDrag = false
            self.dragArrowControlPoint = 0
            
        else
            if self.dragNode ~= 0 then
                self.nodes[self.dragNode].drag = false
                self.dragNode = 0
            end
        end
    end
    if button == 2 then
        self:finishArrow()

    end
end

function Graph:GetMouseOverNode()
    local n = 0
    for i = 1, #self.nodes, 1 do
        if self.nodes[i].mouseOver then
            n = i
        end
    end
    return n
end

function Graph:GetMouseOverArrow()
    local n = 0
    for i = 1, #self.arrows, 1 do
        if self.arrows[i].controlPointOver then
            n = i
        end
    end
    return n
end

function Graph:startArrow()
    local node1 = self:GetMouseOverNode()
    if node1 == 0 then
        return
    end
    self.creatingArrow = true
    self.arrowCreationNode1 = node1

end
function Graph:finishArrow()
    self.creatingArrow = false
    local node2 = self:GetMouseOverNode()
    if node2 == 0 or node2 == self.arrowCreationNode1 or self.nodes[self.arrowCreationNode1]:hasNextNode(node2) then
        return
    end

    table.insert(self.arrows, Arrow:new(self.nodes[self.arrowCreationNode1], self.nodes[node2]))
    self.nodes[self.arrowCreationNode1]:insertNextNode(node2)
    self.nodes[node2].root = false

end