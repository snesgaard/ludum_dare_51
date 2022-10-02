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
        --:set(nw.component.drawable, nw.drawable.body)
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
    return player_animations[state] or player_animations.idle
end

local function draw_player(entity)
    --local animation = get_player_frame(entity)
    --nw.system.animation():ensure(entity, animation, true)
    return nw.drawable.animation(entity)
end

function assemble.player(entity, x, y)
    entity
        :set(nw.component.position, x, y)
        :set(nw.component.drawable, draw_player)

    nw.system.animation():play(entity, animations.player.idle)
end

function assemble.thrower(entity, x, y)
    entity
        :set(nw.component.position, x, y)
        :set(nw.component.drawable, nw.drawable.animation)

    nw.system.animation():play(entity, animations.thrower.idle)
end

local tomato_particle = gfx.prerender(4, 4, function(w, h)
    gfx.setColor(1, 1, 1)
    gfx.circle("fill", w / 2, h / 2, w / 2)
end)
function assemble.tomato_splat(entity, x, y)
    entity
        :set(nw.component.position, x, y)
        :set(
            nw.component.particles,
            {
                image = tomato_particle,
                buffer = 20,
                emit = 20,
                lifetime = {0.25, 0.5},
                spread = math.pi * 0.5,
                dir = -math.pi * 0.5,
                speed = {100, 200},
                acceleration = {0, 500},
                color = color("c44132")
            }
        )
        :set(nw.component.die_on_empty)
        :set(nw.component.drawable, nw.drawable.particles)
end

return assemble
