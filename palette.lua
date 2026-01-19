Select = {}
function Select:new(mode, x, y, size)
    local o = {}
    o.mode = mode
    o.position = Vector:new(x, y)
    o.size = size
    
    setmetatable(o, self)
    self.__index = self
    return o
end

function Select:isMouseOver()
    local mo = false
    local mp = Vector:new(love.mouse.getPosition())
    if self.mode == 'rect' then
        return mp.x > self.position.x and mp.x < self.position.x + self.size and 
            mp.y > self.position.y and mp.y < self.position.y + self.size
    else
        return self.position:distance(mp) <= self.size
    end
end

function Select:draw()
    if self:isMouseOver() then
        if self.mode == "rect" then
            love.graphics.rectangle("fill", self.position.x, self.position.y, self.size, self.size)
        else
            love.graphics.circle("line", self.position.x, self.position.y, self.size + 5)
        end
    end

end

Note = {}
function Note:new(name, x, y)
    local o = {}
    o.name = name
    o.audioSources = {} --Cada elemento é a mesma nota numa oitava diferente
    o.color = 1
    o.select = Select:new("circle", x, y, 26)
    setmetatable(o, self)
    self.__index = self
    return o
end

function Note:initializeSourceList()
    for i = 1, 5 do
        --table.insert(self.audioSources, love.audio.newSource("notes/"..self.name.."/"..self.name..i..".wav", "static"))
    end
end

function Note:draw()
    love.graphics.setColor(notesColors[self.color])
    self.select:draw()

end

function Note:getSelectOver()
    return self.select:isMouseOver()
end

Palette = {}
Palette.notes = {}
Palette.width = 300
Palette.margin = 0.1
Palette.notesNames = {"C", "G", "D", "A", "E", "B", "Gb", "Db", "Ab", "Eb", "Bb", "F"}
Palette.notesNames1 = {"C", "G", "D", "A", "E", "B", "G♭", "D♭", "A♭", "E♭", "B♭", "F"}
Palette.notesNames2 = {"C", "G", "D", "A", "E", "B", "F#", "C#", "G#", "D#", "A#", "F"}
Palette.pos = Vector:new(0, 0)
Palette.image = love.graphics.newImage("imgs/chromatic-circle-white.png")
Palette.currentNote = 0
Palette.currentOctave = 3
Palette.octaveQtd = 5
Palette.notation = "bemol"
Palette.c3 = love.audio.newSource( "notes/C3_.wav", "static" )

function Palette:initializeAllNotes(mode)
    
    for i = 1, 12 do
        local px, py = math.cos(math.rad(i*30 - 120))*120, math.sin(math.rad(i*30 - 120))*120
        table.insert(self.notes, Note:new(self.notesNames[i], px, py))
        self.notes[i].color = i
        --self.notes[i]:initializeSourceList()
    end
end

function Palette:update(dt)
    local w_width, w_height = love.graphics.getDimensions()
    self.pos.x, self.pos.y = w_width - self.width/2, self.width/2
    for i = 1, 12 do
        local px, py = math.cos(math.rad(i*30 - 120))*105 + self.pos.x, math.sin(math.rad(i*30 - 120))*105 + self.pos.y
        self.notes[i].select.position = Vector:new(px, py)
    end
end

function Palette:draw()
    
    love.graphics.setColor(current_theme.paletteBg[1], current_theme.paletteBg[2], current_theme.paletteBg[3], 0.8)
    love.graphics.rectangle("fill", self:getBounds2())
    local radius = self.image:getHeight()
    local scale = self.width/radius
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(self.image, self.pos.x, self.pos.y, 0, scale, scale, radius/2, radius/2)
    love.graphics.setColor(colors.black)
    love.graphics.circle("fill", self.pos.x, self.pos.y, 5)
    for i = 1, 12 do
        self.notes[i]:draw()
    end
    local w_width, w_height = love.graphics.getDimensions()
    if self.currentNote > 0 then
        love.graphics.setColor(notesColors[self.currentNote])
        love.graphics.circle("fill", w_width - self.width + 32, 32, 25)
    end
    love.graphics.setColor(current_theme.arrowColor)
    love.graphics.circle("line", w_width - self.width + 32, 32, 25)

    --#######################

    love.graphics.setColor(current_theme.paletteBg[1], current_theme.paletteBg[2], current_theme.paletteBg[3], 0.8)
    love.graphics.rectangle("fill", self:getBounds3())
    local x3, y3, w3, h3 = self:getBounds3()
    local _cell_size = w3/self.octaveQtd
    love.graphics.setFont(font2)
    love.graphics.setColor(current_theme.nodeLineColor)
    love.graphics.print("octave:", x3+ 4, y3 - 18, 0, 0.6, 0.6)
    for i = 1, self.octaveQtd do
        local ox, oy = font2:getWidth(i)/2.8, font2:getHeight(i)/2.5
        love.graphics.print(i, x3 + _cell_size*(i-0.5), y3 + 20, 0, 0.8, 0.8, ox, oy)
        if self.currentOctave == i then
            love.graphics.rectangle("line", x3 + _cell_size*(i-1), y3, _cell_size, h3)
        end
    end

end

function Palette:draw2()
    local w_width, w_height = love.graphics.getDimensions()
    love.graphics.setColor(current_theme.paletteBg)
    local height = self.width/3.0
    local startX = w_width/2 - self.width/2
    local startY = w_height - height - 5
    love.graphics.rectangle("fill", startX, startY, self.width, height)
    love.graphics.setColor(current_theme.nodeLineColor)
    love.graphics.rectangle("line", startX, startY, self.width, height)

    local cell_margin = self.margin*(height/2)
    local cell_size = height/2
    local cell_size2 = (1 - 2*self.margin)*(height/2)
    for j = 1, 2 do
        for i = 1, 6 do
            love.graphics.setColor(notesColors[i + 6*(j-1)])
            love.graphics.rectangle("fill", startX + cell_size*(i-1) + cell_margin, startY + cell_size*(j-1) + cell_margin, cell_size2, cell_size2)
        end
    end

    if cursorInsideRect(startX - 5, startY - 5, self.width + 5, height + 5) then
        love.graphics.setLineWidth(10)
        love.graphics.setColor(colors.red)
        love.graphics.rectangle("line", startX - 3, startY - 3, self.width+ 3, height + 3)
        love.graphics.setColor(current_theme.nodeLineColor)
        love.graphics.setLineWidth(current_theme.lineWidth)
    end
end

function Palette:getSelectRect(id)


end

function Palette:isMouseOver()

end

function Palette:generateNoteSource(noteID)
    local newSource = Palette.c3:clone()
    if noteID == 2 then
        newSource:setPitch( (2^(1/12))^7 )
    end
    if noteID == 3 then
        newSource:setPitch( (2^(1/12))^2 )
    end
    if noteID == 4 then
        newSource:setPitch( (2^(1/12))^9 )
    end
    if noteID == 5 then
        newSource:setPitch( (2^(1/12))^4 )
    end
    if noteID == 6 then
        newSource:setPitch( (2^(1/12))^11 )
    end
    if noteID == 7 then
        newSource:setPitch( (2^(1/12))^6 )
    end
    if noteID == 8 then
        newSource:setPitch( (2^(1/12))^1 )
    end
    if noteID == 9 then
        newSource:setPitch( (2^(1/12))^8 )
    end
    if noteID == 10 then
        newSource:setPitch( (2^(1/12))^3 )
    end
    if noteID == 11 then
        newSource:setPitch( (2^(1/12))^10 )
    end
    if noteID == 12 then
        newSource:setPitch( (2^(1/12))^5 )
    end
    return newSource
end

function Palette:updateTheme(mode) --dark or light
    if mode == "dark" then
        self.image = love.graphics.newImage("imgs/chromatic-circle-black.png")
    end
    if mode == "light" then
        self.image = love.graphics.newImage("imgs/chromatic-circle-white.png")
    end
    
end

function Palette:getBounds1()
    local w_width, w_height = love.graphics.getDimensions()
    local height = self.width/3.0
    return w_width/2 - self.width/2, w_height - height - 5, self.width, height
end
function Palette:getBounds2()
    local w_width, w_height = love.graphics.getDimensions()

    return w_width - self.width, 0, self.width, self.width
end

function Palette:getBounds3()
    
    local x, y, w, h = self:getBounds2()
    return x, w, self.width, 40
end

function Palette:mousepressed(x, y, button)
    local _x, _y, w, h = self:getBounds2()
    local x2, y2, w2, h2 = self:getBounds3()
    if cursorInsideRect(_x - 5, _y - 5, w + 5, h + 5) or cursorInsideRect(x2 - 5, y2 - 5, w2 + 5, h2 + 5) then
        self.currentNote = 0
        for i = 1, 12 do
            if self.notes[i]:getSelectOver() then
                self.currentNote = i
                break
            end
        end
        return true
    end
    

    return false
end

function Palette:wheelmoved(x, y)
    local _x, _y, w, h = self:getBounds2()
    local x2, y2, w2, h2 = self:getBounds3()
    if cursorInsideRect(_x - 5, _y - 5, w + 5, h + 5) then
        if y > 0 then
            self.currentNote = self.currentNote + 1
            if self.currentNote > 12 then
                self.currentNote = 1
            end
        end
        if y < 0 then
            self.currentNote = self.currentNote - 1
            if self.currentNote < 1 then
                self.currentNote = 12
            end
        end
        return true
    end
    if cursorInsideRect(x2 - 5, y2 - 5, w2 + 5, h2 + 5)  then
        if y > 0 then
            self.currentOctave = self.currentOctave + 1
            if self.currentOctave > self.octaveQtd then
                self.currentOctave = 1
            end
        end
        if y < 0 then
            self.currentOctave = self.currentOctave - 1
            if self.currentOctave < 1 then
                self.currentOctave = self.octaveQtd
            end
        end
        return true
    end
    return false
end