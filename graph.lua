Node = {}

function Node:new(x, y)
    local o = {}
    o.x = x
    o.y = y
    o.noteName = ""
    o.root = true
    o.fillColor = 12
    o.empty = true
    o.mouseOver = false
    o.drag = false
    o.dragOffset = {0, 0}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Node:update(dt, camera)
    if distanceToCursor(self.x, self.y, camera) < Graph.nodeSize*2 then
        self.mouseOver = true
    else
        self.mouseOver = false
    end
    if self.drag then
        local wx, wy = screenToWorldPosition(love.mouse.getX(), love.mouse.getY(), camera)
        self.x = wx + self.dragOffset[1]
        self.y = wy + self.dragOffset[2]
    end
end

function Node:draw(nodeSize)
    love.graphics.setLineWidth(4)
    if self.mouseOver then
        love.graphics.setColor(current_theme.arrowControlPointColor)
        love.graphics.circle("line", self.x, self.y, nodeSize+4, 100)
    end
    if self.empty then
        love.graphics.setColor(current_theme.nodeLineColor[1],
            current_theme.nodeLineColor[2],
            current_theme.nodeLineColor[3], 0.17)
    else
        love.graphics.setColor(notesColors[self.fillColor])
    end
    
    love.graphics.circle("fill", self.x, self.y, nodeSize)
    love.graphics.setColor(current_theme.nodeLineColor)
    love.graphics.circle("line", self.x, self.y, nodeSize, 100)
    if self.root then
        local rootSignSize = nodeSize/2
        local rootSignPoints = {self.x, self.y - nodeSize,
            self.x - rootSignSize, self.y - nodeSize - rootSignSize,
            self.x + rootSignSize, self.y - nodeSize - rootSignSize}
        love.graphics.polygon("fill", rootSignPoints)
        love.graphics.arc("fill", self.x, self.y - nodeSize - rootSignSize, rootSignSize/2, 0, -math.pi)
    end

end



Arrow = {}

function Arrow:new(node1, node2)
    local o = {}
    o.node1 = node1
    o.node2 = node2
    o.controlPoints = {node1.x, node1.y, (node1.x+node2.x)/2, (node1.y+node2.y)/2, node2.x, node2.y}
    o.curve = love.math.newBezierCurve(o.controlPoints)
    o.controlPointRadius = 12
    o.controlPointOver = false
    o.controlPointDrag = false
    o.controlPointOffset = {0, 0}
    o.p1 = 0
    o.p2 = 0.333
    o.p3 = 0.666
    o.color = {0, 0, 0}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Arrow:update(dt)
    self.controlPoints = {self.node1.x, self.node1.y,
        self.controlPoints[3], self.controlPoints[4],
        self.node2.x, self.node2.y}
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
end
function Arrow:draw()
    love.graphics.setColor(current_theme.arrowColor)
    love.graphics.line(self.curve:render())
    love.graphics.circle("fill", self.node1.x, self.node1.y, 8, 70)

    if self.controlPointOver then
        love.graphics.setColor(current_theme.arrowControlPointColor)
        love.graphics.circle("line", self.controlPoints[3], self.controlPoints[4], self.controlPointRadius + 3, 80)
    end

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
    love.graphics.circle("fill", self.node2.x, self.node2.y, 8, 70)
    
    local px, py = self.curve:evaluate(self.p1)
    love.graphics.circle("fill", px, py, 6)
    local p2x, p2y = self.curve:evaluate(self.p2)
    love.graphics.circle("fill", p2x, p2y, 6)
    local p3x, p3y = self.curve:evaluate(self.p3)
    love.graphics.circle("fill", p3x, p3y, 6)
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
end

function Graph:update(dt, camera)
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
    for i = 1, #self.arrows, 1 do
        self.arrows[i]:draw()
    end
    for i = 1, #self.nodes, 1 do
        self.nodes[i]:draw(self.nodeSize)
    end
    
    if self.creatingArrow then
        local wx, wy = screenToWorldPosition(love.mouse.getX(), love.mouse.getY(), camera)

        love.graphics.setColor(current_theme.arrowColor[1], current_theme.arrowColor[2], current_theme.arrowColor[3], 0.65)
        love.graphics.line(self.nodes[self.arrowCreationNode1].x,
            self.nodes[self.arrowCreationNode1].y, wx, wy)
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
                self.nodes[node].dragOffset = {self.nodes[node].x - wx, self.nodes[node].y - wy}
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
    if node2 == 0 or node2 == self.arrowCreationNode1 then
        return
    end

    table.insert(self.arrows, Arrow:new(self.nodes[self.arrowCreationNode1], self.nodes[node2]))
    self.nodes[node2].root = false

end