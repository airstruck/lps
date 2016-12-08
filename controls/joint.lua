local PI2 = math.pi * 2

local function DampingRatio (joint, isSpring)
    return {
        text = 'Damping Ratio',
        tip = 'Set the damping ratio.',
        type = 'slider', min = 0, max = 1, step = 0.01,
        getAmount = isSpring and
            function ()
                return joint:getSpringDampingRatio()
            end
            or function ()
                return joint:getDampingRatio()
            end,
        setAmount = isSpring and
            function (self, amount)
                joint:setSpringDampingRatio(amount)
            end
            or function (self, amount)
                joint:setDampingRatio(amount)
            end,
    }
end

local function Frequency (joint, isSpring)
    return {
        text = 'Frequency',
        tip = 'Set the response speed, in Hertz.',
        type = 'slider', min = 0, max = 10, step = 0.01,
        getAmount = isSpring and
            function ()
                return joint:getSpringFrequency()
            end
            or function ()
                return joint:getFrequency()
            end,
        setAmount = isSpring and
            function (self, amount)
                joint:setSpringFrequency(amount)
            end
            or function (self, amount)
                joint:setFrequency(amount)
            end,
    }
end

local function MaxForce (joint)
    return {
        text = 'Max Force',
        tip = 'Set the maximum force, in Newtons.',
        type = 'slider', min = 0, max = 1000, step = 1, format = '%i',
        getAmount = function ()
            return joint:getMaxForce()
        end,
        setAmount = function (self, amount)
            joint:setMaxForce(amount)
        end,
    }
end

local function MaxTorque (joint)
    return {
        text = 'Max Torque',
        tip = 'Set the maximum torque, in Newton meters.',
        type = 'slider', min = 0, max = 1000, step = 1, format = '%i',
        getAmount = function ()
            return joint:getMaxTorque()
        end,
        setAmount = function (self, amount)
            joint:setMaxTorque(amount)
        end,
    }
end

local function MaxMotorTorque (joint)
    return {
        text = 'Max Motor Torque',
        tip = 'Set the maximum motor torque, in Newton meters.',
        type = 'slider', min = 0, max = 1000, step = 0.01,
        getAmount = function ()
            return joint:getMaxMotorTorque()
        end,
        setAmount = function (self, amount)
            joint:setMaxMotorTorque(amount)
        end,
    }
end

local function MotorEnabled (joint)
    return {
        text = 'Motor Enabled',
        tip = 'Set whether the motor is enabled.',
        isSelected = function ()
            return joint:isMotorEnabled()
        end,
        press = function ()
            joint:setMotorEnabled(not joint:isMotorEnabled())
        end,
    }
end

local function MotorSpeed (joint, isRadians)
    return {
        text = 'Motor Speed',
        tip = ('Set the motor speed, in %s per second.')
            :format(isRadians and 'radians' or 'meters'),
        type = 'slider', min = -1000, max = 1000, step = 0.01,
        getAmount = function ()
            return joint:getMotorSpeed()
        end,
        setAmount = function (self, amount)
            joint:setMotorSpeed(amount)
        end,
    }
end

local function LimitsEnabled (joint)
    return {
        text = 'Limits Enabled',
        tip = 'Set whether the limits are enabled.',
        isSelected = function ()
            return joint:hasLimitsEnabled()
        end,
        press = function ()
            joint:setLimitsEnabled(not joint:hasLimitsEnabled())
        end,
    }
end

local function DistanceJoint (joint)
    return {
        {
            text = 'Distance Joint Properties',
            type = 'label',
        },
        DampingRatio(joint),
        Frequency(joint),
        {
            text = 'Length',
            tip = 'Set the length.',
            type = 'slider', min = 0, max = 100, step = 0.01,
            getAmount = function ()
                return joint:getLength()
            end,
            setAmount = function (self, amount)
                joint:setLength(amount)
            end,
        },
    }
end

local function FrictionJoint (joint)
    return {
        {
            text = 'Friction Joint Properties',
            type = 'label',
        },
        MaxForce(joint),
        MaxTorque(joint),
    }
end

local function MotorJoint (joint)
    return {
        {
            text = 'Motor Joint Properties',
            type = 'label',
        },
        {
            text = 'Correction Factor',
            tip = 'Set the correction factor.',
            type = 'slider', min = 0, max = 1, step = 0.01,
            getAmount = function ()
                return joint:getCorrectionFactor()
            end,
            setAmount = function (self, amount)
                joint:setCorrectionFactor(amount)
            end,
        },
        {
            text = 'Angular Offset',
            tip = 'Set the angular offset, in radians.',
            type = 'slider', min = -PI2, max = PI2, step = 0.01,
            getAmount = function ()
                return joint:getAngularOffset()
            end,
            setAmount = function (self, amount)
                joint:setAngularOffset(amount)
            end,
        },
        {
            text = 'Linear Offset X',
            tip = 'Set the linear offset X component, in meters.',
            type = 'slider', min = -100, max = 100, step = 0.1,
            getAmount = function ()
                local x, y = joint:getLinearOffset()
                return x
            end,
            setAmount = function (self, amount)
                local x, y = joint:getLinearOffset()
                joint:setLinearOffset(amount, y)
            end,
        },
        {
            text = 'Linear Offset Y',
            tip = 'Set the linear offset Y component, in meters.',
            type = 'slider', min = -100, max = 100, step = 0.1,
            getAmount = function ()
                local x, y = joint:getLinearOffset()
                return y
            end,
            setAmount = function (self, amount)
                local x, y = joint:getLinearOffset()
                joint:setLinearOffset(x, amount)
            end,
        },
        MaxForce(joint),
        MaxTorque(joint),
    }
end

local function PrismaticJoint (joint)
    return {
        {
            text = 'Prismatic Joint Properties',
            type = 'label',
        },
        LimitsEnabled(joint),
        {
            text = 'Lower Limit',
            tip = 'Set the lower limit, in meters.',
            type = 'slider', min = 0, max = 100,
            getAmount = function ()
                return joint:getLowerLimit()
            end,
            setAmount = function (self, amount)
                local upper = joint:getUpperLimit()
                joint:setLimits(math.min(amount, upper), upper)
            end,
        },
        {
            text = 'Upper Limit',
            tip = 'Set the upper limit, in meters.',
            type = 'slider', min = 0, max = 100,
            getAmount = function ()
                return joint:getUpperLimit()
            end,
            setAmount = function (self, amount)
                local lower = joint:getLowerLimit()
                joint:setLimits(lower, math.max(amount, lower))
            end,
        },
        MotorEnabled(joint),
        MotorSpeed(joint),
        {
            text = 'Max Motor Force',
            tip = 'Set the maximum motor force, in Newtons.',
            type = 'slider', min = 0, max = 1000, step = 1,
            getAmount = function ()
                return joint:getMaxMotorForce()
            end,
            setAmount = function (self, amount)
                joint:setMaxMotorForce(amount)
            end,
        },
    }
end

local function PulleyJoint (joint)
    return {
        {
            text = 'Pulley Joint Properties',
            type = 'label',
        },
        {
            text = '(no properties)',
        },
    }
end
	
local function RevoluteJoint (joint)
    return {
        {
            text = 'Revolute Joint Properties',
            type = 'label',
        },
        LimitsEnabled(joint),
        {
            text = 'Lower Limit',
            tip = 'Set the lower limit, in radians.',
            type = 'slider', min = -PI2, max = PI2, step = 0.01,
            getAmount = function ()
                return joint:getLowerLimit()
            end,
            setAmount = function (self, amount)
                local upper = joint:getUpperLimit()
                joint:setLimits(math.min(amount, upper), upper)
            end,
        },
        {
            text = 'Upper Limit',
            tip = 'Set the upper limit, in radians.',
            type = 'slider', min = -PI2, max = PI2, step = 0.01,
            getAmount = function ()
                return joint:getUpperLimit()
            end,
            setAmount = function (self, amount)
                local lower = joint:getLowerLimit()
                joint:setLimits(lower, math.max(amount, lower))
            end,
        },
        MotorEnabled(joint),
        MotorSpeed(joint),
        MaxMotorTorque(joint),
    }
end

local function RopeJoint (joint)
    return {
        {
            text = 'Rope Joint Properties',
            type = 'label',
        },
        {
            text = '(no properties)',
        },
    }
end

local function WeldJoint (joint)
    return {
        {
            text = 'Weld Joint Properties',
            type = 'label',
        },
        DampingRatio(joint),
        Frequency(joint),
    }
end

local function WheelJoint (joint)
    return {
        {
            text = 'Wheel Joint Properties',
            type = 'label',
        },
        MotorEnabled(joint),
        MotorSpeed(joint),
        MaxMotorTorque(joint),
        DampingRatio(joint, true),
        Frequency(joint, true),
    }
end

local jointByType = {
    distance = DistanceJoint, 
    friction = FrictionJoint,
    gear = GearJoint,
    motor = MotorJoint,
    mouse = MouseJoint,
    prismatic = PrismaticJoint,
    pulley = PulleyJoint,
    revolute = RevoluteJoint,
    rope = RopeJoint,
    weld = WeldJoint,
    wheel = WheelJoint,
}

return function (joint)
    local f = jointByType[joint:getType()]
    return f and f(joint) or {}
end

