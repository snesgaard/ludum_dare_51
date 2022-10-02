local assemble = {}

local function roll_projectile_type()
    local r = love.math.random()

    if r < 0.2 then return "tomato" end

    return "ball"
end

local function projectile_frame(ptype)
    local frames = {
        ball = get_atlas("art/characters"):get_frame("projectile/ball"),
        tomato = get_atlas("art/characters"):get_frame("projectile/tomato")
    }

    return frames[ptype] or frames.ball
end

local function projectile_draw(entity)
    local ptype = entity:get(nw.component.projectile)

    local frame = projectile_frame(ptype)

    gfx.push("all")
    nw.drawable.push_transform(entity)
    nw.drawable.push_state(entity)
    frame:draw("body", 0, 0)
    gfx.pop()
end

function assemble.projectile(entity, x, y, bump_world)
    entity
        :assemble(
            nw.system.collision().assemble.init_entity, x, y,
            nw.component.hitbox(6, 6), bump_world
        )
        :set(nw.component.drawable, projectile_draw)
        :set(nw.component.color, 1, 1, 1)
        :set(nw.component.base_velocity, -100, 0)
        :set(nw.component.projectile, roll_projectile_type())
end

local function hitzone_draw(entity)
    local timer = entity:get(nw.component.hitzone_activation)
    if not timer or timer:done() then
        entity:set(nw.component.color, 1, 1, 1)
    else
        entity:set(nw.component.color, 1, 0.2, 0.2)
    end

    return nw.drawable.body(entity)
end

function assemble.hitzone(entity, x, y, hitbox, bump_world)
    entity
        :assemble(
            nw.system.collision().assemble.init_entity, x, y,
            hitbox, bump_world
        )
        --:set(nw.component.drawable, hitzone_draw)
end

function assemble.miss_zone(entity, bump_world)
    entity
        :assemble(
            nw.system.collision().assemble.init_entity,
            0, constants:screen_height() / 2,
            spatial(0, 0, 0, 0):expand(50, 1000),
            bump_world
        )
        :set(nw.component.drawable, nw.drawable.body)
        :set(nw.component.miss_zone)

end

function assemble.negation_zone(entity, body, bump_world)
    entity
        :assemble(
            nw.system.collision().assemble.init_entity,
            0, 0, body, bump_world
        )
        :set(nw.component.drawable, nw.drawable.body)
        :set(nw.component.negation_zone)
end

local function get_player_frame(entity)
    local state = entity:ensure(nw.component.player_state)

    local state_map = {
        idle = get_atlas("art/characters"):get_frame("batter/idle"),
        upper_hit = get_atlas("art/characters"):get_frame("batter/high_swing"),
        lower_hit = get_atlas("art/characters"):get_frame("batter/low_swing")
    }

    return state_map[state] or state_map.idle
end

local function draw_player(entity)
    local frame = get_player_frame(entity)
    gfx.push("all")
    nw.drawable.push_transform(entity)
    nw.drawable.push_state(entity)
    frame:draw("body", 0, 0)
    gfx.pop()
end

function assemble.player(entity, x, y)
    entity
        :set(nw.component.position, x, y)
        :set(nw.component.drawable, draw_player)
end

return assemble
