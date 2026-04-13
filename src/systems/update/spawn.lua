local ecs = require "libs.evolved"

local stages       = require "groups.stages"
local deltatime    = require "fragments.deltatime"
local position     = require "fragments.position"
local velocity     = require "fragments.velocity"
local speed        = require "fragments.speed"
local sprite       = require "fragments.sprite"
local score        = require "fragments.score"
local controllable = require "fragments.controllable"

local cooldown  = require "fragments.cooldown"
local enemy_ent = require "entities.enemy"

local SPAWN_INTERVAL_BASE = 5.0   -- seconds between spawns at score 0
local SPAWN_INTERVAL_MIN  = 0.35  -- fastest spawn rate (fully scaled)
local ENEMY_SPEED_BASE    = 300    -- pixels/sec downward at score 0
local ENEMY_SPEED_MAX     = 1000   -- pixels/sec downward when fully scaled

local ENEMY_SPRITES = {  5,  6,  7,  8,  9, 10, 
                        15, 16, 17, 18, 19, 20, 
                        25, 26, 27, 28, 29, 30, 
                        35, 36, 37, 38, 39, 40,
                        45, 46, 47, 48, 49, 50,
                        55, 56, 57, 58, 59, 60,
                    }

local spawn_timer = 0

-- Matches the player entity (always present), giving us live score for scaling.
return ecs.builder()
    :name("system.spawn.update")
    :group(stages.UPDATE)
    :include(controllable, score)
    :execute(function(chunk, entity_list, entity_count)
        local dt = ecs.get(deltatime, deltatime)
        local scores = chunk:components(score)

        spawn_timer = spawn_timer + dt

        local current_score = (entity_count > 0) and scores[1] or 0
        local difficulty     = math.min(current_score / 10000, 1)
        local spawn_interval = SPAWN_INTERVAL_BASE
            - (SPAWN_INTERVAL_BASE - SPAWN_INTERVAL_MIN) * difficulty

        if spawn_timer < spawn_interval then return end
        spawn_timer = 0

        -- Pick a random horizontal position flush inside the screen width.
        local sprite_px  = 8 * SCALE_FACTOR
        local screen_w   = GAME_WIDTH * SCALE_FACTOR
        local ex = math.random(0, screen_w - sprite_px)
        local ey = -sprite_px   -- just above the visible area

        local enemy_speed = ENEMY_SPEED_BASE
            + (ENEMY_SPEED_MAX - ENEMY_SPEED_BASE) * difficulty

        local e = enemy_ent:spawn()
        ecs.set(e, position.x,       ex)
        ecs.set(e, position.y,       ey)
        ecs.set(e, velocity.x,       0)
        ecs.set(e, velocity.y,       enemy_speed)
        ecs.set(e, speed,            enemy_speed)
        ecs.set(e, sprite.base,      ENEMY_SPRITES[math.random(#ENEMY_SPRITES)])
        ecs.set(e, sprite.direction, 0)
        -- Random initial cooldown so enemies don't all fire at the same time.
        ecs.set(e, cooldown, math.random() * 2.0)
    end):spawn()
