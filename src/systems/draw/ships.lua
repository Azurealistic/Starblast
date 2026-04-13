local ecs = require("libs.evolved")

-- ECS Related Imports:
local stages = require("groups.stages")

-- Fragments related to drawing:
local position     = require("fragments.position")
local sprite       = require("fragments.sprite")
local controllable = require("fragments.controllable")

-- Art related imports:
local ships = require "sprites.ships"

return ecs.builder()
    :name("system.ships.draw")
    :group(stages.DRAW)
    :include(position.x, position.y, sprite.base, controllable)
    :execute(function(chunk, entity_list, entity_count)
        local px, py, image, direction = chunk:components(position.x, position.y, sprite.base, sprite.direction)

        for i = 1, entity_count do
            love.graphics.draw(ships.sheet, ships.small[image[i] + direction[i]], px[i], py[i], 0, SCALE_FACTOR, SCALE_FACTOR)
        end
    end):spawn()
