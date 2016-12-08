return function (world)
    return {
        {
            text = 'World Properties',
            type = 'label',
        },
        {
            text = 'Sleeping Allowed',
            tip = 'Set whether bodies are allowed to sleep.',
            isSelected = function ()
                return world:isSleepingAllowed()
            end,
            press = function ()
                world:setSleepingAllowed(not world:isSleepingAllowed())
            end,
        },
        {
            text = 'Gravity X',
            tip = 'Set the X component of gravity, in m/s².',
            type = 'slider', min = -100, max = 100, step = 0.1,
            getAmount = function ()
                local gx, gy = world:getGravity()
                return gx
            end,
            setAmount = function (self, amount)
                local gx, gy = world:getGravity()
                world:setGravity(amount, gy)
            end,
        },
        {
            text = 'Gravity Y',
            tip = 'Set the Y component of gravity, in m/s².',
            type = 'slider', min = -100, max = 100, step = 0.1,
            getAmount = function ()
                local gx, gy = world:getGravity()
                return gy
            end,
            setAmount = function (self, amount)
                local gx, gy = world:getGravity()
                world:setGravity(gx, amount)
            end,
        },
    }
end

