return function (fixture)
    return {
        {
            text = 'Fixture Properties',
            type = 'label',
        },
        {
            text = 'Density',
            tip = 'Set the density; contributes to body mass.',
            type = 'slider', min = 0, max = 10, step = 0.01,
            getAmount = function ()
                return fixture:getDensity()
            end,
            setAmount = function (self, amount)
                fixture:setDensity(amount)
                fixture:getBody():resetMassData()
            end,
        },
        {
            text = 'Friction',
            tip = 'Set the friction, or slipperyness/roughness.',
            type = 'slider', min = 0, max = 1, step = 0.01,
            getAmount = function ()
                return fixture:getFriction()
            end,
            setAmount = function (self, amount)
                fixture:setFriction(amount)
            end,
        },
        {
            text = 'Restitution',
            tip = 'Set the restitution, or bouncyness.',
            type = 'slider', min = 0, max = 1, step = 0.01,
            getAmount = function ()
                return fixture:getRestitution()
            end,
            setAmount = function (self, amount)
                fixture:setRestitution(amount)
            end,
        },
    }
end

