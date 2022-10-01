local hitzones = {}

function hitzones.handle_update(ctx, dt, ecs_world)
    local hitzone_activation = ecs_world:get_component_table(
        nw.component.hitzone_activation
    )

    for id, timer in pairs(hitzone_activation) do
        local is_not_done = not timer:done()
        if timer:update(dt) and is_not_done then
            ctx:emit("hitzone_done", id)
        end
    end

end

function hitzones.observables(ctx)
    return {
        update = ctx:listen("update"):collect()
    }
end

function hitzones.handle_observables(ctx, obs, ecs_world, ...)
    if not ecs_world then return end

    for _, dt in ipairs(obs.update:peek()) do
        hitzones.handle_update(ctx, dt, ecs_world)
    end

    return hitzones.handle_observables(ctx, obs, ...)
end

return hitzones
