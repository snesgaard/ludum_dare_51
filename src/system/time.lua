local Time = {}

function Time.dt(dt, entity)
    local s = entity:get(nw.component.time_scale)
    return s * dt
end

return Time
