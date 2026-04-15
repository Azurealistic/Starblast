local ecs = require "libs.evolved"

local stages          = require "groups.stages"
local position        = require "fragments.position"
local explosion_timer = require "fragments.explosion_timer"
local misc            = require "sprites.misc"

-- Quad indices in misc.png (row 7, cols 10–13 — orange explosion frames)
local FRAMES    = { 88, 89, 90, 91 }
local FRAME_DUR = 0.08

return ecs.builder()
    :name("system.explosion.draw")
    :group(stages.DRAW)
    :include(position.x, position.y, explosion_timer)
    :execute(function(chunk, _, entity_count)
        local px, py, timer = chunk:components(position.x, position.y, explosion_timer)

        for i = 1, entity_count do
            local frame = math.min(math.floor(timer[i] / FRAME_DUR) + 1, #FRAMES)
            love.graphics.draw(
                misc.sheet,
                misc.quads[FRAMES[frame]],
                px[i], py[i],
                0,
                SCALE_FACTOR, SCALE_FACTOR
            )
        end
    end):spawn()
