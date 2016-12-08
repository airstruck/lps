local lk = love.keyboard
local lp = love.physics

local Mode = require 'class' (require 'mode.shape.multipoint')

function Mode:createShape ()
    local body = self.editor:getSelectedBody()
    local loop = lk.isDown('lshift', 'rshift')
    local shape
    
    self.editor:pushUndo('Create Chain')
    
    if body then
        local points = self:getPoints(body)
        shape = lp.newChainShape(loop, points)
        lp.newFixture(body, shape, 1)
    else
        local points, cx, cy = self:getPoints()
        body = lp.newBody(self.editor.world, cx, cy, 'static')
        shape = lp.newChainShape(loop, points)
        self.editor:selectObject(lp.newFixture(body, shape, 1))
    end
end

return Mode

