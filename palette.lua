Note = {}
function Note:new(name)
    local o = {}
    o.name = name
    o.audioSources = {} --Cada elemento é a mesma nota numa oitava diferente
    o.color = 1
    setmetatable(o, self)
    self.__index = self
    return o
end

function Note:initializeSourceList()
    for i = 1, 5 do
        table.insert(self.audioSources, love.audio.newSource("notes/"..self.name.."/"..self.name..i..".wav", "static"))
    end

end

Palette = {}
Palette.notes = {}
Palette.width = 300
Palette.margin = 0.1

function Palette:initializeAllNotes()
    table.insert(self.notes, Note:new("C"))
    table.insert(self.notes, Note:new("G"))
    table.insert(self.notes, Note:new("D"))
    table.insert(self.notes, Note:new("A"))
    table.insert(self.notes, Note:new("E"))
    table.insert(self.notes, Note:new("B"))
    table.insert(self.notes, Note:new("Gb"))
    table.insert(self.notes, Note:new("Db"))
    table.insert(self.notes, Note:new("Ab"))
    table.insert(self.notes, Note:new("Eb"))
    table.insert(self.notes, Note:new("Bb"))
    table.insert(self.notes, Note:new("F"))
    for i = 1, 12 do
        self.notes[i].color = i
        self.notes[i]:initializeSourceList()
    end
end

function Palette:update(dt)


end

function Palette:draw()
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
    
    
end