local component = {}

function component.projectile(type) return type end

function component.base_velocity(vx, vy) return vec2(vx, vy) end

function component.velocity_multiplier(s) return s or 1 end

function component.time_before_speedup(time)
    return nw.component.timer.create(time or 10)
end

function component.hitzone_activation()
    return nw.component.timer.create(0.1)
end

function component.hit_counter(c) return c or 0 end

function component.health(hp) return hp or 3 end

function component.miss_zone() return true end

function component.negation_zone() return true end

function component.miss_counted() return true end

function component.already_counted() return true end

return component
