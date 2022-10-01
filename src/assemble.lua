local assemble = {}

local function roll_projectile_type()
    local r = love.math.random()

    if r < 0.2 then return "tomato" end

    return "ball"
end

local function projectile_draw(entity)
    local ptype = entity:get(nw.component.projectile)

    local colors = {
        tomato = color(1, 0.2, 0.1),
        ball = color(1, 1, 1)
    }

    entity:set(nw.component.color, colors[ptype])
    return nw.drawable.body(entity)
end

function assemble.projectile(entity, x, y, bump_world)
    entity
        :assemble(
            nw.system.collision().assemble.init_entity, x, y,
            nw.component.hitbox(4, 4), bump_world
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

function assemble.hitzone(entity, y, bump_world)
    entity
        :assemble(
            nw.system.collision().assemble.init_entity, 100, y,
            nw.component.hitbox(0, 0):expand(20, 20), bump_world
        )
        :set(nw.component.drawable, hitzone_draw)
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

return assemble
