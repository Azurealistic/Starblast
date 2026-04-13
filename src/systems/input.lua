local ecs = require("libs.evolved")

local stages = require("groups.stages")
local velocity = require("fragments.velocity")
local speed = require("fragments.speed")
local controllable = require("fragments.controllable")

return ecs.builder()
    :name("system.input")
    :group(stages.UPDATE)
    :include(velocity.x, velocity.y, speed, controllable)
    :execute(function(chunk, entity_list, entity_count)
        local vx, vy, speed = chunk:components(
             velocity.x, velocity.y, speed
        )

        local dx, dy = 0, 0
        if love.keyboard.isDown("left") or love.keyboard.isDown("a") then dx = dx - 1 end
        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then dx = dx + 1 end
        if love.keyboard.isDown("up") or love.keyboard.isDown("w") then dy = dy - 1 end
        if love.keyboard.isDown("down") or love.keyboard.isDown("s") then dy = dy + 1 end

        -- Normalize the direction vector if it's not zero
        local norm = math.sqrt(dx * dx + dy * dy)
        if norm > 0 then
            dx = dx / norm
            dy = dy / norm
        end

        for i = 1, entity_count do
            vx[i] = dx * speed[i]
            vy[i] = dy * speed[i]
        end
    end):spawn()