local lg = love.graphics
local lk = love.keyboard
local lp = love.physics

local Editor = {}

function Editor:keypressed (key, ...)
    if self.ui:keypressed(key, ...)
    or self.mode:keypressed(key, ...) then
        return
    end
    
    local ctrlPressed = lk.isDown('lctrl', 'rctrl')
    
    -- undo/redo
    if key == 'z' and ctrlPressed then
        if lk.isDown('lshift', 'rshift') then
            self:redo()
        else
            self:undo()
        end
    -- cut
    elseif key == 'x' and ctrlPressed then
        self:cut()
    -- copy
    elseif key == 'c' and ctrlPressed then
        self:copy()
    -- paste
    elseif key == 'v' and ctrlPressed then
        self:paste()
    -- select body
    elseif key == 'b' and ctrlPressed then
        local object = self.selectedObject
        if object and object:typeOf('Fixture') then
            self:selectObject(object:getBody())
        end
    -- delete
    elseif key == 'd' and ctrlPressed then
        self:delete()
    -- toggle grid
    elseif key == 'g' and ctrlPressed then
        self.hideGrid = not self.hideGrid
    -- enable test plugin
    elseif key == 'e' and ctrlPressed then
        self.pluginManager:enable('plugin.color')
    -- remove test plugin
    elseif key == 'r' and ctrlPressed then
        self.pluginManager:disable('plugin.color')
    end
end

function Editor:mousepressed (x, y, button)
    if self.ui:mousepressed(x, y, button)
    or self.mode:mousepressed(x, y, button) then
        return
    end
    
    if button == 3 then
        local cx, cy = self.viewer:getCamera()
        self.panningFrom = { x = x, y = y, cx = cx, cy = cy }
    end
end

function Editor:mousereleased (x, y, button)
    if self.ui:mousereleased(x, y, button)
    or self.mode:mousereleased(x, y, button) then
        return
    end
    
    if button == 3 then
        self.panningFrom = nil
    end
end

function Editor:mousemoved (x, y)
    if self.ui:mousemoved(x, y, button)
    or self.mode:mousemoved(x, y, button) then
        return
    end
    
    local p = self.panningFrom
    if p then
        local s = self.viewer.scale
        x, y = p.x - x, p.y - y
        self.viewer:setCamera(p.cx + x / s, p.cy + y / s)
    end
end

local ZOOM_STEPS = 20
local ZOOM_MIN = 5
local ZOOM_DEFAULT = 30

function Editor:wheelmoved (x, y)
    if self.ui:wheelmoved(x, y)
    or self.mode:wheelmoved(x, y) then
        return
    end
    local z = self.zoomIndex or ZOOM_STEPS
    z = math.min(math.max(ZOOM_MIN, z + y), ZOOM_STEPS * 4)
    self.viewer.scale = ZOOM_DEFAULT * (z ^ 2 / ZOOM_STEPS ^ 2)
    self.zoomIndex = z
end

function Editor:resize (width, height)
    self.width = width
    self.height = height
    
    self.propertyPanel.left = self.width - self.propertyPanel.controlWidth
    
    self.viewer:setViewport(0, 0, width, height)
    self.ui:resize(width, height)
    self.mode:resize(width, height)
end

function Editor:update (dt)
    if self.shouldUpdate then
        self.accumulator = self.accumulator + dt
        while self.accumulator >= self.timestep do
            self.accumulator = self.accumulator - self.timestep
            self.world:update(self.timestep)
        end
    end
    if self.mode.update then
        self.mode:update(dt)
    end
end

local function drawFixtureBoundingBox (self, fixture)
    for i = 1, fixture:getShape():getChildCount() do
        local x1, y1, x2, y2 = fixture:getBoundingBox(i)
        x1, y1 = self:worldToScreen(x1, y1)
        x2, y2 = self:worldToScreen(x2, y2)
        lg.setLineWidth(2)
        lg.setColor(255, 255, 128, 128)
        lg.rectangle('line', x1 - 1, y1 - 1, x2 - x1 + 1, y2 - y1 + 1)
    end
end

local function drawBodyBoundingBox (self, body)
    local x1, y1, x2, y2
    for i, fixture in ipairs(body:getFixtureList()) do
        for j = 1, fixture:getShape():getChildCount() do
            if i == 1 and j == 1 then
                x1, y1, x2, y2 = fixture:getBoundingBox(j)
            else
                fx1, fy1, fx2, fy2 = fixture:getBoundingBox(j)
                
                x1, y1 = math.min(x1, fx1), math.min(y1, fy1)
                x2, y2 = math.max(x2, fx2), math.max(y2, fy2)
            end
        end
    end
    if not x1 then return end
    x1, y1 = self:worldToScreen(x1, y1)
    x2, y2 = self:worldToScreen(x2, y2)
    lg.setLineWidth(2)
    lg.setColor(128, 255, 255, 128)
    lg.rectangle('line', x1, y1, x2 - x1, y2 - y1)
end

function Editor:draw ()
    local viewer = self.viewer
    
    if not self.hideGrid then
        local w, h, s = viewer.width, viewer.height, viewer.scale
        local floor = math.floor
        local detail = self:getGridDetail()
        lg.setLineWidth(1)
        
        -- 1/10 meter grid
        if detail < 1 then
            lg.setColor(16, 16, 16, 255)
            for x = (w * 0.5 + viewer.cameraX * -s) % (s * 0.1), w, s * 0.1 do
                local fx = floor(x) + 0.5
                lg.line(fx, 0, fx, h)
            end
            for y = (h * 0.5 + viewer.cameraY * -s) % (s * 0.1), h, s * 0.1 do
                local fy = floor(y) + 0.5
                lg.line(0, fy, w, fy)
            end
        end
        
        -- 1 meter grid
        if detail < 10 then
            lg.setColor(32, 32, 32, 255)
            for x = (w * 0.5 + viewer.cameraX * -s) % s, w, s do
                local fx = floor(x) + 0.5
                lg.line(fx, 0, fx, h)
            end
            for y = (h * 0.5 + viewer.cameraY * -s) % s, h, s do
                local fy = floor(y) + 0.5
                lg.line(0, fy, w, fy)
            end
        end
        
        -- 10 meter grid
        lg.setColor(48, 48, 48, 255)
        for x = (w * 0.5 + viewer.cameraX * -s) % (s * 10), w, s * 10 do
            local fx = floor(x) + 0.5
            lg.line(fx, 0, fx, h)
        end
        for y = (h * 0.5 + viewer.cameraY * -s) % (s * 10), h, s * 10 do
            local fy = floor(y) + 0.5
            lg.line(0, fy, w, fy)
        end
        
        -- origin axes
        local x, y = viewer:worldToScreen(0, 0)
        local fx = floor(x) + 0.5
        local fy = floor(y) + 0.5
        if fx > 0 and fx < w then
            lg.setColor(0, 80, 0, 255)
            lg.line(fx, 0, fx, h)
        end
        if fy > 0 and fy < h then
            lg.setColor(80, 0, 0, 255)
            lg.line(0, fy, w, fy)
        end
    end
    
    viewer:draw(self.world)
    
    self.mode:draw()
    
    local object = self.selectedObject
    if object then
        if object:typeOf('Fixture') then
            drawFixtureBoundingBox(self, object)
        elseif object:typeOf('Body') then
            drawBodyBoundingBox(self, object)
        end
    end
    
    self.ui:draw()
end

function Editor:textinput (...)
    self.ui:textinput(...)
end

return Editor

