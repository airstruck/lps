local lg = love.graphics
local lp = love.physics
local lk = love.keyboard

local Mode = require 'class' (require 'mode.joint')

-- body1, body2, gx1, gy1, gx2, gy2, x1, y1, x2, y2, ratio, collideConnected

function Mode:createJoint ()
    local a, b = self.dragPoint, self.endPoint
    local c, d = self.groundA, self.groundB
    
    if lk.isDown('lalt', 'ralt') then
        local detail = self.editor:getGridDetail()
        local viewer = self.editor.viewer
        a.x, a.y = viewer:snapScreenPoint(a.x, a.y, detail)
        b.x, b.y = viewer:snapScreenPoint(b.x, b.y, detail)
        c.x, c.y = viewer:snapScreenPoint(c.x, c.y, detail)
        d.x, d.y = viewer:snapScreenPoint(d.x, d.y, detail)
    end
    
    local ax, ay = self:screenToWorld(a.x, a.y)
    local bx, by = self:screenToWorld(b.x, b.y)
    local cx, cy = self:screenToWorld(c.x, c.y)
    local dx, dy = self:screenToWorld(d.x, d.y)
        
    local bodyA = self:getBodyAtPoint(ax, ay)
    local bodyB = self:getBodyAtPoint(bx, by)
    
    if bodyA and bodyB and bodyA ~= bodyB then
        self.editor:pushUndo('Create Pulley Joint')
        local joint = lp.newPulleyJoint(
            bodyA, bodyB,
            cx, cy, dx, dy,
            ax, ay, bx, by,
            1,
            lk.isDown('lctrl', 'rctrl')
        )
        self.editor:selectObject(joint)
    end
end

function Mode:mousepressed (x, y, button)
    if button == 1 then
        if self.preview then return end
        self.dragPoint = { x = x, y = y }
        self.endPoint = { x = x, y = y }
        return true
    elseif button == 2 then
        self.dragPoint = false
        self.preview = false
        self.groundA = false
        self.groundB = false
    end
end

function Mode:mousemoved (x, y)
    local dp = self.dragPoint
    if dp then
        self.endPoint = { x = x, y = y }
        self.preview = true
    end
end

function Mode:mousereleased (x, y, button)
    if button ~= 1 then return end
    if self.dragPoint and not self.preview then
        self.preview = true
        return
    end
    if self.dragPoint and not self.groundA then
        self.groundA = { x = x, y = y }
        return
    end
    if self.groundA and not self.groundB then
        self.groundB = { x = x, y = y }
        return
    end
    if self.preview then
        self:try(self.createJoint, self)
    end
    self.dragPoint = false
    self.preview = false
    self.groundA = false
    self.groundB = false
    return true
end

function Mode:draw ()
    if self.preview then
        local viewer = self.editor.viewer
        local a, b = self.dragPoint, self.endPoint
        local c, d = self.groundA, self.groundB
        local ax, ay, bx, by = a.x, a.y, b.x, b.y
        local detail = self.editor:getGridDetail()
        if lk.isDown('lalt', 'ralt') then
            ax, ay = viewer:snapScreenPoint(ax, ay, detail)
            bx, by = viewer:snapScreenPoint(bx, by, detail)
        end
        lg.setColor(255, 255, 255)
        if not c then
            lg.line(ax, ay, bx, by)
            return
        end
        local cx, cy = c.x, c.y
        if lk.isDown('lalt', 'ralt') then
            cx, cy = viewer:snapScreenPoint(cx, cy, detail)
        end
        lg.line(ax, ay, cx, cy)
        if not d then
            lg.line(cx, cy, bx, by)
            return
        end
        local dx, dy = d.x, d.y
        if lk.isDown('lalt', 'ralt') then
            dx, dy = viewer:snapScreenPoint(dx, dy, detail)
        end
        lg.line(cx, cy, dx, dy)
        lg.line(dx, dy, bx, by)
    end
end

return Mode


