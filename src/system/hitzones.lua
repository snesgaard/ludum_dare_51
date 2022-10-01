local hitzones = {}

function hitzones.handle_update(dt, ecs_world)
    local hitzone_activation = ecs_world:get_component_table(
        nw.component.hitzone_activation
    )

    for _, timer in pairs(hitzone_activation) do
        timer:update(dt)
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

function hitzones.handle_collision(colinfo, ecs_world)
    local other_activation = ecs_world:get(
        nw.component.hitzone_activation, colinfo.other
    )
    local item_projectile = ecs_world:get(
        nw.component.projectile, colinfo.item
    )

    if not other_activation or not item_projectile then return end

    if other_activation:done() then return end

    ecs_world:destroy(colinfo.item)
end

function hitzones.observables(ctx)
    return {
        update = ctx:listen("update"):collect(),
        collision = ctx:listen("collision"):collect(),
        keypressed = ctx:listen("keypressed"):collect()
    }
end

function hitzones.handle_observables(ctx, obs, ecs_world, ...)
    if not ecs_world then return end

    for _, dt in ipairs(obs.update:peek()) do
        hitzones.handle_update(dt, ecs_world)
    end

    for _, key in ipairs(obs.keypressed:peek()) do
        hitzones.handle_keypressed(key, ecs_world)
    end

    for _, colinfo in ipairs(obs.collision:peek()) do
        hitzones.handle_collision(colinfo, ecs_world)
    end

    return hitzones.handle_observables(ctx, obs, ...)
end

return hitzones
