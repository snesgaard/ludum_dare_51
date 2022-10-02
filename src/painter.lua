local painter = {}

painter.font = gfx.newFont(32)
painter.small_font = gfx.newFont(16)

function painter.paint_scene(ecs_world)
    local drawable = ecs_world:get_component_table(nw.component.drawable)

    for id, func in pairs(drawable) do func(ecs_world:entity(id)) end
end

function painter.paint_finish(ecs_world)
    local mid = spatial(
        gfx.getWidth() / 2, gfx.getHeight() / 2,
        0, 0
    ):expand(gfx.getWidth() / 2, 0)
    local upper = mid:up(0, 10, nil, 100)
    local down = mid:down(0, 10, nil, 100)

    painter.paint_textbox("It's over!", upper)
    painter.paint_textbox("Press R to replay!", down)
end

function painter.paint_textbox(text, area, text_opts)
    local text_opts = text_opts or {font = painter.font, align = "center", valign = "center"}
    local margin = text_opts.margin or 0
    gfx.push("all")
    gfx.setColor(0.1, 0.2, 0.5, 0.5)
    gfx.rectangle("fill", area:expand(margin, margin):unpack())
    gfx.setColor(1, 1, 1)
    painter.paint_text(text, area.x, area.y, area.w, area.h, text_opts)
    gfx.pop()
end

local function compute_vertical_offset(valign, font, h)
    if valign == "top" then
		return 0
	elseif valign == "bottom" then
		return h - font:getHeight()
    else
        return (h - font:getHeight()) / 2
	end
end

function painter.paint_text(text, x, y, w, h, opt, sx, sy)
    local opt = opt or {}
    if opt.font then gfx.setFont(opt.font) end

    local dy = compute_vertical_offset(opt.valign, gfx.getFont(), h)

    gfx.printf(text, x, y + dy, w, opt.align or "left")
end

function painter.paint_background(dim)
    local frame = get_atlas("art/characters"):get_frame("background")
    gfx.push("all")

    frame:draw(0, 0)
    if dim then
        gfx.setColor(0.1, 0.2, 0.4, 0.3)
        gfx.rectangle(
            "fill", 0, 0, constants.screen_width(), constants.screen_height()
        )
    end

    gfx.pop()
end

function painter.paint_time(shape, time, duration)
    local theme = {
        bg = color("573976"),
        fg = color("eedfc7")
    }
    local center = shape:center()
    local angle = -(time / duration) * math.pi * 2 + math.pi

    gfx.push("all")
    gfx.translate(shape.x, shape.y)
    gfx.setColor(theme.bg)
    gfx.circle("fill", 0, 0, shape.w / 2, shape.h / 2)
    gfx.rotate(angle)
    gfx.setColor(theme.fg)
    gfx.rectangle("fill", -5, 0, 10, shape.h / 2)
    gfx.pop()
end

return painter
