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

    local lanes = constants.world_lanes()
    local rng = love.math.random(1, lanes:size())
    local lane_y = lanes[rng]
    projectile_spawn.spawn(
        ecs_world, constants.screen_width() - 50, lane_y, bump_world
    )

    local thrower_entity = ecs_world:entity(constants.id.thrower)
    if rng == 1 then
        nw.system.animation():play_once(
            thrower_entity, animations.thrower.up_throw
        )
    else
        nw.system.animation():play_once(
            thrower_entity, animations.thrower.low_throw
        )
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
    end

    return projectile_spawn.handle_observables(ctx, obs, ...)
end



return projectile_spawn
