local ecs = require("libs.evolved")

local stages = require("groups.stages")
local velocity = require("fragments.velocity")
local speed = require("fragments.speed")
local controllable = require("fragments.controllable")
local sprite = require("fragments.sprite")
local boost = require("fragments.boost")
local energy = require("fragments.energy")
local deltatime = require("fragments.deltatime")

local DRAIN_RATE = 30  -- energy per second while boosting
local REGEN_RATE = 5  -- energy per second while not boosting

return ecs.builder()
    :name("system.input.update")
    :group(stages.UPDATE)
    :include(velocity.x, velocity.y, speed, controllable)
    :include(sprite.direction)
    :include(boost)
    :include(energy.current, energy.max)
    :execute(function(chunk, entity_list, entity_count)
        local vx, vy, spd, direction, boosting, energy, energy_max = chunk:components(
            velocity.x, velocity.y, speed, sprite.direction,
            boost, energy.current, energy.max
        )

        local dt = ecs.get(deltatime, deltatime)

        local dx, dy = 0, 0
        if love.keyboard.isDown("left") or love.keyboard.isDown("a") then dx = dx - 1 end
        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then dx = dx + 1 end
        if love.keyboard.isDown("up") or love.keyboard.isDown("w") then dy = dy - 1 end
        if love.keyboard.isDown("down") or love.keyboard.isDown("s") then dy = dy + 1 end

        local wants_boost = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

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

            -- Hysteresis: once boosting, run until empty (> 0).
            -- To start a fresh boost, need > 30 so regen can't immediately retrigger.
            local is_boosting
            if boosting[i] then
                is_boosting = wants_boost and energy[i] > 0
            else
                is_boosting = wants_boost and energy[i] > 30
            end
            boosting[i] = is_boosting

            if is_boosting then
                energy[i] = math.max(0, energy[i] - DRAIN_RATE * dt)
                spd[i] = spd[i] * 1.5
            else
                energy[i] = math.min(energy_max[i], energy[i] + REGEN_RATE * dt)
                spd[i] = spd[i] * (2 / 3)
            end

            vx[i] = dx * spd[i]
            vy[i] = dy * spd[i]
        end
    end):spawn()
