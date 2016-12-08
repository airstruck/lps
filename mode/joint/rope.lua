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
        self.editor:pushUndo('Create Rope Joint')
        self.editor:selectObject(
            lp.newRopeJoint(
                bodyA, bodyB,
                ax, ay, bx, by,
                math.sqrt((ax - bx) ^ 2 + (ay - by) ^ 2), -- max length
                lk.isDown('lctrl', 'rctrl')
            )
        )
    end
end

return Mode

