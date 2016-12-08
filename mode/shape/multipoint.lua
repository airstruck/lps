-- abstract base class for chain and polygon shapes

local lg = love.graphics
local lk = love.keyboard
local lp = love.physics
local inf = math.huge

local Mode = require 'class' (require 'mode')

function Mode:getPoints (body)
    local points = {}
    local p = self.preview
    local viewer = self.editor.viewer
    local xMin, yMin, xMax, yMax = inf, inf, -inf, -inf
    for i = 1, #p do
        local a = p[i]
        local ax, ay = a.x, a.y
        ax, ay = self:screenToWorld(ax, ay)
        if lk.isDown('lalt', 'ralt') then
            local detail = self.editor:getGridDetail()
            ax, ay = viewer:snapWorldPoint(ax, ay, detail)
        end
        if body then
            ax, ay = body:getLocalPoint(ax, ay)
        end
        points[#points + 1] = ax
        points[#points + 1] = ay
        xMin = math.min(xMin, ax)
        xMax = math.max(xMax, ax)
        yMin = math.min(yMin, ay)
        yMax = math.max(yMax, ay)
    end
    if body then
        return points
    end
    local cx, cy = (xMin + xMax) * 0.5, (yMin + yMax) * 0.5
    for i = 1, #points - 1, 2 do
        points[i] = points[i] - cx
        points[i + 1] = points[i + 1] - cy
    end
    return points, cx, cy
end

function Mode:mousepressed (x, y, button)
    if button == 1 then
        if self.preview then return end
        self.dragPoint = { x = x, y = y }
        self.endPoint = { x = x, y = y }
        return true
    elseif button == 2 then
        self:try(self.createShape, self)
        self.dragPoint = false
        self.preview = false
    end
end

function Mode:mousemoved (x, y)
    local dp = self.dragPoint
    if dp then
        self.endPoint = { x = x, y = y }
    end
    if self.dragPoint and not self.preview then
        self.preview = { self.dragPoint }
    end
end

function Mode:mousereleased (x, y, button)
    if button ~= 1 then return end
    if self.dragPoint and not self.preview then
        self:selectObjectAtPoint(self:screenToWorld(x, y))
        self.dragPoint = nil
        return
    end
    if self.preview then
        self.preview[#self.preview + 1] = { x = x, y = y }
    end
    return true
end

function Mode:draw ()
    if self.preview then
        local viewer = self.editor.viewer
        local p = self.preview
        local ax, ay, bx, by
        lg.setColor(255, 255, 255)
        for i = 1, #p do
            local a = p[i]
            local b = p[i + 1]
            if not b then
                b = self.endPoint
            end
            ax, ay, bx, by = a.x, a.y, b.x, b.y
            if lk.isDown('lalt', 'ralt') then
                local detail = self.editor:getGridDetail()
                ax, ay = viewer:snapScreenPoint(ax, ay, detail)
                bx, by = viewer:snapScreenPoint(bx, by, detail)
            end
            lg.line(ax, ay, bx, by)
        end
    end
end

return Mode

