local ecs = require("libs.evolved")

-- ECS Related Imports:
local stages = require("groups.stages")

-- Fragments:
local health = require("fragments.health")
local shield = require("fragments.shield")
local energy = require("fragments.energy")
local score  = require("fragments.score")

-- Art:
local misc = require "sprites.misc"

-- Fonts:
local score_font = love.graphics.newFont("assets/fonts/80s-retro-future.ttf", 32)

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
    :include(energy.current, energy.max)
    :include(score)
    :execute(function(chunk, entity_list, entity_count)
        local hp, hp_max, shield, shield_max, energy, energy_max, score_val = chunk:components(
            health.current, health.max,
            shield.current, shield.max,
            energy.current, energy.max,
            score
        )

        local pad       = PADDING * SCALE_FACTOR
        local step      = (ICON_SIZE + GAP) * SCALE_FACTOR
        local row2      = pad + (ICON_SIZE + GAP) * SCALE_FACTOR
        local bar_h     = SCALE_FACTOR  -- actual drawn height (screen_h - bar_h puts it flush)
        local screen_w  = GAME_WIDTH * SCALE_FACTOR
        local screen_h  = GAME_HEIGHT * SCALE_FACTOR

        -- Animated pulse: cycles through bright green <-> lime <-> teal
        local t = love.timer.getTime()
        local p = (math.sin(t * 4) + 1) / 2   -- 0..1 at ~4 rad/s
        local r = 0.05 + 0.25 * p
        local g = 0.75 + 0.25 * p
        local b = 0.10 + 0.30 * p

        for i = 1, entity_count do
            -- Hearts (top row)
            for h = 1, hp_max[i] do
                local x = pad + (h - 1) * step
                local quad = h <= hp[i] and HEART_FULL or HEART_EMPTY
                love.graphics.draw(misc.sheet, misc.quads[quad], x, pad, 0, SCALE_FACTOR, SCALE_FACTOR)
            end

            -- Shields (row below hearts)
            for s = 1, shield_max[i] do
                local x = pad + (s - 1) * step
                local quad = s <= shield[i] and SHIELD_FULL or SHIELD_EMPTY
                love.graphics.draw(misc.sheet, misc.quads[quad], x, row2, 0, SCALE_FACTOR, SCALE_FACTOR)
            end

            -- Energy bar (bottom of screen, depletes right to left)
            local ratio = energy_max[i] > 0 and (energy[i] / energy_max[i]) or 0
            love.graphics.setColor(r, g, b, 1)
            love.graphics.rectangle("fill", 0, screen_h - bar_h, screen_w * ratio, bar_h)
            love.graphics.setColor(1, 1, 1, 1)

            -- Score (top-right corner)
            local prev_font = love.graphics.getFont()
            love.graphics.setFont(score_font)
            love.graphics.printf(tostring(score_val[i]), 0, pad, screen_w - pad, "right")
            love.graphics.setFont(prev_font)
        end
    end):spawn()
