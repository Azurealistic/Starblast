local ecs = require "libs.evolved"

local position     = require "fragments.position"
local velocity     = require "fragments.velocity"
local speed        = require "fragments.speed"
local health       = require "fragments.health"
local damage       = require "fragments.damage"
local sprite       = require "fragments.sprite"
local interactable = require "fragments.interactable"
local enemy_frag   = require "fragments.enemy"
local cooldown     = require "fragments.cooldown"
local spawn_grace  = require "fragments.spawn_grace"

local enemy = ecs.builder()
    :name("entities.enemy")
    :set(interactable)
    :set(enemy_frag)
    :set(position.x)
    :set(position.y)
    :set(velocity.x, 0)
    :set(velocity.y, 0)
    :set(speed, 0)
    :set(health.current, 1)
    :set(health.max, 1)
    :set(damage, 1)
    :set(sprite.base, 4)
    :set(sprite.direction, 0)
    :set(cooldown, 0)
    :set(spawn_grace)

return enemy
