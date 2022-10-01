local painter = require "painter"

local function draw_scene(ecs_world)
    gfx.push("all")
    gfx.scale(constants.scale, constants.scale)
    painter.paint_scene(ecs_world)
    gfx.pop()
end

local collision_class = nw.system.collision():class()

function collision_class.default_filter()
    return "cross"
end

return function(ctx)
    local ecs_world = nw.ecs.entity.create()
    local bump_world = nw.third.bump.newWorld()

    for index, id in ipairs(constants.id.hitzones) do
        local y = constants.lanes[index]
        ecs_world:entity(id):assemble(assemble.hitzone, y, bump_world)
    end

    ctx:to_cache("ecs_world", ecs_world)
    ctx:to_cache("bump_world", bump_world)

    local systems = list(
        nw.system.motion(ctx),
        require "system.projectile_spawn",
        require "system.projectile_speed",
        require "system.hitzones"
    )

    local system_observables = systems:map(function(sys)
        return sys.observables(ctx)
    end)

    local draw = ctx:listen("draw"):collect()

    while ctx:is_alive() do
        for i = 1, system_observables:size() do
            local sys = systems[i]
            local obs = system_observables[i]
            sys.handle_observables(ctx, obs, ecs_world)
        end

        for _, _ in ipairs(draw:pop()) do
            draw_scene(ecs_world)
        end

        ctx:yield()
    end
end
