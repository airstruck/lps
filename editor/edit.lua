local lp = love.physics

local Hero = require 'lib.hero'

local Editor = {}

function Editor:undo ()
    local s = self.undoStack
    local i = self.undoStackIndex
    if i > 0 then
        if #s == i then
            self:pushUndo('Current State')
        end
        self.undoStackIndex = i - 1
        local world, lookup = Hero.load(s[i].worldState)
        self.world = world
        self:selectObject(lookup[s[i].selectedId])
    end
end

function Editor:redo ()
    local s = self.undoStack
    local i = self.undoStackIndex + 1
    if i < #s then
        self.undoStackIndex = i
        local world, lookup = Hero.load(s[i + 1].worldState)
        self.world = world
        self:selectObject(lookup[s[i + 1].selectedId])
    end
end

function Editor:destroyObject (object)
    if object:typeOf('Fixture') then
        local body = object:getBody()
        if #body:getFixtureList() < 2 then
            body:destroy()
        else
            object:destroy()
        end
    else
        object:destroy()
    end
end

function Editor:delete ()
    local object = self.selectedObject
    if object then
        self:pushUndo('Delete Object')
        self:destroyObject(object)
        self:selectObject()
    end
end

function Editor:cut ()
    local object = self.selectedObject
    if object then
        self:pushUndo('Cut Object')
        self:copy()
        self:destroyObject(object)
        self:selectObject()
    end
end

function Editor:copy ()
    local object = self.selectedObject
    if not object then return false end
    if object:typeOf('Body') then
        self.clipboard = {
            body = Hero.BodyState(object),
        }
    elseif object:typeOf('Fixture') then
        self.clipboard = {
            body = Hero.BodyState(object:getBody()),
            fixture = Hero.FixtureState(object),
        }
    end
end

function Editor:paste (x, y)
    local cb = self.clipboard
    if not cb then return end
    
    self:pushUndo('Paste Object')
    
    if not x then
        x, y = love.mouse.getPosition()
    end
    if cb.fixture then
        local wx, wy = self:screenToWorld(x, y)
        local bodyType = cb.body and cb.body.type or 'dynamic'
        local body = lp.newBody(self.world, wx, wy, bodyType)
        local fixture = Hero.Fixture(cb.fixture, body)
        self:selectObject(fixture)
    elseif cb.body then
        cb.body.x, cb.body.y = self:screenToWorld(x, y)
        local body = Hero.Body(cb.body, self.world)
        self:selectObject(body)
    end
end

return Editor

