local projectile = {}

function projectile.update_multipliers(dt, ecs_world)
    local timer = ecs_world:ensure(
        nw.component.time_before_speedup, constants.id.global
    )

    if not timer:update(dt) then return end
    timer:reset()

    local mul = ecs_world:ensure(
        nw.component.velocity_multiplier,
        constants.id.global
    )
    ecs_world:set(
        nw.component.velocity_multiplier, constants.id.global, mul + 0.25
    )
end

function projectile.set_speed(ecs_world)
    local entity_to_multiply = ecs_world:get_component_table(
        nw.component.base_velocity
    )

    for id, base_velocity in pairs(entity_to_multiply) do
        local velocity_multiplier = ecs_world:ensure(
            nw.component.velocity_multiplier, constants.id.global
        )
        local v = base_velocity * velocity_multiplier
        ecs_world:set(nw.component.velocity, id, v:unpack())
    end
end

function projectile.observables(ctx)
    return {
        update = ctx:listen("update"):collect(),
        collision = ctx:listen("collision"):collect()
    }
end

function projectile.handle_observables(ctx, obs, ecs_world, ...)
    if not ecs_world then return end

    for _, dt in ipairs(obs.update:pop()) do
        projectile.update_multipliers(dt, ecs_world)
        projectile.set_speed(ecs_world)
    end

    return projectile.handle_observables(ctx, obs, ...)
end

return projectile
