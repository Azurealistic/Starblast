local ecs = require "libs.evolved"

local stages          = require "groups.stages"
local position        = require "fragments.position"
local projectile = require "fragments.projectile"

-- Margin in screen pixels beyond the visible area before a projectile is
-- destroyed.  A small buffer prevents a visible pop when a bullet clips the edge.
local MARGIN = 16

return ecs.builder()
    :name("system.projectile.update")
    :group(stages.UPDATE)
    :include(projectile, position.x, position.y)
    :execute(function(chunk, entity_list, entity_count)
        local px, py, ptype = chunk:components(position.x, position.y, projectile)

        local screen_w = GAME_WIDTH  * SCALE_FACTOR
        local screen_h = GAME_HEIGHT * SCALE_FACTOR

        -- Collect off-screen entities first; never modify the list mid-loop.
        local to_destroy = {}
        for i = 1, entity_count do
            if  px[i] < -MARGIN
             or px[i] > screen_w + MARGIN
             or py[i] < -MARGIN
             or py[i] > screen_h + MARGIN
            then
                to_destroy[#to_destroy + 1] = entity_list[i]
            end

            -- Type-specific behaviour hook: extend here for new projectile types.
            -- e.g. if ptype[i] == 2 then add homing logic end
        end

        for _, entity in ipairs(to_destroy) do
            ecs.destroy(entity)
        end
    end):spawn()
