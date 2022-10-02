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
    },
    thrower = {
        idle = atlas:get_animation("throw/idle"),
        low_throw = list(
            --atlas:get_frame("throw/pre_throw"):set_dt(0.05),
            atlas:get_frame("throw/low_throw"):set_dt(constants.swing_decay),
            atlas:get_frame("throw/pre_throw")
        ),
        up_throw = list(
            atlas:get_frame("throw/up_throw"):set_dt(constants.swing_decay),
            atlas:get_frame("throw/pre_throw")
        )
    }
}
