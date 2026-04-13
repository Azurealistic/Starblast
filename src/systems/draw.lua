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
    :name("system.draw")
    :group(stages.DRAW)
    :include(position.x, position.y)
    :include(sprite)
    :include(size)
    :execute(function(chunk, entity_list, entity_count)
        local px, py = chunk:components(position.x, position.y)
        local sprites = chunk:components(sprite)
        local size = chunk:components(size)

        for i = 1, entity_count do
            if size == 0 then
                love.graphics.draw(ships.sheet, ships.small[sprites[i]], px[i], py[i], 0, SCALE_FACTOR, SCALE_FACTOR)
            elseif size == 1 then
                love.graphics.draw(ships.sheet, ships.large[sprites[i]], px[i], py[i], 0, SCALE_FACTOR, SCALE_FACTOR)
            end
        end
    end):spawn()
