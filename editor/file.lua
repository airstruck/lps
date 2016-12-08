local lf = love.filesystem

local Hero = require 'lib.hero'
local Serialize = require 'lib.serialize'

local Editor = {}

local function deleteDirectory (item, depth)
    depth = depth or 0
    if lf.isDirectory(item) then
        for _, child in ipairs(lf.getDirectoryItems(item)) do
            deleteDirectory(item .. '/' .. child, depth + 1)
            lf.remove(item .. '/' .. child)
        end
    end
    lf.remove(item)
end

function Editor:saveScene (name)
    local dir = 'scene/' .. name
    if not lf.exists(dir) then
        lf.createDirectory(dir)
    end
    local worldFile = dir .. '/world.lua'
    if lf.exists(worldFile) then
        lf.remove(worldFile)
    end
    lf.write(worldFile, Serialize(Hero.save(self.world)))
    self.currentScene = name
end

function Editor:loadScene (name)
    local dir = 'scene/' .. name
    if not lf.exists(dir) then
        error 'scene not found on disk'
    end
    local worldFile = dir .. '/world.lua'
    if not lf.exists(worldFile) then
        error 'world.lua not found on disk'
    end
    print('Loading ' .. worldFile)
    local worldState = setfenv(lf.load(worldFile), {})()
    self.world = Hero.load(worldState)
    self.currentScene = name
    self:selectObject()
    self.undoStack = {}
    self.undoStackIndex = 0
end

return Editor

