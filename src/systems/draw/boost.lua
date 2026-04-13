local ecs = require("libs.evolved")

-- ECS Related Imports:
local stages = require("groups.stages")

-- Fragments related to drawing:
local position = require("fragments.position")
local boost = require("fragments.boost")

-- Art related imports:
local misc = require "sprites.misc"

local ANIM_FPS    = 8
local ANIM_FRAMES = 4
local ROW_STRIDE  = 13  -- sheet is 8 quads wide (4 gold + 4 green per row)
local FLAME_ROW   = 3  -- which size row to use (0=small .. 3=large)
local GOLD_ROW    = FLAME_ROW * ROW_STRIDE + 5       -- cols 0-3 of that row
local GREEN_ROW   = GOLD_ROW + 4    -- cols 4-7 of that row

return ecs.builder()
    :name("system.boost.draw")
    :group(stages.DRAW)
    :include(position.x, position.y)
    :include(boost)
    :execute(function(chunk, entity_list, entity_count)
        local px, py, boosting = chunk:components(position.x, position.y, boost)
        local frame = math.floor(love.timer.getTime() * ANIM_FPS) % ANIM_FRAMES + 1
        for i = 1, entity_count do
            local row = boosting[i] and GREEN_ROW or GOLD_ROW
            love.graphics.draw(misc.sheet, misc.quads[frame + row], px[i], py[i] + 8 * SCALE_FACTOR, 0, SCALE_FACTOR, SCALE_FACTOR)
        end
    end):spawn()
