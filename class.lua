return function (super)
    local meta = { __index = {} }
    return setmetatable(meta.__index, {
        __call = function (_, ...)
            local instance = setmetatable({}, meta)
            if instance.init then
                instance:init(...)
            end
            return instance
        end,
        __index = super
    })
end

