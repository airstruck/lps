local WIDTH = 800
local HEIGHT = 600

local editor

function love.conf (t)
    t.identity = 'lovely-physics-sandbox'
    
    t.window.title = 'Lovely Physics Sandbox'
    t.window.icon = 'res/icon.png'
    t.window.width = WIDTH
    t.window.height = HEIGHT
    t.window.minwidth = 600
    t.window.minheight = 400
    t.window.resizable = true
end

function love.load (args)
    editor = require 'editor' (WIDTH, HEIGHT)
    love.physics.setMeter(1)
    love.resize(WIDTH, HEIGHT)
end

function love.update (dt)
    editor:update(dt)
end

function love.draw ()
    editor:draw()
end

function love.mousepressed (...)
    editor:mousepressed(...)
end

function love.mousereleased (...)
    editor:mousereleased(...)
end

function love.mousemoved (...)
    editor:mousemoved(...)
end

function love.wheelmoved (...)
    editor:wheelmoved(...)
end

function love.textinput (...)
    editor:textinput(...)
end

function love.keypressed (...)
    editor:keypressed(...)
end

function love.resize (...)
    editor:resize(...)
end

