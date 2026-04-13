local ecs = require "libs.evolved"

local stages          = require "groups.stages"
local position        = require "fragments.position"
local projectile = require "fragments.projectile"
local projectiles     = require "sprites.projectiles"

return ecs.builder()
    :name("system.projectile.draw")
    :group(stages.DRAW)
    :include(projectile.id, position.x, position.y)
    :execute(function(chunk, entity_list, entity_count)
        local px, py, ptype = chunk:components(position.x, position.y, projectile.id)

        for i = 1, entity_count do
            local quad = projectiles.quads[ptype[i]]
            if quad then
                love.graphics.draw(
                    projectiles.sheet, quad,
                    px[i], py[i],
                    0, SCALE_FACTOR, SCALE_FACTOR
                )
            end
        end
    end):spawn()
