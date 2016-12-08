local lg = love.graphics
local lk = love.keyboard

local Mode = require 'class' (require 'mode')

function Mode:mousepressed (x, y, button)
    if button == 1 then
        if self.preview then return end
        self.dragPoint = { x = x, y = y }
        self.endPoint = { x = x, y = y }
        return true
    elseif button == 2 then
        self.dragPoint = false
        self.preview = false
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
    if self.preview then
        -- snap to grid
        if lk.isDown('lalt', 'ralt') then
            local a, b = self.dragPoint, self.endPoint
            local viewer = self.editor.viewer
            local detail = self.editor:getGridDetail()
            a.x, a.y = viewer:snapScreenPoint(a.x, a.y, detail)
            b.x, b.y = viewer:snapScreenPoint(b.x, b.y, detail)
        end
        self:try(self.createJoint, self)
    end
    self.dragPoint = false
    self.preview = false
    return true
end

function Mode:draw ()
    if self.preview then
        local a, b = self.dragPoint, self.endPoint
        local ax, ay, bx, by = a.x, a.y, b.x, b.y
        -- snap to grid
        if lk.isDown('lalt', 'ralt') then
            local viewer = self.editor.viewer
            local detail = self.editor:getGridDetail()
            ax, ay = viewer:snapScreenPoint(ax, ay, detail)
            bx, by = viewer:snapScreenPoint(bx, by, detail)
        end
        
        lg.setColor(255, 255, 255)
        lg.line(ax, ay, bx, by)
    end
end

return Mode

