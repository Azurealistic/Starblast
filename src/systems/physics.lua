local ecs = require("libs.evolved")

local stages = require("groups.stages")
local position = require("fragments.position")
local velocity = require("fragments.velocity")
local deltatime = require("fragments.deltatime")

return ecs.builder()
    :name("system.physics")
    :group(stages.UPDATE)
    :include(position.x, position.y, velocity.x, velocity.y)
    :execute(function(chunk, entity_list, entity_count)
        local px, py, vx, vy = chunk:components(
            position.x, position.y, velocity.x, velocity.y
        )

        local dt = ecs.get(deltatime, deltatime)

        for i = 1, entity_count do
            px[i] = px[i] + vx[i] * dt
            py[i] = py[i] + vy[i] * dt
            -- print("Entity " .. entity_list[i] .. " moved to position: (" .. px[i] .. ", " .. py[i] .. ")")
        end
    end):spawn()