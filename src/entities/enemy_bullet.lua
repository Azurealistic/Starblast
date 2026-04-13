local ecs = require "libs.evolved"

local position      = require "fragments.position"
local velocity      = require "fragments.velocity"
local speed         = require "fragments.speed"
local damage        = require "fragments.damage"
local projectile    = require "fragments.projectile"
local enemy_bullet  = require "fragments.enemy_bullet"

local enemy_bullet_ent = ecs.builder()
    :name("entities.enemy_bullet")
    :set(enemy_bullet)          -- marks this as an enemy projectile
    :set(projectile.id, projectile.BASIC)
    :set(position.x)
    :set(position.y)
    :set(velocity.x, 0)
    :set(velocity.y, 0)
    :set(speed, 0)
    :set(damage, 1)

return enemy_bullet_ent
