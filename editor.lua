local lg = love.graphics
local lk = love.keyboard
local lp = love.physics
local lf = love.filesystem

local Ape = require 'lib.ape'
local Ui = require 'ui'
local Hero = require 'lib.hero'
local Sketchy = require 'lib.sketchy'

local ToolbarControls = require 'controls.toolbar'
local EditorControls = require 'controls.editor'
local WorldControls = require 'controls.world'
local BodyControls = require 'controls.body'
local FixtureControls = require 'controls.fixture'
local JointControls = require 'controls.joint'

local Editor = require 'class' ()

for k, v in pairs(require 'editor.callbacks') do Editor[k] = v end
for k, v in pairs(require 'editor.edit') do Editor[k] = v end
for k, v in pairs(require 'editor.file') do Editor[k] = v end

local ZOOM_DEFAULT = 30

function Editor:init (width, height)
    local editor = self
    
    self.width = width
    self.height = height
    self.world = lp.newWorld()
    self.viewer = Sketchy():setScale(ZOOM_DEFAULT)
    self.pluginManager = Ape(self)
    self.ui = Ui(self)
    
    self.accumulator = 0
    self.shouldUpdate = true
    self.updatesPerSecond = 15
    self.timestep = 1 / self.updatesPerSecond
    self.undoStack = {}
    self.undoStackIndex = 0
    
    self.ui.panels[1] = Ui.Panel(0, 0, 32, 32)
    self.ui.panels[1]:addControls(ToolbarControls())
    self.sidebarPanel = self.ui.panels[1]
    
    self.ui.panels[2] = Ui.Panel(0, 32, 200, 20)
    self.ui.panels[2]:addControls(EditorControls(self))
    self.ui.panels[2]:addControls(WorldControls(self.world))
    self.propertyPanel = self.ui.panels[2]
    
    self.ui.panels[3] = Ui.HorizontalPanel(32, 0, 32, 32)
    self.ui.panels[3]:addControls(require 'controls.topbar' (self))
    self.topbarPanel = self.ui.panels[3]
    
    local drawJoint = self.viewer.drawJoint

    function self.viewer:drawJoint (joint)
        if editor.selectedObject == joint then
            lg.setLineWidth(self.jointLineWidth * 2 / self.scale)
            drawJoint(self, joint)
            local x1, y1, x2, y2 = joint:getAnchors()
            lg.circle('line', x1, y1, 6 / self.scale)
            lg.circle('line', x2, y2, 6 / self.scale)
            lg.setLineWidth(self.jointLineWidth / self.scale)
            return
        end
        drawJoint(self, joint)
    end
    
    local drawContact = self.viewer.drawContact
    
    function self.viewer:drawContact (contact)
        if editor.shouldUpdate then
            drawContact(self, contact)
        end
    end
    
    if not lf.exists('scene') then
        lf.createDirectory('scene')
    end
    local dir = 'plugin'
    if not lf.exists(dir) then
        lf.createDirectory(dir)
    end
    print('Plugins in ' .. lf.getRealDirectory(dir))
    local path ='appdata/' .. dir .. '/'
    local files = lf.getDirectoryItems(path)
    for _, file in ipairs(files) do
        local out = dir .. '/' .. file
        if not lf.exists(out) then
            lf.write(out, lf.read(path .. file))
        end
    end
    local files = lf.getDirectoryItems(dir)
    table.sort(files)
    for _, file in ipairs(files) do
        if file:find('%.lua$') then
            local name = file:gsub('%.lua$', '')
            local path = dir .. '.' .. name
            self.pluginManager:load(path)
        end
    end
    
    self:switchMode 'mode.select'
end

function Editor:selectObject (object)
    local panel = self.propertyPanel
    self.selectedObject = object
    panel:clear()
    panel:addControls(EditorControls(self))
    panel:addControls(WorldControls(self.world))
    if not object then
        return
    elseif object:typeOf('Body') then
        panel:addControls(BodyControls(object))
    elseif object:typeOf('Fixture') then
        panel:addControls(BodyControls(object:getBody()))
        panel:addControls(FixtureControls(object))
    elseif object:typeOf('Joint') then
        panel:addControls(JointControls(object))
        local a, b = object:getBodies()
        a:setAwake(true)
        b:setAwake(true)
    end
    
    return object
end

function Editor:setUpdatesPerSecond (n)
    self.updatesPerSecond = n
    self.timestep = 1 / n
end

function Editor:getUpdatesPerSecond ()
    return self.updatesPerSecond
end

function Editor:screenToWorld (x, y)
    return self.viewer:screenToWorld(x, y)
end

function Editor:worldToScreen (x, y)
    return self.viewer:worldToScreen(x, y)
end

function Editor:switchMode (name)
    if self.mode then
        self.mode:destroy()
    end
    self.mode = require(name)(self)
    self.modeName = name
end

function Editor:getGridDetail ()
    local s = self.viewer.scale
    return s >= 60 and 0.1
        or s >= 6 and 1
        or 10
end

function Editor:getSelectedBody ()
    local object = self.selectedObject
    
    if object and object:typeOf('Body') then
        return object
    end
end

function Editor:pushUndo (message)
    local i = self.undoStackIndex + 1
    local s = self.undoStack
    
    while #s > i do
        s[#s] = nil
    end
    
    local worldState = Hero.save(self.world)
    local selectedId = tostring(self.selectedObject)
    
    s[i] = {
        message = message,
        worldState = worldState,
        selectedId = selectedId,
    }
    
    self.undoStackIndex = i
    
    return i
end

function Editor:pushUndoOnce (message)
    local i = self.undoStackIndex
    local s = self.undoStack
    
    if not s[i] or s[i].message ~= message then
        return self:pushUndo(message)
    end
end

function Editor:try (...)
    local undoStackIndex = self.undoStackIndex
    local undoStack = {}
    for i = 1, #self.undoStack do
        undoStack[i] = self.undoStack[i]
    end
    local success, message = pcall(...)
    if not success then
        self.undoStackIndex = undoStackIndex
        self.undoStack = undoStack
        print('Trapped: ' .. message)
    end
end

return Editor

