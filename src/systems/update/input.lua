local ecs = require("libs.evolved")

local stages = require("groups.stages")
local velocity = require("fragments.velocity")
local speed = require("fragments.speed")
local controllable = require("fragments.controllable")
local sprite = require("fragments.sprite")

return ecs.builder()
    :name("system.input.update")
    :group(stages.UPDATE)
    :include(velocity.x, velocity.y, speed, controllable)
    :include(sprite.direction)
    :execute(function(chunk, entity_list, entity_count)
        local vx, vy, speed, direction = chunk:components(
             velocity.x, velocity.y, speed, sprite.direction
        )

        local dx, dy = 0, 0
        if love.keyboard.isDown("left") or love.keyboard.isDown("a") then dx = dx - 1 end
        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then dx = dx + 1 end
        if love.keyboard.isDown("up") or love.keyboard.isDown("w") then dy = dy - 1 end
        if love.keyboard.isDown("down") or love.keyboard.isDown("s") then dy = dy + 1 end

        -- Save integer facing direction (-1, 0, 1) before normalization
        local facing = dx

        -- Normalize the direction vector if it's not zero
        local norm = math.sqrt(dx * dx + dy * dy)
        if norm > 0 then
            dx = dx / norm
            dy = dy / norm
        end

        for i = 1, entity_count do
            vx[i] = dx * speed[i]
            vy[i] = dy * speed[i]
            direction[i] = facing
        end
    end):spawn()