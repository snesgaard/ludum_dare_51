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

function hitzones.handle_keypressed(key, ecs_world)
    local index_from_key = {up = 1, down = 2}
    local index = index_from_key[key]
    if not index then return end
    local id = constants.id.hitzones[index]
    if not id then return end
    ecs_world:set(nw.component.hitzone_activation, id)
end

function hitzones.observables(ctx)
    return {
        update = ctx:listen("update"):collect(),
        keypressed = ctx:listen("keypressed"):collect()
    }
end

function hitzones.handle_observables(ctx, obs, ecs_world, ...)
    if not ecs_world then return end

    for _, dt in ipairs(obs.update:peek()) do
        hitzones.handle_update(ctx, dt, ecs_world)
    end

    for _, key in ipairs(obs.keypressed:peek()) do
        hitzones.handle_keypressed(key, ecs_world)
    end

    return hitzones.handle_observables(ctx, obs, ...)
end

return hitzones
