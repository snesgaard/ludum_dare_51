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

    ctx:emit("hitzone_impact", {hitzone=colinfo.other, projectile=colinfo.item})
end

function collision.misszone(ctx, ecs_world, colinfo)
    local item_projectile = ecs_world:get(nw.component.projectile, colinfo.item)
    local other_miss_zone = ecs_world:get(nw.component.miss_zone, colinfo.other)

    if not item_projectile or not other_miss_zone then return end

    local already_counted = ecs_world:get(nw.component.already_counted, colinfo.item)
    if already_counted then return end

    if item_projectile ~= "tomato" then ctx:emit("take_damage") end
    ecs_world:set(nw.component.already_counted, colinfo.item)
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

function rules.hitzone_impact(ctx, ecs_world, args)
    local proj_type = ecs_world:get(nw.component.projectile, args.projectile)

    if not proj_type then return end

    if ecs_world:get(nw.component.already_counted, args.projectile) then
        return
    end

    if proj_type == "ball" then
        ecs_world:map(
            nw.component.hit_counter,
            constants.id.global,
            function(c) return c + 1 end
        )
    elseif proj_type == "tomato" then
        ctx:emit("take_damage")
    end

    if proj_type == "tomato" then
        local pos = ecs_world:get(nw.component.position, args.projectile)
        ecs_world:destroy(args.projectile)
        ecs_world:entity():assemble(assemble.tomato_splat, pos.x, pos.y)
    else
        ecs_world:set(nw.component.base_velocity, args.projectile, 200, -200)
        ecs_world:set(nw.component.already_counted, args.projectile)
    end
    ecs_world:set(nw.component.already_counted, args.hitzone)
end

function rules.collision(ctx, ecs_world, colinfo)
    collision.hitzone(ctx, ecs_world, colinfo)
    collision.misszone(ctx, ecs_world, colinfo)
    collision.negation_zone(ctx, ecs_world, colinfo)
end

function rules.hitzone_done(ctx, ecs_world, id)
    if ecs_world:get(nw.component.already_counted, id) then return end
end

function rules.update(ctx, ecs_world, dt)
    local particle_entities = ecs_world:get_component_table(
        nw.component.particles
    )

    for id, particle in pairs(particle_entities) do
        particle:update(dt)
        if particle:getCount() == 0 and ecs_world:get(nw.component.die_on_empty, id) then
            ecs_world:destroy(id)
        end
    end

    local timer = ecs_world:get(
        nw.component.player_state_decay, constants.id.player
    )

    if not timer then return end
    if timer:update(dt) then
        ecs_world:remove(nw.component.player_state_decay, constants.id.player)
        ecs_world:remove(nw.component.player_state, constants.id.player)
    end
end

function rules.keypressed(ctx, ecs_world, key)
    local index_from_key = {up = 1, down = 2}
    local index = index_from_key[key]
    if not index then return end
    local id = constants.id.hitzones[index]
    if not id then return end
    ecs_world:set(nw.component.hitzone_activation, id)
    ecs_world:remove(nw.component.already_counted, false)
    local entity = ecs_world:entity(constants.id.player)
    if key == "up" then
        ecs_world:set(
            nw.component.player_state, constants.id.player, "upper_hit"
        )
        ecs_world:set(
            nw.component.player_state_decay, constants.id.player
        )
        nw.system.animation(ctx):play_once(entity, animations.player.upper_hit)
    elseif key == "down" then
        ecs_world:set(
            nw.component.player_state, constants.id.player, "lower_hit"
        )
        ecs_world:set(
            nw.component.player_state_decay, constants.id.player
        )
        nw.system.animation(ctx):play_once(entity, animations.player.lower_hit)
    end
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
