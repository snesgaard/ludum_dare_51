local collision = {}

function collision.hitzone(ctx, ecs_world, colinfo)
    local other_activation = ecs_world:get(
        nw.component.hitzone_activation, colinfo.other
    )
    local item_projectile = ecs_world:get(
        nw.component.projectile, colinfo.item
    )

    if not other_activation or not item_projectile then return end

    if other_activation:done() then return end

    ecs_world:destroy(colinfo.item)
    ecs_world:map(
        nw.component.hit_counter,
        constants.id.global,
        function(c) return c + 1 end
    )
    ecs_world:set(nw.component.already_counted, colinfo.other)
end

function collision.misszone(ctx, ecs_world, colinfo)
    local item_projectile = ecs_world:get(nw.component.projectile, colinfo.item)
    local other_miss_zone = ecs_world:get(nw.component.miss_zone, colinfo.other)

    if not item_projectile or not other_miss_zone then return end

    local already_counted = ecs_world:get(nw.component.already_counted, colinfo.item)
    if already_counted then return end

    ecs_world:set(nw.component.already_counted, colinfo.item)
    ctx:emit("take_damage")
end

function collision.negation_zone(ctx, ecs_world, colinfo)
    local item_projectile = ecs_world:get(nw.component.projectile, colinfo.item)
    local other_negation_zone = ecs_world:get(
        nw.component.negation_zone, colinfo.other
    )
    if not item_projectile or not other_negation_zone then return end
    ecs_world:destroy(colinfo.item)
end

local rules = {}

function rules.take_damage(ctx, ecs_world)
    ecs_world:map(
        nw.component.health, constants.id.global,
        function(hp) return math.max(0, hp - 1) end
    )
end

function rules.collision(ctx, ecs_world, colinfo)
    collision.hitzone(ctx, ecs_world, colinfo)
    collision.misszone(ctx, ecs_world, colinfo)
    collision.negation_zone(ctx, ecs_world, colinfo)
end

function rules.hitzone_done(ctx, ecs_world, id)
    if ecs_world:get(nw.component.already_counted, id) then return end
    ctx:emit("take_damage")
end

local api = {}

function api.observables(ctx)
    local obs = {}

    for key, _ in pairs(rules) do
        obs[key] = ctx:listen(key):collect()
    end

    return obs
end

function api.handle_observables(ctx, obs, ecs_world, ...)
    if not ecs_world then return end

    for k, o in pairs(obs) do
        local f = rules[k]
        for _, value in ipairs(o:peek()) do
            f(ctx, ecs_world, value)
        end
    end

    return api.handle_observables(ctx, obs, ...)
end

return api
