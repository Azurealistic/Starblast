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

return ecs.builder()
    :name("system.movement_pattern.update")
    :group(stages.UPDATE)
    :include(enemy_frag, velocity.x, velocity.y, speed, movement_pattern.id, path_timer)
    :execute(function(chunk, entity_list, entity_count)
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
                -- Gentle weave, amplitude scales with speed
                vx[i] = math.sin(t * 2.8) * s * 0.65
                vy[i] = s

            elseif pat[i] == ZIGZAG then
                -- Sharp cuts every 0.35 s
                local dir = math.floor(t / 0.35) % 2 == 0 and 1 or -1
                vx[i] = dir * s * 0.7
                vy[i] = s * 0.85

            elseif pat[i] == DIVE_LEFT then
                -- Hard leftward sweep that fades out over ~0.6 s
                local fade = math.max(0, 1 - t * 1.6)
                vx[i] = -s * fade * 1.4
                vy[i] = s

            elseif pat[i] == DIVE_RIGHT then
                local fade = math.max(0, 1 - t * 1.6)
                vx[i] = s * fade * 1.4
                vy[i] = s

            elseif pat[i] == STRAFE_LEFT then
                -- Glides left-and-down for 0.8 s, then drops straight
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
            end
        end
    end):spawn()
