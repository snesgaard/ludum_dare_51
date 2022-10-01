local constants = {
    id = {
        player = "player",
        global = "global",
        lowzone = "lowzone",
        highzone = "highzone",
        spawner = "spawner",
        hitzones = {up = "up", down = "down"}
    },
    types = {
        ball = "ball",
        tomato = "tomato"
    },
    scale = 4,
    lanes = list(
        40,
        100
    )
}


constants.id.hitzones = constants.lanes:map(
    function(y) return "hitzone:" .. tostring(y) end
)


function constants.screen_width()
    return gfx.getWidth() / constants.scale
end

return constants
