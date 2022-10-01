local painter = {}

function painter.paint_scene(ecs_world)
    local drawable = ecs_world:get_component_table(nw.component.drawable)

    for id, func in pairs(drawable) do func(ecs_world:entity(id)) end
end

return painter
