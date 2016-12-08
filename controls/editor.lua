return function (editor)
    return {
        {
            text = 'Editor Properties',
            type = 'label',
        },
        {
            text = 'Run Simulation',
            tip = 'Run or pause the simulation.',
            isSelected = function ()
                return editor.shouldUpdate
            end,
            press = function ()
                editor.shouldUpdate = not editor.shouldUpdate
            end,
        },
        {
            text = 'Updates Per Second',
            tip = 'Set the number of updates per second.',
            type = 'slider', min = 1, max = 100, step = 1, format = '%i',
            getAmount = function ()
                return editor:getUpdatesPerSecond()
            end,
            setAmount = function (self, amount)
                editor:setUpdatesPerSecond(math.floor(amount))
            end,
        },
    }
end

