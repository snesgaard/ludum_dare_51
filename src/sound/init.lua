local BASE = ...

local function load(name)
    return love.audio.newSource(BASE .. name, "static")
end

return {
    hit = list(
        love.audio.newSource(... .. "/bathit.ogg", "static"),
        love.audio.newSource(... .. "/bathit2.ogg", "static"),
        love.audio.newSource(... .. "/bathit3.ogg", "static")
    ),
    mistake = love.audio.newSource(... .. "/mistake.ogg", "static"),
    lets_bat = love.audio.newSource(... .. "/lets_bat.ogg", "static"),
    faster = load("/faster.ogg"),
    speed = load("/speed.ogg"),
    woosh = load("/woosh.ogg")
}
