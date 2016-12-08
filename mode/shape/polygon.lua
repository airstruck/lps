local lp = love.physics

local Mode = require 'class' (require 'mode.shape.multipoint')

function Mode:createShape ()
    local body = self.editor:getSelectedBody()
    local shape
    
    self.editor:pushUndo('Create Polygon')
    
    if body then
        local points = self:getPoints(body)
        shape = lp.newPolygonShape(points)
        lp.newFixture(body, shape, 1)
    else
        local points, cx, cy = self:getPoints()
        body = lp.newBody(self.editor.world, cx, cy, 'dynamic')
        shape = lp.newPolygonShape(points)
        self.editor:selectObject(lp.newFixture(body, shape, 1))
    end
end

return Mode

