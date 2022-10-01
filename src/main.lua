nw = require "nodeworks"
constants = require "constants"
assemble = require "assemble"

decorate(nw.component, require "component")

function love.load()
    world = nw.ecs.world()
    world:push(require "scene.baseball")
end

function love.mousepressed(x, y, button)
    world:emit("mousepressed", x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
    world:emit("keypressed", key)

    if key == "escape" then love.event.quit() end
end

function love.keyreleased(key)
    world:emit("keyreleased", key)
end

function love.update(dt)
    world:emit("update", dt):spin()
end

function love.draw()
    world:emit("draw"):spin()
end
