local lg = love.graphics
local lm = love.mouse

local icons = lg.newImage('res/icons.png')

local PADDING = 4
local ICON_SIZE = 32
local PAGE_SIZE = 600
local y = 0
local function Q (start)
    local y2 = start or y
    y = y2 + ICON_SIZE
    return y2, ICON_SIZE, ICON_SIZE, PAGE_SIZE, PAGE_SIZE
end
local atlas = {
    ['mode.select'] = lg.newQuad(200, Q(16)),
    
    ['mode.shape.circle'] = lg.newQuad(200, Q()),
    ['mode.shape.rectangle'] = lg.newQuad(200, Q()),
    ['mode.shape.polygon'] = lg.newQuad(200, Q()),
    ['mode.shape.edge'] = lg.newQuad(200, Q()),
    ['mode.shape.chain'] = lg.newQuad(200, Q()),
    
    ['mode.joint.distance'] = lg.newQuad(16, Q(16)),
    ['mode.joint.friction'] = lg.newQuad(16, Q()),
    ['mode.joint.gear'] = lg.newQuad(16, Q()),
    ['mode.joint.motor'] = lg.newQuad(16, Q()),
    ['mode.joint.mouse'] = lg.newQuad(16, Q()),
    ['mode.joint.prismatic'] = lg.newQuad(16, Q()),
    ['mode.joint.pulley'] = lg.newQuad(16, Q()),
    ['mode.joint.revolute'] = lg.newQuad(16, Q()),
    ['mode.joint.rope'] = lg.newQuad(16, Q()),
    ['mode.joint.weld'] = lg.newQuad(16, Q()),
    ['mode.joint.wheel'] = lg.newQuad(16, Q()),
    
    ['file.plugin'] = lg.newQuad(400, Q(16)),
    ['file.load'] = lg.newQuad(400, Q()),
    ['file.save'] = lg.newQuad(400, Q()),
    ['file.import'] = lg.newQuad(400, Q()),
    
    ['edit.undo'] = lg.newQuad(400, Q()),
    ['edit.redo'] = lg.newQuad(400, Q()),
    ['edit.delete'] = lg.newQuad(400, Q()),
    ['edit.cut'] = lg.newQuad(400, Q()),
    ['edit.copy'] = lg.newQuad(400, Q()),
    ['edit.paste'] = lg.newQuad(400, Q()),
}

local Panel = require 'class' () 

function Panel:init (left, top, controlWidth, controlHeight)
    self.left = left
    self.top = top
    self.controlWidth = controlWidth
    self.controlHeight = controlHeight
    self.controls = {}
end

function Panel:addControls (t)
    local controls = self.controls
    for _, control in ipairs(t) do
        controls[#controls + 1] = control
    end
end

function Panel:clear ()
    self.controls = {}
end

function Panel:removeFrom (ui)
    local panels = ui.panels
    for i = #panels, 1, -1 do
        if self == panels[i] then
            table.remove(panels, i)
        end
    end
end

function Panel:getControlAt (x, y)
    local cx, cy = self.left, self.top
    local cw, ch = self.controlWidth, self.controlHeight
    local controls = self.controls
    
    if x < cx or x >= cx + cw or y < cy or y >= cy + ch * #controls then
        return
    end
    
    local i = math.floor((y - cy) / ch) + 1
    return controls[i], cx, cy + ch * (i - 1), cw, ch
end

function Panel:getControl (index)
    local cx, cy = self.left, self.top
    local cw, ch = self.controlWidth, self.controlHeight
    return self.controls[index],
        cx, cy + ch * (index - 1), cw, ch
end

local HorizontalPanel = require 'class' (Panel)

function HorizontalPanel:getControlAt (x, y)
    local cx, cy = self.left, self.top
    local cw, ch = self.controlWidth, self.controlHeight
    local controls = self.controls
    
    if x < cx or x >= cx + cw * #controls or y < cy or y >= cy + ch then
        return
    end
    
    local i = math.floor((x - cx) / cw) + 1
    return controls[i], cx + cw * (i - 1), cy, cw, ch
end

function HorizontalPanel:getControl (index)
    local cx, cy = self.left, self.top
    local cw, ch = self.controlWidth, self.controlHeight
    return self.controls[index],
        cx + cw * (index - 1), cy, cw, ch
end

local Ui = require 'class' ()

Ui.Panel = Panel
Ui.HorizontalPanel = HorizontalPanel

function Ui:init (editor)
    self.editor = editor
    self.panels = {}
end

function Ui:getControlAt (x, y, destroyTransient)
    local panels = self.panels
    for i = #panels, 1, -1 do
        local panel = panels[i]
        local c, cx, cy, cw, ch = panel:getControlAt(x, y)
        if c then return c, cx, cy, cw, ch end
        if destroyTransient and panel.transient then
            table.remove(panels, i)
        end
    end
end

function Ui:drawControl (control, cx, cy, cw, ch)
    local mx, my = love.mouse.getPosition()
    local hovered = mx >= cx and mx < cx + cw and my >= cy and my < cy + ch
    local pressed = control == self.pressedControl
    if control.tip and hovered then
        lg.setColor(255, 255, 255)
        lg.print(control.tip, 4, self.editor.height - 20)
    end
    if control.mode == self.editor.modeName
    or control.isSelected and control:isSelected() then
        lg.setColor(255, 255, 128)
    elseif control.type == 'label' then
        lg.setColor(128, 128, 128)
    elseif control.type == 'textbox' and control.focused then
        lg.setColor(255, 255, 255)
    elseif hovered and pressed then
        if control.type == 'slider' then
            lg.setColor(224, 224, 224)
        else
            lg.setColor(160, 160, 160)
        end
    elseif hovered and not self.isPressed then
        lg.setColor(224, 224, 224)
    else
        lg.setColor(192, 192, 192)
    end
    lg.rectangle('fill', cx, cy, cw, ch)
    if control.type == 'textbox' then
        control.x, control.y, control.width, control.height
            = cx + 4, cy, cw - 16, ch
    elseif control.type == 'slider' then
        local amount = control:getAmount() or 0
        local width = (amount - control.min) / 
            (control.max - control.min) * cw
        if width > 0 then
            lg.setColor(255, 255, 128)
            lg.rectangle(mode or 'fill', cx, cy, width, ch)
        end
        lg.setColor(0, 0, 0)
        lg.printf(string.format(control.format or '%.2f', amount),
            cx, cy + PADDING, cw - PADDING, 'right')
    end
    local quad = control.mode and atlas[control.mode]
        or control.icon and atlas[control.icon]
    if quad then
        lg.draw(icons, quad, cx, cy)
    end
    if control.text then
        if control.type == 'label' then
            lg.setColor(224, 224, 224)
        else
            lg.setColor(0, 0, 0)
        end
        lg.print(control.text, cx + PADDING, cy + PADDING)
    end
    if control.getValue then
        lg.printf(control:getValue(), cx, cy + PADDING, cw - PADDING, 'right')
    end
end

local function updateSlider (control, x, cx, cy, cw, ch)
    local u = (x + 1 - cx) / cw
    local min, max = control.min, control.max
    control:setAmount(math.min(math.max(
        min, u * (max - min) + min), max))
end

function Ui:mousepressed (x, y, button)
    if button ~= 1 then return end
    self.isPressed = true
    if self.focusedControl then
        self.focusedControl.focused = nil
    end
    self.focusedControl = nil
    self.pressedControl = nil
    local control, cx, cy, cw, ch = self:getControlAt(x, y, true)
    if control then
        control.focused = true
        self.focusedControl = control
        self.pressedControl = control
        self.pressedControlX = cx
        self.pressedControlY = cy
        self.pressedControlWidth = cw
        self.pressedControlHeight = ch
        if control.type == 'slider' then
            updateSlider(control, x, cx, cy, cw, ch)
        end
        if control.mousepressed then
            control:mousepressed(x, y, button)
        end
        return true
    end
end

function Ui:mousereleased (x, y, button)
    if button ~= 1 then return end
    self.isPressed = false
    local control = self.pressedControl
    self.pressedControl = nil
    if not control then return end
    local c, cx, cy, cw, ch = self:getControlAt(x, y)
    if control == c then
        if control.press then control:press(cx, cy, cw, ch) end
        if control.mode then self.editor:switchMode(control.mode) end
    end
    if control.mousereleased then
        control:mousereleased(x, y, button)
    end
    return true
end

function Ui:mousemoved (x, y)
    local control = self.pressedControl
    if not control then return end
    if control.mousemoved then
        control:mousemoved(x, y)
    end
    if control.type == 'slider' then
        local cx = self.pressedControlX
        local cy = self.pressedControlY
        local cw = self.pressedControlWidth
        local ch = self.pressedControlHeight
        updateSlider(control, x, cx, cy, cw, ch)
        return true
    end
end

function Ui:wheelmoved (x, y)
    local control = self:getControlAt(lm.getPosition())
    if control and control.type == 'slider' then
        local amount = (control:getAmount() or 0) +
            y * (control.step or 0.01)
        control:setAmount(math.min(math.max(
            control.min, amount), control.max))
        return true
    end
end

function Ui:textinput (...)
    local control = self.focusedControl
    if control and control.textinput then
        return control:textinput(...)
    end
end

function Ui:keypressed (...)
    local control = self.focusedControl
    if control and control.keypressed then
        return control:keypressed(...)
    end
end

function Ui:resize (width, height)
    for _, panel in ipairs(self.panels) do
        for i = 1, #panel.controls do
            local control = panel:getControl(i)
            if control.resize then
                control:resize(width, height)
            end
        end
    end
end

function Ui:draw ()
    for _, panel in ipairs(self.panels) do
        for i = 1, #panel.controls do
            local control, x, y, w, h = panel:getControl(i)
            self:drawControl(control, x, y, w, h)
            if control.draw then
                control:draw()
            end
        end
    end
end

return Ui

