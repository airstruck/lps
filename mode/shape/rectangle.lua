local lp = love.physics
local lg = love.graphics
local lk = love.keyboard

local Mode = require 'class' (require 'mode')

function Mode:createRectangle (x, y, w, h)
    local body = self.editor:getSelectedBody()
    local shape
    
    self.editor:pushUndo('Create Box')
    
    if body then
        x, y = body:getLocalPoint(x, y)
        shape = lp.newRectangleShape(x, y, w, h, -body:getAngle()) 
        lp.newFixture(body, shape, 1)
    else
        body = lp.newBody(self.editor.world, x, y, 'dynamic')
        shape = lp.newRectangleShape(w, h)
        self.editor:selectObject(lp.newFixture(body, shape, 1))
    end
end

function Mode:mousepressed (x, y, button)
    if button == 1 then
        self.dragPoint = { x = x, y = y }
        return true
    elseif button == 2 then
        self.dragPoint = nil
        self.preview = nil
    end
end

function Mode:mousemoved (x, y)
    local dp = self.dragPoint
    if not dp then return end
    local viewer = self.editor.viewer
    local detail = self.editor:getGridDetail()
    local ax, ay = dp.x, dp.y
    local cx, cy
    if lk.isDown('lalt', 'ralt') then
        x, y = viewer:snapScreenPoint(x, y, detail)
    end
    if lk.isDown('lshift', 'rshift') then
        if lk.isDown('lalt', 'ralt') then
            ax, ay = viewer:snapScreenPoint(ax, ay, 0.5 * detail)
        end
        cx, cy = ax, ay
    else
        if lk.isDown('lalt', 'ralt') then
            ax, ay = viewer:snapScreenPoint(ax, ay, detail)
        end
        cx, cy = (ax + x) * 0.5, (ay + y) * 0.5
    end
    self.preview = {
        x = cx,
        y = cy,
        w = math.abs(cx - x) * 2,
        h = math.abs(cy - y) * 2,
    }
end

function Mode:mousereleased (x, y, button)
    if button ~= 1 then return end
    local preview = self.preview
    if preview and preview.w > 0 and preview.h > 0 then
        local editor = self.editor
        local s = editor.viewer.scale
        local wx, wy = self:screenToWorld(preview.x, preview.y)
        local ww, wh = preview.w / s, preview.h / s
        
        if ww >= 0.01 and wh >= 0.01 then
            self:try(self.createRectangle, self, wx, wy, ww, wh)
        end
    else
        self:selectObjectAtPoint(self:screenToWorld(x, y))
    end
    self.dragPoint = nil
    self.preview = nil
    return true
end

function Mode:draw ()
    local preview = self.preview
    local w, h
    if preview and preview.w > 0 and preview.h > 0 then
        local x, y, w, h = preview.x, preview.y, preview.w, preview.h
        lg.setColor(255, 255, 255)
        lg.rectangle('line', x - w * 0.5, y - h * 0.5, w, h)
        local s = self.editor.viewer.scale
        lg.print(('%.2f'):format(w / s), x - w * 0.5, y + h * 0.5 + 2)
        lg.print(('%.2f'):format(h / s), x + w * 0.5 + 2, y - h * 0.5)
    end
end

return Mode

