local ecs = require("libs.evolved")

-- ECS Related Imports:
local stages = require("groups.stages")

-- Fragments related to drawing:
local position = require("fragments.position")
local sprite = require("fragments.sprite")
local size = require("fragments.size")

-- Art related imports:
local ships = require "sprites.ships"

return ecs.builder()
    :name("system.ships.draw")
    :group(stages.DRAW)
    :include(position.x, position.y)
    :include(sprite.base)
    :include(size)
    :execute(function(chunk, entity_list, entity_count)
        local px, py, image, direction, size = chunk:components(position.x, position.y, sprite.base, sprite.direction, size)

        for i = 1, entity_count do
            if size[i] == 0 then
                love.graphics.draw(ships.sheet, ships.small[image[i] + direction[i]], px[i], py[i], 0, SCALE_FACTOR, SCALE_FACTOR)
            elseif size[i] == 1 then
                love.graphics.draw(ships.sheet, ships.large[image[i] + direction[i]], px[i], py[i], 0, SCALE_FACTOR, SCALE_FACTOR)
            end
        end
    end):spawn()
