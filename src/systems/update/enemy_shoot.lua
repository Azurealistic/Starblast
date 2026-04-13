local ecs = require "libs.evolved"

local stages          = require "groups.stages"
local deltatime       = require "fragments.deltatime"
local position        = require "fragments.position"
local velocity        = require "fragments.velocity"
local speed           = require "fragments.speed"
local damage          = require "fragments.damage"
local projectile      = require "fragments.projectile"
local enemy_frag      = require "fragments.enemy"
local cooldown        = require "fragments.cooldown"

local enemy_bullet_ent = require "entities.enemy_bullet"

local SHOOT_COOLDOWN  = 2.0    -- seconds between shots per enemy
local BULLET_SPEED    = 400    -- pixels/sec downward
local BULLET_DAMAGE   = 1

-- Horizontal centering offset: enemy sprite is 8 game-px wide, bullet is also
-- 8 game-px wide, so a 0-offset aligns their left edges. No centering needed
-- because both are the same width.
local SPRITE_PX = 8 * SCALE_FACTOR

return ecs.builder()
    :name("system.enemy_shoot.update")
    :group(stages.UPDATE)
    :include(enemy_frag, position.x, position.y, cooldown)
    :execute(function(chunk, entity_list, entity_count)
        local dt = ecs.get(deltatime, deltatime)
        local ex, ey, ec = chunk:components(position.x, position.y, cooldown)

        for i = 1, entity_count do
            ec[i] = ec[i] - dt

            if ec[i] <= 0 then
                ec[i] = SHOOT_COOLDOWN

                -- Fire a bullet from the bottom-centre of the enemy sprite.
                local bx = ex[i]
                local by = ey[i] + SPRITE_PX

                local b = enemy_bullet_ent:spawn()
                ecs.set(b, position.x,    bx)
                ecs.set(b, position.y,    by)
                ecs.set(b, velocity.x,    0)
                ecs.set(b, velocity.y,    BULLET_SPEED)
                ecs.set(b, speed,         BULLET_SPEED)
                ecs.set(b, damage,        BULLET_DAMAGE)
                ecs.set(b, projectile.id, projectile.DENSE)
            end
        end
    end):spawn()
