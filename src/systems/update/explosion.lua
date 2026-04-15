local ecs = require "libs.evolved"

local stages          = require "groups.stages"
local deltatime       = require "fragments.deltatime"
local explosion_timer = require "fragments.explosion_timer"

local FRAME_DUR  = 0.05  -- seconds per frame
local NUM_FRAMES = 4
local MAX_TIME   = FRAME_DUR * NUM_FRAMES 

local to_destroy = {}

return ecs.builder()
    :name("system.explosion.update")
    :group(stages.UPDATE)
    :include(explosion_timer)
    :prologue(function()
        to_destroy = {}
    end)
    :execute(function(chunk, entity_list, entity_count)
        local dt    = ecs.get(deltatime, deltatime)
        local timer = chunk:components(explosion_timer)

        for i = 1, entity_count do
            timer[i] = timer[i] + dt
            if timer[i] >= MAX_TIME then
                to_destroy[#to_destroy + 1] = entity_list[i]
            end
        end
    end)
    :epilogue(function()
        for _, e in ipairs(to_destroy) do
            if ecs.alive(e) then ecs.destroy(e) end
        end
    end):spawn()
