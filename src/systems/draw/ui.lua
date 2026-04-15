local ecs = require("libs.evolved")

-- ECS Related Imports:
local stages = require("groups.stages")

-- Fragments:
local health = require("fragments.health")
local shield = require("fragments.shield")
local energy = require("fragments.energy")
local score  = require("fragments.score")
local ammo   = require("fragments.ammo")

-- Art:
local misc = require "sprites.misc"

-- Fonts:
local score_font = love.graphics.newFont("assets/fonts/80s-retro-future.ttf", 32)

-- High score:
local highscore = require "highscore"

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
    :include(ammo.current, ammo.max)
    :execute(function(chunk, _, entity_count)
        local hp, hp_max, sh, sh_max, en, en_max, score_val, ammo_cur, ammo_max = chunk:components(
            health.current, health.max,
            shield.current, shield.max,
            energy.current, energy.max,
            score,
            ammo.current, ammo.max
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

        -- Blue pulse for ammo bar
        local bp = (math.sin(t * 4) + 1) / 2
        local br = 0.10 + 0.15 * bp
        local bg = 0.40 + 0.20 * bp
        local bb = 0.95 + 0.05 * bp

        local seg_h    = SCALE_FACTOR * 2
        local ammo_y   = screen_h - bar_h - seg_h - SCALE_FACTOR

        for i = 1, entity_count do
            -- Hearts (top row)
            for h = 1, hp_max[i] do
                local x = pad + (h - 1) * step
                local quad = h <= hp[i] and HEART_FULL or HEART_EMPTY
                love.graphics.draw(misc.sheet, misc.quads[quad], x, pad, 0, SCALE_FACTOR, SCALE_FACTOR)
            end

            -- Shields (row below hearts)
            for s = 1, sh_max[i] do
                local x = pad + (s - 1) * step
                local quad = s <= sh[i] and SHIELD_FULL or SHIELD_EMPTY
                love.graphics.draw(misc.sheet, misc.quads[quad], x, row2, 0, SCALE_FACTOR, SCALE_FACTOR)
            end

            -- Energy bar (bottom of screen, depletes right to left)
            local ratio = en_max[i] > 0 and (en[i] / en_max[i]) or 0
            love.graphics.setColor(r, g, b, 1)
            love.graphics.rectangle("fill", 0, screen_h - bar_h, screen_w * ratio, bar_h)
            love.graphics.setColor(1, 1, 1, 1)

            -- Ammo bar — segmented, blue/glowing, above energy bar
            local max_a   = ammo_max[i] > 0 and ammo_max[i] or 1
            local slot_w  = screen_w / max_a
            local seg_w   = slot_w - 2
            for seg = 1, max_a do
                local sx = (seg - 1) * slot_w + 1
                if seg <= ammo_cur[i] then
                    -- Glow halo
                    love.graphics.setColor(br * 0.5, bg * 0.5, bb, 0.25)
                    love.graphics.rectangle("fill", sx - 1, ammo_y - 1, seg_w + 2, seg_h + 2)
                    -- Solid segment
                    love.graphics.setColor(br, bg, bb, 1)
                    love.graphics.rectangle("fill", sx, ammo_y, seg_w, seg_h)
                else
                    -- Empty slot
                    love.graphics.setColor(0.04, 0.08, 0.25, 0.6)
                    love.graphics.rectangle("fill", sx, ammo_y, seg_w, seg_h)
                end
            end
            love.graphics.setColor(1, 1, 1, 1)

            -- Score (top-right corner)
            local prev_font = love.graphics.getFont()
            love.graphics.setFont(score_font)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf(tostring(score_val[i]), 0, pad, screen_w - pad, "right")
            -- High score just below, in muted gold
            love.graphics.setColor(0.85, 0.65, 0.1, 0.75)
            love.graphics.printf(tostring(highscore.get()), 0, pad + 36, screen_w - pad, "right")
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setFont(prev_font)
        end
    end):spawn()
