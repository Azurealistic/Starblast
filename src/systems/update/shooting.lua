local ecs = require "libs.evolved"

local stages          = require "groups.stages"
local deltatime       = require "fragments.deltatime"
local controllable    = require "fragments.controllable"
local position        = require "fragments.position"
local velocity        = require "fragments.velocity"
local speed           = require "fragments.speed"
local damage          = require "fragments.damage"
local projectile      = require "fragments.projectile"
local ammo            = require "fragments.ammo"
local projectile_ent  = require "entities.projectile"
local player_state    = require "player_state"

local SHOOT_COOLDOWN   = 0.25
local BULLET_SPEED_MUL = 1
local BULLET_DAMAGE    = 1
local REGEN_RATE       = 0.50  -- seconds per bullet

local shoot_cooldown = 0
local regen_timer    = 0

return ecs.builder()
    :name("system.shooting.update")
    :group(stages.UPDATE)
    :include(controllable, position.x, position.y, speed, projectile.id, ammo.current, ammo.max)
    :execute(function(chunk, _, entity_count)
        local dt = ecs.get(deltatime, deltatime)
        local ammo_cur, ammo_max, px, py, player_speed, ptype = chunk:components(
            ammo.current, ammo.max, position.x, position.y, speed, projectile.id)

        -- Regen 1 bullet per second, always.
        regen_timer = regen_timer + dt
        if regen_timer >= REGEN_RATE then
            regen_timer = regen_timer - REGEN_RATE
            for i = 1, entity_count do
                ammo_cur[i] = math.min(ammo_max[i], ammo_cur[i] + 1)
            end
        end

        -- Shoot.
        shoot_cooldown = shoot_cooldown + dt
        if not love.keyboard.isDown("space") or shoot_cooldown < SHOOT_COOLDOWN then
            return
        end
        shoot_cooldown = 0

        for i = 1, entity_count do
            if ammo_cur[i] <= 0 then goto continue end

            local bullet_speed = player_speed[i] * BULLET_SPEED_MUL
            local by = py[i] - (8 * SCALE_FACTOR)

            if player_state.double_shoot > 0 and ammo_cur[i] >= 2 then
                -- Double shoot: two offset bullets, costs 2 ammo.
                ammo_cur[i] = ammo_cur[i] - 2
                local offset = 4 * SCALE_FACTOR

                local p1 = projectile_ent:spawn()
                ecs.set(p1, position.x,    px[i] - offset)
                ecs.set(p1, position.y,    by)
                ecs.set(p1, velocity.x,    0)
                ecs.set(p1, velocity.y,    -bullet_speed)
                ecs.set(p1, speed,         bullet_speed)
                ecs.set(p1, damage,        BULLET_DAMAGE)
                ecs.set(p1, projectile.id, ptype[i])

                local p2 = projectile_ent:spawn()
                ecs.set(p2, position.x,    px[i] + offset)
                ecs.set(p2, position.y,    by)
                ecs.set(p2, velocity.x,    0)
                ecs.set(p2, velocity.y,    -bullet_speed)
                ecs.set(p2, speed,         bullet_speed)
                ecs.set(p2, damage,        BULLET_DAMAGE)
                ecs.set(p2, projectile.id, ptype[i])
            else
                -- Single shot.
                ammo_cur[i] = ammo_cur[i] - 1

                local proj = projectile_ent:spawn()
                ecs.set(proj, position.x,    px[i])
                ecs.set(proj, position.y,    by)
                ecs.set(proj, velocity.x,    0)
                ecs.set(proj, velocity.y,    -bullet_speed)
                ecs.set(proj, speed,         bullet_speed)
                ecs.set(proj, damage,        BULLET_DAMAGE)
                ecs.set(proj, projectile.id, ptype[i])
            end
            ::continue::
        end
    end):spawn()
