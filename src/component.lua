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



return component
