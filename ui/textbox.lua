local utf8 = require 'utf8'

local defaultHighlight = { 0x80, 0x80, 0xff, 0x80 }
    
local function getRectangle (self)
    return self.x, self.y, self.width, self.height
end

local function setValue (self, value)
    local oldValue = self.value
    if oldValue == value then return end
    self.value = value
    self:changed(value, oldValue)
end

-- make sure selection range doesn't extend past EOT
local function trimRange (self)
    local max = #self.value
    if self.startIndex > max then self.startIndex = max end
    if self.endIndex > max then self.endIndex = max end
end

local function updateHighlight (self)
    local value = self.value
    local font = love.graphics.getFont()
    local startIndex, endIndex = self.startIndex, self.endIndex
    local offset = self.x - self.scrollX
    self.startX = font:getWidth(value:sub(1, startIndex)) + offset
    self.endX = font:getWidth(value:sub(1, endIndex)) + offset
end

local function scrollToCaret (self)
    updateHighlight(self)
    local x1, y1, w, h = getRectangle(self)
    local x2, y2 = x1 + w, y1 + h
    local oldX = self.endX or x1

    if oldX <= x1 then
        self.scrollX = self.scrollX - (x1 - oldX)
        updateHighlight(self)
    elseif oldX >= x2 then
        self.scrollX = self.scrollX + (oldX - x2 + 1)
        updateHighlight(self)
    end
end

local function selectRange (self, startIndex, endIndex)
    if startIndex then self.startIndex = startIndex end
    if endIndex then self.endIndex = endIndex end
    trimRange(self)

    scrollToCaret(self)
end

-- return caret index
local function findIndexFromPoint (self, x, y)
    local x1 = self.x

    local font = love.graphics.getFont()
    local width = 0
    local lastPosition = 0

    local function checkPosition (position)
        local text = self.value:sub(1, position - 1)
        width = font:getWidth(text)
        if width > x + self.scrollX - x1 then
            if position == 1 then
                return 0
            end
            return lastPosition
        end
        lastPosition = position - 1
    end

    for position in utf8.codes(self.value) do
        local index = checkPosition(position)
        if index then return index end
    end

    local index = checkPosition(#self.value + 1)
    if index then return index end

    return #self.value
end

-- move the caret or end of selection range one character to the left
local function moveCharLeft (self, alterRange)
    trimRange(self)
    local text, endIndex = self.value, self.endIndex

    -- clamp caret to beginning
    if endIndex < 1 then endIndex = 1 end

    -- move left
    local index = (utf8.offset(text, -1, endIndex + 1) or 0) - 1
    selectRange(self, not alterRange and index, index)
end

-- move caret or end of selection range one word to the left
local function moveWordLeft (self, alterRange)
    trimRange(self)
    local text = self.value:sub(1, self.endIndex)
    local pos = text:find('%s[^%s]+%s*$') or 0
    selectRange(self, not alterRange and pos, pos)
end

-- move the caret or end of selection range to the beginning of the line
local function moveLineLeft (self, alterRange)
    trimRange(self)
    selectRange(self, not alterRange and 0, 0)
end

-- move caret or end of selection range one character to the right
local function moveCharRight (self, alterRange)
    trimRange(self)
    local text, endIndex = self.value, self.endIndex

    -- clamp caret to end
    if endIndex >= #text then endIndex = #text - 1 end

    -- move right
    local index = (utf8.offset(text, 2, endIndex + 1) or #text) - 1
    selectRange(self, not alterRange and index, index)
end

-- move caret or end of selection range one word to the right
local function moveWordRight (self, alterRange)
    trimRange(self)
    local text = self.value
    local _, pos = text:find('^%s*[^%s]+', self.endIndex + 1)
    pos = pos or #text + 1
    selectRange(self, not alterRange and pos, pos)
end

-- move caret or end of selection range to the end of the line
local function moveLineRight (self, alterRange)
    trimRange(self)
    local text = self.value
    selectRange(self, not alterRange and #text, #text)
end

local function getRange (self)
    trimRange(self)
    if self.startIndex <= self.endIndex then
        return self.startIndex, self.endIndex
    end

    return self.endIndex, self.startIndex
end

local function deleteRange (self)
    trimRange(self)
    local text = self.value
    local first, last = getRange(self)

    -- if expanded range is selected, delete text in range
    if first ~= last then
        local left = text:sub(1, first)
        local index = #left
        setValue(self, left .. text:sub(last + 1))
        selectRange(self, index, index)
        return true
    end
end

local function deleteCharacterLeft (self)
    trimRange(self)
    local text = self.value
    local first, last = getRange(self)

    -- if cursor is at beginning, do nothing
    if first < 1 then
        return
    end

    -- delete character to the left
    local offset = utf8.offset(text, -1, last + 1) or 0
    local left = text:sub(1, offset - 1)
    local index = #left
    setValue(self, left .. text:sub(first + 1))
    selectRange(self, index, index)
end

local function deleteCharacterRight (self)
    trimRange(self)
    local text = self.value
    local first, last = getRange(self)

    -- if cursor is at end, do nothing
    if first == #text then
        return
    end

    -- delete character to the right
    local offset = utf8.offset(text, 2, last + 1) or 0
    local left = text:sub(1, first)
    local index = #left
    setValue(self, left .. text:sub(offset))
    selectRange(self, index, index)
end

local function copyRangeToClipboard (self)
    trimRange(self)
    local text = self.value
    local first, last = getRange(self)
    if last >= first + 1 then
        love.system.setClipboardText(text:sub(first + 1, last))
    end
end

local function pasteFromClipboard (self)
    trimRange(self)
    local text = self.value
    local pasted = love.system.getClipboardText() or ''
    local first, last = getRange(self)
    local left = text:sub(1, first) .. pasted
    local index = #left
    setValue(self, left .. text:sub(last + 1))
    selectRange(self, index, index)
end

local function insertText (self, newText)
    trimRange(self)
    local text = self.value
    local first, last = getRange(self)
    local left = text:sub(1, first) .. newText
    local index = #left
    setValue(self, left .. text:sub(last + 1))
    selectRange(self, index, index)
end

local function isShiftPressed ()
    return love.keyboard.isDown('lshift', 'rshift')
end

-- check command (gui) key, only on Mac.
local isCommandPressed
if IS_MAC then
    isCommandPressed = function ()
        return love.keyboard.isDown('lgui', 'rgui')
    end
else
    isCommandPressed = function ()
        return false
    end
end

-- check command (gui) key on Mac and ctrl key everywhere else.
local isCommandOrCtrlPressed
if IS_MAC then
    isCommandOrCtrlPressed = function ()
        return love.keyboard.isDown('lgui', 'rgui')
    end
else
    isCommandOrCtrlPressed = function ()
        return love.keyboard.isDown('lctrl', 'rctrl')
    end
end

-- check option (alt) key on Mac and ctrl key everywhere else.
local isOptionOrCtrlPressed
if IS_MAC then
    isOptionOrCtrlPressed = function ()
        return love.keyboard.isDown('lalt', 'ralt')
    end
else
    isOptionOrCtrlPressed = function ()
        return love.keyboard.isDown('lctrl', 'rctrl')
    end
end

-- Special keys.
local function createDefaultKeyActions (self)
    return {
        ['tab'] = function ()
            return false
        end,
        ['return'] = function ()
            self:returned(self.value)
        end,
        ['backspace'] = function ()
            if isOptionOrCtrlPressed() then
                moveWordLeft(self, true)
            end
            if not deleteRange(self) then
                deleteCharacterLeft(self)
            end
        end,
        ['delete'] = function ()
            if isOptionOrCtrlPressed() then
                moveWordRight(self, true)
            end
            if not deleteRange(self) then
                deleteCharacterRight(self)
            end
        end,
        ['left'] = function ()
            if isOptionOrCtrlPressed() then
                moveWordLeft(self, isShiftPressed())
            elseif isCommandPressed() then
                moveLineLeft(self, isShiftPressed())
            else
                moveCharLeft(self, isShiftPressed())
            end
        end,
        ['right'] = function ()
            if isOptionOrCtrlPressed() then
                moveWordRight(self, isShiftPressed())
            elseif isCommandPressed() then
                moveLineRight(self, isShiftPressed())
            else
                moveCharRight(self, isShiftPressed())
            end
        end,
        ['home'] = function ()
            moveLineLeft(self, isShiftPressed())
        end,
        ['end'] = function ()
            moveLineRight(self, isShiftPressed())
        end,
        ['x'] = function ()
            if isCommandOrCtrlPressed() then
                copyRangeToClipboard(self)
                deleteRange(self)
            end
        end,
        ['c'] = function ()
            if isCommandOrCtrlPressed() then
                copyRangeToClipboard(self)
            end
        end,
        ['v'] = function ()
            if isCommandOrCtrlPressed() then
                pasteFromClipboard(self)
            end
        end,
        ['a'] = function ()
            if isCommandOrCtrlPressed() then
                selectRange(self, 0, #self.value)
            end
        end,
    }
end

local textInputKeys = {
    ['space'] = true,
    ['return'] = true,
    ['kp00'] = true,
    ['kp000'] = true,
    ['kp&&'] = true,
    ['kp||'] = true,
}

local function isKeyTextInput (key)
    if textInputKeys[key] or #key == 1
    or (#key == 3 and key:sub(1, 2) == "kp") then
        return not love.keyboard.isDown(
            'lalt', 'ralt', 'lctrl', 'rctrl', 'lgui', 'rgui')
    end
    return false
end

-- callbacks

local function draw (self)

    if self.needsUpdate then
        updateHighlight(self)
    end
    
    local startX, endX = self.startX, self.endX
    local x, y, w, h = getRectangle(self)
    local width, height = endX - startX, h
    local font = love.graphics.getFont()
    local color = self.color or { 0, 0, 0, 255 }
    local textTop = math.floor(y + (h - font:getHeight()) / 2)

    love.graphics.push('all')
    love.graphics.intersectScissor(x, y, w, h)
    -- love.graphics.setFont(font)

    if self.focused then
        -- draw highlighted selection
        love.graphics.setColor(self.highlight or defaultHighlight)
        love.graphics.rectangle('fill', startX, y, width, height)
        -- draw cursor selection
        if love.timer.getTime() % 2 < 1.75 then
            love.graphics.setColor(color)
            love.graphics.rectangle('fill', endX, y, 1, height)
        end
    else
        love.graphics.setColor { color[1], color[2], color[3],
            (color[4] or 256) / 8 }
        love.graphics.rectangle('fill', startX, y, width, height)
    end

    -- draw text
    love.graphics.setColor(color)
    love.graphics.print(self.value, x - self.scrollX, textTop)

    love.graphics.pop()
end

local function mousepressed (self, x, y, button)
    if button ~= 1 then return end
    self.isDragging = true
    self.startIndex = findIndexFromPoint(self, x)
    self.endIndex = self.startIndex
    scrollToCaret(self)
end

local function mousemoved (self, x, y)
    if not self.isDragging then return end
    self.endIndex = findIndexFromPoint(self, x)
    scrollToCaret(self)
end

local function mousereleased (self, x, y)
    if button ~= 1 then return end
    self.isDragging = false
end

local function textinput (self, text)
    insertText(self, text)
end

local function keypressed (self, key)
    local act = self.keyActions[key]
    if act then
        local result = act()
        return result == nil and true or result
    end
    return isKeyTextInput(key)
end

local function resize (self, width, height)
    self.needsUpdate = true
end

local function nothing () end

return function (t)
    t = t or {}
    
    t.x = x or 0
    t.y = y or 0
    t.width = t.width or 128
    t.height = t.height or 32
    t.startIndex, t.endIndex = 0, 0
    t.startX, t.endX = -1, -1
    t.scrollX = 0
    t.value = t.value or ''
    t.keyActions = createDefaultKeyActions(t)
    
    t.type = 'textbox'
    t.draw = draw
    t.mousepressed = mousepressed
    t.mousemoved = mousemoved
    t.mousereleased = mousereleased
    t.keypressed = keypressed
    t.textinput = textinput
    t.resize = resize
    
    t.changed = t.changed or nothing
    t.returned = t.returned or nothing
    
    return t
end
