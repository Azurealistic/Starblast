local ecs = require "libs.evolved"

local stages          = require "groups.stages"
local deltatime       = require "fragments.deltatime"
local controllable    = require "fragments.controllable"
local position        = require "fragments.position"
local velocity        = require "fragments.velocity"
local speed           = require "fragments.speed"
local damage          = require "fragments.damage"
local projectile      = require "fragments.projectile"
local projectile_ent  = require "entities.projectile"
local projectiles_spr = require "sprites.projectiles"

-- How many seconds must pass between shots.
local SHOOT_COOLDOWN   = 0.15
-- Bullet speed as a multiplier of the player's current speed.
local BULLET_SPEED_MUL = 1
-- Bullet damage value.
local BULLET_DAMAGE    = 1

local cooldown = 0

return ecs.builder()
    :name("system.shooting.update")
    :group(stages.UPDATE)
    :include(controllable, position.x, position.y, speed)
    :execute(function(chunk, entity_list, entity_count)
        local dt = ecs.get(deltatime, deltatime)
        cooldown = cooldown + dt

        if not love.keyboard.isDown("space") or cooldown < SHOOT_COOLDOWN then
            return
        end
        cooldown = 0

        local px, py, player_speed = chunk:components(position.x, position.y, speed)

        for i = 1, entity_count do
            local bullet_speed = player_speed[i] * BULLET_SPEED_MUL

            -- Spawn at the horizontal centre of the ship, flush with its top edge.
            -- Ship sprite is 8 px wide at SCALE_FACTOR, so centre offset = 4 * SCALE_FACTOR.
            -- Bullet sprite is also 8 px wide, so its left edge lands at the same px.
            local bx = px[i]
            local by = py[i] - (8 * SCALE_FACTOR)

            local proj = projectile_ent:spawn()
            ecs.set(proj, position.x,       bx)
            ecs.set(proj, position.y,       by)
            ecs.set(proj, velocity.x,       0)
            ecs.set(proj, velocity.y,       -bullet_speed)
            ecs.set(proj, speed,            bullet_speed)
            ecs.set(proj, damage,           BULLET_DAMAGE)
            ecs.set(proj, projectile,  projectiles_spr.BASIC)
        end
    end):spawn()
