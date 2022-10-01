local constants = {
    id = {
        player = "player",
        global = "global",
        lowzone = "lowzone",
        highzone = "highzone",
        spawner = "spawner",
        misszone = "misszone",
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

function constants.screen_height()
    return gfx.getHeight() / constants.scale
end

return constants
