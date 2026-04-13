local ecs = require "libs.evolved"

local position       = require "fragments.position"
local velocity       = require "fragments.velocity"
local speed          = require "fragments.speed"
local damage         = require "fragments.damage"
local projectile_frag = require "fragments.projectile"

-- Projectile template: actual position/velocity are set at spawn time by
-- the shooting system. speed is stored so type-specific logic can read it.
local projectile = ecs.builder()
    :name("entities.projectile")
    :set(position.x)
    :set(position.y)
    :set(velocity.x)
    :set(velocity.y)
    :set(speed)
    :set(damage)
    :set(projectile_frag.id)

return projectile
