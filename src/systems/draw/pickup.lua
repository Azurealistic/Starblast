local ecs = require "libs.evolved"

local stages      = require "groups.stages"
local position    = require "fragments.position"
local pickup      = require "fragments.pickup"
local pickup_type = require "fragments.pickup_type"
local misc        = require "sprites.misc"

return ecs.builder()
    :name("system.pickup.draw")
    :group(stages.DRAW)
    :include(pickup, position.x, position.y, pickup_type.id)
    :execute(function(chunk, _, entity_count)
        local px, py, ptype = chunk:components(position.x, position.y, pickup_type.id)

        for i = 1, entity_count do
            local quad_idx = pickup_type.QUADS[ptype[i]]
            if quad_idx and misc.quads[quad_idx] then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(
                    misc.sheet, misc.quads[quad_idx],
                    px[i], py[i], 0, SCALE_FACTOR, SCALE_FACTOR)
            end
        end
    end):spawn()
