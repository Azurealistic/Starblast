local ecs = require "libs.evolved"

local position        = require "fragments.position"
local explosion_timer = require "fragments.explosion_timer"

local explosion = ecs.builder()
    :name("entities.explosion")
    :set(position.x)
    :set(position.y)
    :set(explosion_timer)

return explosion
