local ecs = require "libs.evolved"

local position    = require "fragments.position"
local velocity    = require "fragments.velocity"
local pickup      = require "fragments.pickup"
local pickup_type = require "fragments.pickup_type"

local FALL_SPEED = 60  -- screen pixels/sec (slow drift downward)

local pickup_ent = ecs.builder()
    :name("entities.pickup")
    :set(pickup)
    :set(pickup_type.id, 0)
    :set(position.x,  0)
    :set(position.y,  0)
    :set(velocity.x,  0)
    :set(velocity.y,  FALL_SPEED)

return pickup_ent
