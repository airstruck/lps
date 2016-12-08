return function (body)
    return {
        {
            text = 'Body Properties',
            type = 'label',
        },
        {
            text = 'Awake',
            tip = 'Set whether the body is awake.',
            isSelected = function ()
                return body:isAwake()
            end,
            press = function ()
                body:setAwake(not body:isAwake())
            end,
        },
        {
            text = 'Type',
            tip = 'Change the body type.',
            press = function ()
                local bodyType = body:getType()
                if bodyType == 'dynamic' then
                    body:setType('kinematic')
                elseif bodyType == 'kinematic' then
                    body:setType('static')
                elseif bodyType == 'static' then
                    body:setType('dynamic')
                end
            end,
            getValue = function ()
                return body:getType()
            end,
        },
        {
            text = 'Bullet',
            tip = 'Set the bullet status of a body.',
            isSelected = function ()
                return body:isBullet()
            end,
            press = function ()
                body:setBullet(not body:isBullet())
            end,
        },
        {
            text = 'Fixed Rotation',
            tip = 'Set whether the body rotation is locked.',
            isSelected = function ()
                return body:isFixedRotation()
            end,
            press = function ()
                body:setFixedRotation(not body:isFixedRotation())
            end,
        },
        {
            text = 'Angular Damping',
            tip = 'Set rate of decrease of angular velocity over time.',
            type = 'slider', min = 0, max = 1, step = 0.01,
            getAmount = function ()
                return body:getAngularDamping()
            end,
            setAmount = function (self, amount)
                body:setAngularDamping(amount)
            end,
        },
        {
            text = 'Linear Damping',
            tip = 'Set rate of decrease of linear velocity over time.',
            type = 'slider', min = 0, max = 1, step = 0.01,
            getAmount = function ()
                return body:getLinearDamping()
            end,
            setAmount = function (self, amount)
                body:setLinearDamping(amount)
            end,
        },
        {
            text = 'Gravity Scale',
            tip = 'The gravity scale factor.',
            type = 'slider', min = 0, max = 10, step = 0.01,
            getAmount = function ()
                return body:getGravityScale()
            end,
            setAmount = function (self, amount)
                body:setGravityScale(amount)
            end,
        },
    }
end


