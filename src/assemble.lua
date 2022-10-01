local assemble = {}

function assemble.projectile(entity, x, y, bump_world)
    entity
        :assemble(
            nw.system.collision().assemble.init_entity, x, y,
            nw.component.hitbox(4, 4), bump_world
        )
        :set(nw.component.drawable, nw.drawable.body)
        :set(nw.component.color, 1, 1, 1)
        :set(nw.component.base_velocity, -100, 0)
        :set(nw.component.projectile, "ball")
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
            nw.component.hitbox(0, 0):expand(10, 20), bump_world
        )
        :set(nw.component.drawable, hitzone_draw)
end

return assemble
