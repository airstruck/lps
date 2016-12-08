local Plugin = {}

local function getUserData (object)
    local data = object:getUserData()
    if not data then
        data = {}
        object:setUserData(data)
    end
    if not data.color then
        data.color = { r = 0, g = 0, b = 0 }
    end
    return data
end

local function createControls (fixture)
    return {
        {
            text = 'Shape Color',
            type = 'label',
        },
        {
            text = 'Use Custom Color',
            tip = 'Set whether to use a custom color for this fixture.',
            isSelected = function ()
                local data = fixture:getUserData()
                return data and data.color and data.color.enabled
            end,
            press = function ()
                local data = getUserData(fixture)
                data.color.enabled = not data.color.enabled
            end,
        },
        {
            text = 'Red',
            tip = 'Set the red channel.',
            type = 'slider', min = 0, max = 255, step = 1, format = '%i',
            getAmount = function ()
                return getUserData(fixture).color.r
            end,
            setAmount = function (self, amount)
                getUserData(fixture).color.r = math.floor(amount)
            end,
        },
        {
            text = 'Green',
            tip = 'Set the green channel.',
            type = 'slider', min = 0, max = 255, step = 1, format = '%i',
            getAmount = function ()
                return getUserData(fixture).color.g
            end,
            setAmount = function (self, amount)
                getUserData(fixture).color.g = math.floor(amount)
            end,
        },
        {
            text = 'Blue',
            tip = 'Set the blue channel.',
            type = 'slider', min = 0, max = 255, step = 1, format = '%i',
            getAmount = function ()
                return getUserData(fixture).color.b
            end,
            setAmount = function (self, amount)
                getUserData(fixture).color.b = math.floor(amount)
            end,
        },
    }
end

function Plugin:enable (editor)
    local viewer = editor.viewer
    local drawShape = viewer.drawShape
    
    function viewer:drawShape (shape, fixture)
        local data = fixture:getUserData()
        local color = data and data.color
        if color and color.enabled then
            love.graphics.setColor(color.r, color.g, color.b)
        end
        return drawShape(viewer, shape, fixture)
    end
    
    local selectObject = editor.selectObject
    
    function editor:selectObject (object)
        selectObject(editor, object)
        if object and object:typeOf('Fixture') then
            self.propertyPanel:addControls(createControls(object))
        end
    end

    self.drawShape = drawShape
    self.selectObject = selectObject
    
    editor:selectObject(editor.selectedObject)
end

function Plugin:disable (editor)
    editor.viewer.drawShape = self.drawShape
    editor.selectObject = self.selectObject
    
    editor:selectObject(editor.selectedObject)
end

return Plugin

