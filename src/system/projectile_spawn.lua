local projectile_spawn = {}

local function despawn_component() return true end

function projectile_spawn.spawn(ecs_world, x, y, bump_world)
    ecs_world:entity()
        :assemble(assemble.projectile, x, y, bump_world)
        :set(despawn_component)
end

function projectile_spawn.handle_update(dt, ecs_world, bump_world)
    local timer = ecs_world:ensure(
        nw.component.timer.create, constants.id.global, 0.5
    )
    local mul = ecs_world:ensure(
        nw.component.velocity_multiplier, constants.id.global
    )
    if not timer:update(dt * mul) then return end
    timer:reset()

    local rng = love.math.random(1, constants.lanes:size())
    local lane_y = constants.lanes[rng]
    projectile_spawn.spawn(ecs_world, constants.screen_width(), lane_y, bump_world)
end

function projectile_spawn.handle_despawn(dt, ecs_world)
    local to_check = ecs_world:get_component_table(despawn_component)
    for id, _ in pairs(to_check) do
        local p = ecs_world:ensure(nw.component.position, id)
        if p.x < -50 then ecs_world:destroy(id) end
    end
end

function projectile_spawn.observables(ctx)
    return {
        update = ctx:listen("update"):collect(),
        bump_world = ctx:from_cache("bump_world"):latest()
    }
end

function projectile_spawn.handle_observables(ctx, obs, ecs_world, ...)
    if not ecs_world then return end

    for _, dt in ipairs(obs.update:peek()) do
        projectile_spawn.handle_update(dt, ecs_world, obs.bump_world:peek())
        projectile_spawn.handle_despawn(dt, ecs_world)
    end

    return projectile_spawn.handle_observables(ctx, obs, ...)
end



return projectile_spawn
