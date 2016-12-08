return function ()
    return {
        { mode = 'mode.select', tip = 'Interact with objects' },
        
        { mode = 'mode.shape.circle', tip = 'Create circle' },
        { mode = 'mode.shape.rectangle', tip = 'Create rectangle' },
        { mode = 'mode.shape.polygon', tip = 'Create polygon' },
        { mode = 'mode.shape.edge', tip = 'Create edge' },
        { mode = 'mode.shape.chain', tip = 'Create chain' },
        
        { mode = 'mode.joint.distance', tip = 'Create distance joint' },
        { mode = 'mode.joint.friction', tip = 'Create friction joint' },
        --{ mode = 'mode.joint.gear', tip = 'Create gear joint' },
        { mode = 'mode.joint.motor', tip = 'Create motor joint' },
        --{ mode = 'mode.joint.mouse', tip = 'Create mouse joint' },
        { mode = 'mode.joint.prismatic', tip = 'Create prismatic joint' },
        { mode = 'mode.joint.pulley', tip = 'Create pulley joint' },
        { mode = 'mode.joint.revolute', tip = 'Create revolute joint' },
        { mode = 'mode.joint.rope', tip = 'Create rope joint' },
        { mode = 'mode.joint.weld', tip = 'Create weld joint' },
        { mode = 'mode.joint.wheel', tip = 'Create wheel joint' },
    }
end

