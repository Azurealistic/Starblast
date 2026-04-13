local ecs = require("libs.evolved")

-- ECS Related Imports:
local stages = require("groups.stages")

-- Fragments:
local health = require("fragments.health")
local shield = require("fragments.shield")

-- Art:
local misc = require "sprites.misc"

-- Adjust these to match the correct quads in misc.png:
local HEART_FULL  = 3
local HEART_EMPTY = 5
local SHIELD_FULL  = 4
local SHIELD_EMPTY = 5

local PADDING   = 4  -- pixels from screen edge (before SCALE_FACTOR)
local ICON_SIZE = 8  -- each icon is 8x8 px in the sheet
local GAP       = 2  -- pixels between icons (before SCALE_FACTOR)

return ecs.builder()
    :name("system.ui.draw")
    :group(stages.DRAW)
    :include(health.current, health.max)
    :include(shield.current, shield.max)
    :execute(function(chunk, entity_list, entity_count)
        local hp, hp_max, sh, sh_max = chunk:components(
            health.current, health.max,
            shield.current, shield.max
        )

        local pad  = PADDING * SCALE_FACTOR
        local step = (ICON_SIZE + GAP) * SCALE_FACTOR
        local row2 = pad + (ICON_SIZE + GAP) * SCALE_FACTOR

        for i = 1, entity_count do
            -- Hearts (top row)
            for h = 1, hp_max[i] do
                local quad = h <= hp[i] and HEART_FULL or HEART_EMPTY
                love.graphics.draw(misc.sheet, misc.quads[quad], pad + (h - 1) * step, pad, 0, SCALE_FACTOR, SCALE_FACTOR)
            end

            -- Shields (row below hearts)
            for s = 1, sh_max[i] do
                local quad = s <= sh[i] and SHIELD_FULL or SHIELD_EMPTY
                love.graphics.draw(misc.sheet, misc.quads[quad], pad + (s - 1) * step, row2, 0, SCALE_FACTOR, SCALE_FACTOR)
            end
        end
    end):spawn()
