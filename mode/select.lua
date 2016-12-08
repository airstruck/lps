local lp = love.physics
local lk = love.keyboard

local Mode = require 'class' (require 'mode')

function Mode:createMouseJoint (x, y)
    local wx, wy = self:screenToWorld(x, y)
    local body = self:selectObjectAtPoint(wx, wy)
    
    self:destroyMouseJoint()
    
    if not body then return end
    self.editor:pushUndoOnce('Move Objects')
    
    local bodyType = body:getType()
    local shouldUpdate = self.editor.shouldUpdate
    
    if bodyType == 'dynamic' and shouldUpdate then
        self.mouseJoint = lp.newMouseJoint(body, wx, wy)
    elseif bodyType == 'kinematic' and shouldUpdate then
        local bx, by = body:getPosition()
        self.kinematicMover = { body = body,
            x = wx, y = wy, ox = bx - wx, oy = by - wy }
    else
        local bx, by = body:getPosition()
        self.staticMover = { body = body,
            x = wx, y = wy, ox = bx - wx, oy = by - wy }
    end
end

function Mode:destroyMouseJoint ()
    if self.mouseJoint and not self.mouseJoint:isDestroyed() then
        self.mouseJoint:destroy()
    end
    self.mouseJoint = nil
    self.staticMover = nil
    self.kinematicMover = nil
end

function Mode:mousepressed (x, y, button)
    if button == 1 then
        self:createMouseJoint(x, y)
    end
end

function Mode:mousereleased (x, y, button)
    if button == 1 then
        self:destroyMouseJoint()
    end
end

function Mode:mousemoved (x, y)
    local wx, wy = self:screenToWorld(x, y)
    
    if self.mouseJoint and not self.mouseJoint:isDestroyed() then
        self.mouseJoint:setTarget(wx, wy)
    elseif self.kinematicMover then
        self.kinematicMover.x = wx
        self.kinematicMover.y = wy
    elseif self.staticMover then
        self.staticMover.x = wx
        self.staticMover.y = wy
    end
end

function Mode:update (dt)
    local km = self.kinematicMover
    if km then
        local body = km.body
        local bx, by = body:getPosition()
        body:setLinearVelocity((km.x - bx + km.ox) * 8, (km.y - by + km.oy) * 8)
    end
    local sm = self.staticMover
    if sm then
        local body = sm.body
        local bx, by = body:getPosition()
        local world = self.editor.world
        local sa = world:isSleepingAllowed()
        local x, y = sm.x + sm.ox, sm.y + sm.oy
        if lk.isDown('lalt', 'ralt') then
            local detail = self.editor:getGridDetail()
            x, y = self.editor.viewer:snapWorldPoint(x, y, detail)
        end
        world:setSleepingAllowed(false)
        body:setPosition(x, y)
        world:setSleepingAllowed(sa)
    end
end

function Mode:destroy ()
    self:destroyMouseJoint()
end

return Mode

