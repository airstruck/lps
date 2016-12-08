local lp = love.physics
local lk = love.keyboard

local Mode = require 'class' (require 'mode.joint')

function Mode:createJoint ()
    local a, b = self.dragPoint, self.endPoint
    local ax, ay = self:screenToWorld(a.x, a.y)
    local bx, by = self:screenToWorld(b.x, b.y)
    local bodyA = self:getBodyAtPoint(ax, ay)
    local bodyB = self:getBodyAtPoint(bx, by)
    
    if bodyA and bodyB and bodyA ~= bodyB then
        self.editor:pushUndo('Create Distance Joint')
        self.editor:selectObject(
            lp.newDistanceJoint(
                bodyA, bodyB,
                ax, ay, bx, by,
                lk.isDown('lctrl', 'rctrl')
            )
        )
    end
end

return Mode

