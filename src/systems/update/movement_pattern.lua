local ecs = require "libs.evolved"

local stages           = require "groups.stages"
local deltatime        = require "fragments.deltatime"
local velocity         = require "fragments.velocity"
local speed            = require "fragments.speed"
local enemy_frag       = require "fragments.enemy"
local movement_pattern = require "fragments.movement_pattern"
local path_timer       = require "fragments.path_timer"

local STRAIGHT     = movement_pattern.STRAIGHT
local SINE         = movement_pattern.SINE
local ZIGZAG       = movement_pattern.ZIGZAG
local DIVE_LEFT    = movement_pattern.DIVE_LEFT
local DIVE_RIGHT   = movement_pattern.DIVE_RIGHT
local STRAFE_LEFT  = movement_pattern.STRAFE_LEFT
local STRAFE_RIGHT = movement_pattern.STRAFE_RIGHT
local SWEEP_LEFT   = movement_pattern.SWEEP_LEFT
local SWEEP_RIGHT  = movement_pattern.SWEEP_RIGHT
local ORBIT        = movement_pattern.ORBIT
local CHARGE       = movement_pattern.CHARGE

return ecs.builder()
    :name("system.movement_pattern.update")
    :group(stages.UPDATE)
    :include(enemy_frag, velocity.x, velocity.y, speed, movement_pattern.id, path_timer)
    :execute(function(chunk, _, entity_count)
        local dt = ecs.get(deltatime, deltatime)
        local vx, vy, spd, pat, timer = chunk:components(
            velocity.x, velocity.y, speed, movement_pattern.id, path_timer)

        for i = 1, entity_count do
            timer[i] = timer[i] + dt
            local t = timer[i]
            local s = spd[i]

            if pat[i] == STRAIGHT then
                vx[i] = 0
                vy[i] = s

            elseif pat[i] == SINE then
                vx[i] = math.sin(t * 2.8) * s * 0.65
                vy[i] = s

            elseif pat[i] == ZIGZAG then
                local dir = math.floor(t / 0.35) % 2 == 0 and 1 or -1
                vx[i] = dir * s * 0.7
                vy[i] = s * 0.85

            elseif pat[i] == DIVE_LEFT then
                local fade = math.max(0, 1 - t * 1.6)
                vx[i] = -s * fade * 1.4
                vy[i] = s

            elseif pat[i] == DIVE_RIGHT then
                local fade = math.max(0, 1 - t * 1.6)
                vx[i] = s * fade * 1.4
                vy[i] = s

            elseif pat[i] == STRAFE_LEFT then
                if t < 0.8 then
                    vx[i] = -s * 0.85
                    vy[i] = s * 0.45
                else
                    vx[i] = 0
                    vy[i] = s
                end

            elseif pat[i] == STRAFE_RIGHT then
                if t < 0.8 then
                    vx[i] = s * 0.85
                    vy[i] = s * 0.45
                else
                    vx[i] = 0
                    vy[i] = s
                end

            elseif pat[i] == SWEEP_LEFT then
                -- Fast horizontal sweep right→left for 1.4 s, then drops
                if t < 1.4 then
                    vx[i] = -s * 1.5
                    vy[i] =  s * 0.2
                else
                    vx[i] = 0
                    vy[i] = s
                end

            elseif pat[i] == SWEEP_RIGHT then
                if t < 1.4 then
                    vx[i] = s * 1.5
                    vy[i] = s * 0.2
                else
                    vx[i] = 0
                    vy[i] = s
                end

            elseif pat[i] == ORBIT then
                -- Circular descent: traces a helix downward
                local omega = 3.5
                vx[i] = -s * 0.85 * math.sin(t * omega)
                vy[i] =  s * 0.5  + s * 0.85 * math.cos(t * omega)

            elseif pat[i] == CHARGE then
                -- Menacing hover with wobble, then sudden fast dive
                if t < 1.5 then
                    vx[i] = math.sin(t * 6) * s * 0.2
                    vy[i] = s * 0.1
                else
                    vx[i] = 0
                    vy[i] = s * 2.5
                end
            end
        end
    end):spawn()
