local painter = require "painter"

local phases = {
    countdown = require "scene.countdown"
}

local collision_class = nw.system.collision():class()

function collision_class.default_filter()
    return "cross"
end

local function countdown(ctx, ecs_world)
    local draw = ctx:listen("draw"):collect()
end

local function baseball(ctx)
    local ecs_world = nw.ecs.entity.create()
    local bump_world = nw.third.bump.newWorld()

    local lanes = constants:world_lanes()

    local hitzones = {
        constants.upper_swing_box(),
        constants.lower_swing_box()
    }

    for index, id in ipairs(constants.id.hitzones) do
        local y = constants.actor_floor()
        local x = constants.player_position().x
        local hb = hitzones[index]
        ecs_world:entity(id)
            :assemble(assemble.hitzone, x, y, hb, bump_world)
    end

    ecs_world:entity(constants.id.miss_zone)
        :assemble(assemble.miss_zone, bump_world)

    local scene_bound = spatial(
        0, 0, constants:screen_width(), constants:screen_height()
    ):expand(10, 10)

    ecs_world:set(nw.component.health, constants.id.global, 3)

    ecs_world:entity()
        :assemble(assemble.negation_zone, scene_bound:up(), bump_world)
    ecs_world:entity()
        :assemble(assemble.negation_zone, scene_bound:down(), bump_world)
    ecs_world:entity()
        :assemble(assemble.negation_zone, scene_bound:left(), bump_world)
    ecs_world:entity()
        :assemble(assemble.negation_zone, scene_bound:right(), bump_world)

    ecs_world:entity(constants.id.player)
        :assemble(
            assemble.player, constants.player_position():unpack()
        )

    ecs_world:entity(constants.id.thrower)
        :assemble(
            assemble.thrower, constants.thrower_position():unpack()
        )

    ctx:to_cache("ecs_world", ecs_world)
    ctx:to_cache("bump_world", bump_world)

    local draw = ctx:listen("draw"):collect()
    
    phases.countdown(ctx, ecs_world)

    local systems = list(
        nw.system.motion(ctx),
        nw.system.animation(ctx),
        require "system.projectile_spawn",
        require "system.projectile_speed",
        require "system.hitzones",
        require "system.rules"
    )

    local system_observables = systems:map(function(sys)
        return sys.observables(ctx)
    end)


    local pause = ctx:listen("keypressed")
        :filter(function(key) return key == "p" end)
        :reduce(function(state) return not state end, false)

    local dim = ctx:listen("keypressed")
        :filter(function(key) return key == "d" end)
        :reduce(function(state) return not state end, true)

    while ctx:is_alive() and 0 < ecs_world:ensure(nw.component.health, constants.id.global) do
        if not pause:peek() then
            for i = 1, system_observables:size() do
                local sys = systems[i]
                local obs = system_observables[i]
                sys.handle_observables(ctx, obs, ecs_world)
            end
        end

        for _, _ in ipairs(draw:pop()) do
            painter.paint_scene(ecs_world, dim:peek())
            painter.paint_ui(ecs_world)
        end

        ctx:yield()
    end

    local replay = ctx:listen("keypressed")
        :filter(function(key) return key == "r" end)
        :latest()

    while ctx:is_alive() and not replay:peek() do
        for _, _ in ipairs(draw:pop()) do
            painter.paint_scene(ecs_world, true)
            painter.paint_ui(ecs_world)
            painter.paint_finish(ecs_world)
        end
        ctx:yield()
    end

    return baseball(ctx)
end

return baseball
