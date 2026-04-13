local ecs = require("libs.evolved")

local stages = require("groups.stages")
local position = require("fragments.position")
local controllable = require("fragments.controllable")

local SHIP_SIZE = 8 -- sprite cell size in game pixels

return ecs.builder()
    :name("system.clamp.update")
    :group(stages.UPDATE)
    :include(position.x, position.y, controllable)
    :execute(function(chunk, entity_list, entity_count)
        local px, py = chunk:components(position.x, position.y)

        local min_x = 0
        local max_x = (GAME_WIDTH - SHIP_SIZE) * SCALE_FACTOR
        local min_y = (GAME_HEIGHT / 2) -- Don't want to clash with the UI!
        local max_y = (GAME_HEIGHT - SHIP_SIZE * 2) * SCALE_FACTOR

        for i = 1, entity_count do
            if px[i] < min_x then px[i] = min_x end
            if px[i] > max_x then px[i] = max_x end
            if py[i] < min_y then py[i] = min_y end
            if py[i] > max_y then py[i] = max_y end
        end
    end):spawn()
