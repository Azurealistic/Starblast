local ecs = require "libs.evolved"

local health = require "fragments.health"
local position = require "fragments.position"
local interactor = require "fragments.interactor"
local velocity = require "fragments.velocity"
local controllable = require "fragments.controllable"
local speed = require "fragments.speed"
local shield = require "fragments.shield"
local sprite = require "fragments.sprite"
local size = require "fragments.size"
local score = require "fragments.score"
local projectile = require "fragments.projectile"

local player = ecs.builder()
    :name("entities.player")
    :set(controllable)
    :set(interactor)
    :set(position.x, (GAME_WIDTH / 2 * SCALE_FACTOR) - (4 * SCALE_FACTOR)) -- We set this initial position based off the position of the scale factor and such!
    :set(position.y, (GAME_HEIGHT * .9 * SCALE_FACTOR) - (4 * SCALE_FACTOR))
    :set(velocity.x)
    :set(velocity.y)
    :set(speed)
    :set(health.current, 3)
    :set(health.max, 3)
    :set(shield.current, 3)
    :set(shield.max, 3)
    :set(sprite.base)
    :set(sprite.direction)
    :set(size)
    :set(score)
    :set(projectile.id, projectile.BASIC)

return player
