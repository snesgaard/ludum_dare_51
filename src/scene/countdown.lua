local painter = require "painter"

local CounterDowner = class()

CounterDowner.interval = 1
CounterDowner.messages = list("3", "2", "1", "Let's Bat!")

local function create_msg_timer(msg)
    return {msg = msg, timer = nw.component.timer.create(CounterDowner.interval)}
end

function CounterDowner.create()
    return setmetatable(
        {
            timers = CounterDowner.messages:map(create_msg_timer)
        },
        CounterDowner
    )
end

function CounterDowner:__tostring()
    return "CountDown"
end

function CounterDowner:update(dt)
    for _, timer in ipairs(self.timers) do
        if not timer.timer:done() then
            timer.timer:update(dt)
            return
        end
    end
end

function CounterDowner:is_done()
    for _, timer in ipairs(self.timers) do
        if not timer.timer:done() then return false end
    end

    return true
end

local text_opt = {
    font = gfx.newFont(64),
    align = "center",
    valign = "center"
}

function CounterDowner:draw_single_message(timer)
    local scale = ease.linear(timer.timer.time, 1, 4, timer.timer.duration)
    local box = spatial(0, 0, 1000, 100)
    gfx.push()
    gfx.translate(gfx.getWidth() / 2, gfx.getHeight() / 2)
    gfx.scale(scale, scale)
    gfx.translate(-box.w * 0.5, -box.h * 0.5)
    painter.paint_text(timer.msg, box.x, box.y, box.w, box.h, text_opt)
    gfx.pop()
end

function CounterDowner:draw()
    for _, timer in ipairs(self.timers) do
        if not timer.timer:done() then
            return self:draw_single_message(timer)
        end
    end
end

return function(ctx, ecs_world)
    local systems = list(
        nw.system.motion(ctx),
        nw.system.animation(ctx),
        require "system.hitzones",
        require "system.rules"
    )
    local system_observables = systems:map(function(sys)
        return sys.observables(ctx)
    end)

    local countdown = CounterDowner.create()

    local draw = ctx:listen("draw"):collect()
    local update = ctx:listen("update"):collect()

    while ctx:is_alive() and not countdown:is_done() do
        for i = 1, system_observables:size() do
            local sys = systems[i]
            local obs = system_observables[i]
            sys.handle_observables(ctx, obs, ecs_world)
        end

        for _, dt in ipairs(update:pop()) do
            countdown:update(dt)
        end

        for _, _ in ipairs(draw:pop()) do
            painter.paint_scene(ecs_world, true)
            painter.paint_ui(ecs_world)
            countdown:draw()
        end

        ctx:yield()
    end
end
