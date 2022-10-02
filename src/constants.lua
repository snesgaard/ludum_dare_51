local constants = {
    id = {
        player = "player",
        global = "global",
        lowzone = "lowzone",
        highzone = "highzone",
        spawner = "spawner",
        misszone = "misszone",
        thrower = "thrower",
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
    ),
    batter_x = 100,
    swing_decay = 0.2
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

function constants.thrower_x()
    return constants.screen_width() - 40
end

function constants.actor_floor()
    local frame = get_atlas("art/characters"):get_frame("background")
    local player_slice = frame.slices.player
    return player_slice:centerbottom().y
end

function constants.player_position()
    local frame = get_atlas("art/characters"):get_frame("background")
    local player_slice = frame.slices.player
    return player_slice:centerbottom()
end

function constants.thrower_position()
    local frame = get_atlas("art/characters"):get_frame("background")
    local player_slice = frame.slices.thrower
    return player_slice:centerbottom()
end

function constants.base_lanes()
    local frame = get_atlas("art/characters"):get_frame("batter/idle")

    local body_slice = frame.slices.body
    local low_slice = frame.slices.lower_hit
    local high_slice = frame.slices.upper_hit

    return list(
        high_slice:centerbottom().y - body_slice:centerbottom().y,
        low_slice:centerbottom().y - body_slice:centerbottom().y
    )
end

function constants.lower_swing_box()
    local frame = get_atlas("art/characters"):get_frame("batter/idle")

    local low_slice = frame.slices.lower_hit
    local body_slice = frame.slices.body
    local c = -body_slice:centerbottom()
    return low_slice:move(c:unpack())
end

function constants.upper_swing_box()
    local frame = get_atlas("art/characters"):get_frame("batter/idle")

    local low_slice = frame.slices.upper_hit
    local body_slice = frame.slices.body
    local c = -body_slice:centerbottom()
    return low_slice:move(c:unpack())
end

function constants.world_lanes()
    return constants.base_lanes()
        :map(function(y) return y + constants.actor_floor() end)
end

return constants
