local ecs = require "libs.evolved"

local health = require "fragments.health"
local position = require "fragments.position"
local interactor = require "fragments.interactor"
local velocity = require "fragments.velocity"
local controllable = require "fragments.controllable"
local speed = require "fragments.speed"
local shield = require "fragments.shield"
local sprite = require "fragments.sprite"

local player = ecs.builder()
    :name("entities.player")
    :set(controllable)
    :set(interactor)
    :set(position.x, 0)
    :set(position.y, 0)
    :set(velocity.x, 0)
    :set(velocity.y, 0)
    :set(speed, 0)
    :set(health.current, 3)
    :set(health.max, 3)
    :set(shield.current, 3)
    :set(shield.max, 3)
    :set(sprite)

return player
