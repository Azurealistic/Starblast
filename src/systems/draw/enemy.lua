local ecs = require("libs.evolved")

-- ECS Related Imports:
local stages = require("groups.stages")

-- Fragments related to drawing:
local position     = require("fragments.position")
local sprite       = require("fragments.sprite")
local enemy_frag   = require("fragments.enemy")

-- Art related imports:
local ships = require "sprites.ships"

-- Enemy ships are drawn flipped vertically so they face downward.
-- With a negative sy the pivot is the top-left corner, so we offset y by the
-- sprite height (8 game pixels * SCALE_FACTOR) to keep the sprite in place.
local SPRITE_H = 8

return ecs.builder()
    :name("system.enemy.draw")
    :group(stages.DRAW)
    :include(position.x, position.y, sprite.base, enemy_frag)
    :execute(function(chunk, entity_list, entity_count)
        local px, py, image = chunk:components(position.x, position.y, sprite.base)

        for i = 1, entity_count do
            love.graphics.draw(
                ships.sheet,
                ships.small[image[i]],
                px[i],
                py[i] + SPRITE_H * SCALE_FACTOR,  -- compensate for vertical flip pivot
                0,
                SCALE_FACTOR,
                -SCALE_FACTOR  -- flip vertically so the ship faces down
            )
        end
    end):spawn()
