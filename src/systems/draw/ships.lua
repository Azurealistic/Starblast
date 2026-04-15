local ecs = require("libs.evolved")

-- ECS Related Imports:
local stages = require("groups.stages")

-- Fragments related to drawing:
local position     = require("fragments.position")
local sprite       = require("fragments.sprite")
local controllable = require("fragments.controllable")

-- Shared player state for invulnerability blink:
local player_state = require "player_state"

-- Art related imports:
local ships = require "sprites.ships"

return ecs.builder()
    :name("system.ships.draw")
    :group(stages.DRAW)
    :include(position.x, position.y, sprite.base, controllable)
    :execute(function(chunk, _, entity_count)
        local px, py, image, direction =
            chunk:components(position.x, position.y, sprite.base, sprite.direction)

        for i = 1, entity_count do
            -- Blink ~10 times/sec while invulnerable.
            if player_state.invuln > 0 and math.floor(love.timer.getTime() * 10) % 2 == 0 then
                goto continue
            end
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(ships.sheet, ships.small[image[i] + direction[i]], px[i], py[i], 0, SCALE_FACTOR, SCALE_FACTOR)
            ::continue::
        end
    end):spawn()
