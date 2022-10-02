local painter = require "painter"

local function draw_end_screen(ecs_world)
    gfx.push("all")
    gfx.setFont(font)
    gfx.setColor(1, 1, 1)
    gfx.pop()
end

local function draw_ui(ecs_world)
    local health = ecs_world:ensure(nw.component.health, constants.id.global)
    local hit_count = ecs_world:ensure(
        nw.component.hit_counter, constants.id.global
    )

    gfx.push("all")

    gfx.translate(10, 10)

    gfx.setFont(painter.font)
    gfx.setColor(1, 1, 1)
    gfx.printf(string.format("%i", hit_count), 10, 0, 100, "left")

    gfx.translate(0, 40)
    gfx.setColor(1, 0, 0)

    for i = 1, health do gfx.circle("fill", i * 15, 0, 5) end

    gfx.pop()

    gfx.push("all")

    gfx.translate(gfx.getWidth(), 0)
    gfx.translate(-20, 20)

    local counter_box = spatial(0, 0, 10, 100)
    local timer = ecs_world:ensure(nw.component.time_before_speedup, constants.id.global)
    local s = timer.time / timer.duration

    gfx.setColor(0.5, 0.5, 0.5)
    gfx.rectangle("fill", counter_box:unpack())
    gfx.setColor(1, 1, 1)
    gfx.rectangle(
        "fill",
        counter_box.x, counter_box.y + counter_box.h * (1 - s),
        counter_box.w, counter_box.h * s
    )
    gfx.pop()
end

local function draw_scene(ecs_world)
    gfx.push("all")
    gfx.scale(constants.scale, constants.scale)
    painter.paint_scene(ecs_world)
    local atlas = get_atlas("art/characters")
    local frame = atlas:get_frame("batter/idle")
    frame:draw(0, 0)
    gfx.pop()
end

local collision_class = nw.system.collision():class()

function collision_class.default_filter()
    return "cross"
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
        local x = constants.batter_x
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
        :assemble(assemble.player, 100, constants.actor_floor())

    ctx:to_cache("ecs_world", ecs_world)
    ctx:to_cache("bump_world", bump_world)

    local systems = list(
        nw.system.motion(ctx),
        require "system.projectile_spawn",
        require "system.projectile_speed",
        require "system.hitzones",
        require "system.rules"
    )

    local system_observables = systems:map(function(sys)
        return sys.observables(ctx)
    end)

    local draw = ctx:listen("draw"):collect()

    local pause = ctx:listen("keypressed")
        :filter(function(key) return key == "p" end)
        :reduce(function(state) return not state end, false)


    while ctx:is_alive() and 0 < ecs_world:ensure(nw.component.health, constants.id.global) do
        if not pause:peek() then
            for i = 1, system_observables:size() do
                local sys = systems[i]
                local obs = system_observables[i]
                sys.handle_observables(ctx, obs, ecs_world)
            end
        end

        for _, _ in ipairs(draw:pop()) do
            print("draw")
            draw_scene(ecs_world)
            draw_ui(ecs_world)
        end

        ctx:yield()
    end

    local replay = ctx:listen("keypressed")
        :filter(function(key) return key == "r" end)
        :latest()

    while ctx:is_alive() and not replay:peek() do
        for _, _ in ipairs(draw:pop()) do
            draw_scene(ecs_world)
            draw_ui(ecs_world)
            painter.paint_finish(ecs_world)
        end
        ctx:yield()
    end

    return baseball(ctx)
end

return baseball
