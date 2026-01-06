-- Variáveis de câmera
camera = {
    x = 0,
    y = 0,
    scale = 1.0
}

-- Variáveis para arrastar com o botão do meio
isDragging = false
dragStartX, dragStartY = 0, 0
dragStartCamX, dragStartCamY = 0, 0

function love.load()
    window_width, window_height = love.graphics.getDimensions( )

    font = love.graphics.newFont("Comfortaa-Bold.ttf", 20)
    require 'utils'
    require 'vector'
    require 'graph'
    require 'palette'
    Palette:initializeAllNotes()
    love.graphics.setFont(font)
    current_theme = themes.light

    love.graphics.setBackgroundColor(current_theme.backgroundColor)
    love.graphics.setLineWidth(current_theme.lineWidth)
    love.graphics.setLineStyle("smooth");
    love.graphics.setLineJoin( "bevel" )
    
    key_pressed = ""
    
end


function love.update(dt)
    -- Atualizar posição da câmera durante o arrasto
    if isDragging then
        local mouseX, mouseY = love.mouse.getPosition()
        camera.x = dragStartCamX + (mouseX - dragStartX)
        camera.y = dragStartCamY + (mouseY - dragStartY)
    end
    Palette:update(dt)
    Graph:update(dt, camera)

end

function love.draw()

    love.graphics.push()
    
    
    love.graphics.translate(camera.x, camera.y)
    love.graphics.scale(camera.scale, camera.scale)
    
    love.graphics.setColor(colors.black)
    love.graphics.circle("fill", 0, 0, 15)
    local controlPoints = {125,125, love.mouse.getX(), love.mouse.getY(), 500,125}
    local curve = love.math.newBezierCurve(controlPoints)
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("current theme: "..key_pressed..", "..current_theme.backgroundColor[1], 0, 80)
    --love.graphics.line(curve:render())
    Graph:draw()
    
--[[
    
    love.graphics.circle("fill", 200, 200, 150)
    love.graphics.circle("fill", 700, 400, 80)
    love.graphics.setLineWidth(8)
    love.graphics.circle("line", 1100, 200, 600)
    love.graphics.circle("line", 1400, 500, 200)
    love.graphics.setColor(colors.red)
    love.graphics.circle("fill", 300, 200, 5)
]]--

    love.graphics.pop()
    Palette:draw()
    if dragging then
        love.graphics.setColor(colors.black)
        love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), 30)
    end


end

function love.mousepressed( x, y, button)
    local palette = Palette:mousepressed(x, y, button)
    if not palette then
        Graph:mousePressed(x, y, button)
    end
    

    if button == 3 then
        isDragging = true
        dragStartX, dragStartY = x, y
        dragStartCamX, dragStartCamY = camera.x, camera.y
    end

end
function love.mousereleased(x, y, button)
    Graph:mouseReleased(x, y, button)

    if button == 3 then
        isDragging = false
        
    end
end
function love.mousemoved(x, y, dx, dy)

end

function love.wheelmoved(x, y)
    -- Armazenar posição do mouse antes do zoom
    local mouseX, mouseY = love.mouse.getPosition()
    local worldX = (mouseX - camera.x) / camera.scale
    local worldY = (mouseY - camera.y) / camera.scale
    
    -- Ajustar escala
    if y > 0 then
        camera.scale = camera.scale + 0.1
    elseif y < 0 then
        camera.scale = math.max(0.1, camera.scale - 0.1) -- Evitar escala negativa ou zero
    end
    
    -- Ajustar posição para manter o zoom centrado no mouse
    camera.x = mouseX - worldX * camera.scale
    camera.y = mouseY - worldY * camera.scale
end
function love.keypressed(key)
    if key == "a" then
        current_theme = themes.light
        love.graphics.setBackgroundColor(current_theme.backgroundColor)
        key_pressed = "a"
        Palette:updateTheme("light")
    end
    if key == "s" then
        current_theme = themes.dark
        love.graphics.setBackgroundColor(current_theme.backgroundColor)
        key_pressed = "s"
        Palette:updateTheme("dark")
    end
    if key == "d" then
        current_theme = themes.dark2
        love.graphics.setBackgroundColor(current_theme.backgroundColor)
        key_pressed = "d"
        Palette:updateTheme("dark")
    end
end

function love.filedropped(file)

end