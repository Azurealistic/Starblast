local ecs = require "libs.evolved"

local stages      = require "groups.stages"
local deltatime   = require "fragments.deltatime"
local enemy_frag  = require "fragments.enemy"
local spawn_grace = require "fragments.spawn_grace"

return ecs.builder()
    :name("system.spawn_grace.update")
    :group(stages.UPDATE)
    :include(enemy_frag, spawn_grace)
    :execute(function(chunk, entity_list, entity_count)
        local grace = chunk:components(spawn_grace)
        local dt    = ecs.get(deltatime, deltatime)

        for i = 1, entity_count do
            if grace[i] > 0 then
                grace[i] = math.max(0, grace[i] - dt)
            end
        end
    end):spawn()
