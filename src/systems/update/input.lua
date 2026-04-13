local ecs = require("libs.evolved")

local stages = require("groups.stages")
local velocity = require("fragments.velocity")
local speed = require("fragments.speed")
local controllable = require("fragments.controllable")
local sprite = require("fragments.sprite")
local boost = require("fragments.boost")

return ecs.builder()
    :name("system.input.update")
    :group(stages.UPDATE)
    :include(velocity.x, velocity.y, speed, controllable)
    :include(sprite.direction)
    :include(boost)
    :execute(function(chunk, entity_list, entity_count)
        local vx, vy, speed, direction, boosting = chunk:components(
             velocity.x, velocity.y, speed, sprite.direction, boost
        )

        local dx, dy = 0, 0
        if love.keyboard.isDown("left") or love.keyboard.isDown("a") then dx = dx - 1 end
        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then dx = dx + 1 end
        if love.keyboard.isDown("up") or love.keyboard.isDown("w") then dy = dy - 1 end
        if love.keyboard.isDown("down") or love.keyboard.isDown("s") then dy = dy + 1 end

        -- If we are boosting we need to zoom! Let's go 1.5x faster!
        local is_boosting = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

        -- Save integer facing direction (-1, 0, 1) before normalization
        local facing = dx

        -- Normalize the direction vector if it's not zero
        local norm = math.sqrt(dx * dx + dy * dy)
        if norm > 0 then
            dx = dx / norm
            dy = dy / norm
        end

        for i = 1, entity_count do
            direction[i] = facing
            boosting[i] = is_boosting
            if boosting[i] then
                speed[i] = speed[i] * 1.5
            else
                speed[i] = speed[i] * (2 / 3)
            end
            vx[i] = dx * speed[i]
            vy[i] = dy * speed[i]
            print("{}{}", vx[i], vy[i])
        end
    end):spawn()