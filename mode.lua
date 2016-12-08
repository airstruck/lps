local lk = love.keyboard

local JOINT_SELECT_SLOP = 4 -- max distance a joint can be selected from

local Mode = require 'class' ()

function Mode:init (editor)
    self.editor = editor
end

function Mode:destroy ()
end

function Mode:keypressed ()
end

function Mode:textentered ()
end

function Mode:mousepressed ()
end

function Mode:mousereleased ()
end

function Mode:mousemoved ()
end

function Mode:wheelmoved ()
end

function Mode:draw ()
end

function Mode:resize ()
end

function Mode:screenToWorld (x, y)
    return self.editor:screenToWorld(x, y)
end

function Mode:getBodyAtPoint (x, y)
    local fixture = self:getFixtureAtPoint(x, y)
    if fixture then
        return fixture:getBody()
    end
end

function Mode:getFixtureAtPoint (x, y)
    local a, b, c
    
    self.editor.world:queryBoundingBox(
        x, y, x, y,
        function (fixture)
            if fixture:testPoint(x, y) then
                a = fixture
                return false
            end
            if not b then
                for i = 1, fixture:getShape():getChildCount() do
                    local x1, y1, x2, y2 = fixture:getBoundingBox(i)
                    if x >= x1 - 0.01 and x <= x2 + 0.01
                    and y >= y1 - 0.01 and y <= y2 + 0.01 then
                        b = fixture
                    end
                end
            end
            if not c then
                c = fixture
            end
            return true
        end)
        
    return a or b -- or c
end

local function distanceToSegment (pX, pY, sX1, sY1, sX2, sY2)
    local xl, yl = sX2 - sX1, sY2 - sY1
    local l2 = xl ^ 2 + yl ^ 2
    local xd, yd = pX - sX1, pY - sY1
    if l2 == 0 then return math.sqrt(xd ^ 2 + yd ^ 2) end
    local u = math.max(0, math.min(1, (xd * xl + yd * yl) / l2))
    return math.sqrt((pX - (sX1 + u * xl)) ^ 2 + (pY - (sY1 + u * yl)) ^ 2)
end

function Mode:getJointAtPoint (x, y)
    local editor = self.editor
    local viewer = editor.viewer
    
    for i, joint in ipairs(editor.world:getJointList()) do
        local ax, ay, bx, by = joint:getAnchors()
        local maxDistance = JOINT_SELECT_SLOP / viewer.scale
        local jointType = joint:getType()
        -- pulley joints have 3 segments to check
        if jointType == 'pulley' then
            local cx, cy, dx, dy = joint:getGroundAnchors()
            if distanceToSegment(x, y, cx, cy, dx, dy) < maxDistance
            or distanceToSegment(x, y, ax, ay, cx, cy) < maxDistance
            or distanceToSegment(x, y, bx, by, dx, dy) < maxDistance then
                return joint
            end
        -- other joints have 1 segment
        else
            if distanceToSegment(x, y, ax, ay, bx, by) < maxDistance then
                return joint
            end
        end
    end
end

function Mode:selectObjectAtPoint (x, y)
    local joint = self:getJointAtPoint(x, y)
    local fixture = self:getFixtureAtPoint(x, y)
    if joint then
        self.editor:selectObject(joint)
        return fixture and fixture:getBody()
    end
    if fixture then
        local body = fixture:getBody()
        if lk.isDown('lctrl', 'rctrl') then
            self.editor:selectObject(body)
        else
            self.editor:selectObject(fixture)
        end
        return body
    end
    self.editor:selectObject()
end

function Mode:try (...)
    return self.editor:try(...)
end

return Mode

