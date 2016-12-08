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
        local vx, vy
        if lk.isDown('lshift', 'rshift') then
            vx, vy = 0, 0
        else
            local dx, dy = bx - ax, by - ay
            local len = math.sqrt(dx ^ 2 + dy ^ 2)
            vx, vy = dx / len, dy / len
        end
        self.editor:pushUndo('Create Prismatic Joint')
        self.editor:selectObject(
            lp.newPrismaticJoint(
                bodyA, bodyB,
                ax, ay, bx, by,
                vx, vy, -- axis
                lk.isDown('lctrl', 'rctrl')
            )
        )
    end
end

return Mode

