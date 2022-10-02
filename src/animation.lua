local atlas = get_atlas("art/characters")

return {
    player = {
        idle = atlas:get_animation("batter/idle"),
        upper_hit = list(
            atlas:get_frame("batter/idle"):set_dt(0.02),
            atlas:get_frame("batter/high_swing"):set_dt(constants.swing_decay),
            atlas:get_frame("batter/idle")
        ),
        lower_hit = list(
            atlas:get_frame("batter/idle"):set_dt(0.02),
            atlas:get_frame("batter/low_swing"):set_dt(constants.swing_decay),
            atlas:get_frame("batter/idle")
        )
    }
}
