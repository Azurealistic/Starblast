local ecs = require "libs.evolved"

local stages       = require "groups.stages"
local position     = require "fragments.position"
local health       = require "fragments.health"
local shield       = require "fragments.shield"
local damage       = require "fragments.damage"
local interactable   = require "fragments.interactable"
local interactor     = require "fragments.interactor"
local projectile     = require "fragments.projectile"
local score          = require "fragments.score"
local enemy_bullet   = require "fragments.enemy_bullet"
local spawn_grace    = require "fragments.spawn_grace"
local explosion_timer = require "fragments.explosion_timer"
local explosion_ent   = require "entities.explosion"
local pickup_type_frag = require "fragments.pickup_type"
local pickup_ent       = require "entities.pickup"
local player_state    = require "player_state"

-- AABB test: both sprites are treated as (8 * SCALE_FACTOR) squares.
local function aabb(ax, ay, bx, by)
    local s = 8 * SCALE_FACTOR
    return ax < bx + s and ax + s > bx
       and ay < by + s and ay + s > by
end

-- Standalone queries used inside prologue to collect live bullets / player data
-- before the per-chunk execute callbacks run.
-- Enemy bullets are excluded so they never accidentally damage enemies.
local bullet_query = ecs.builder()
    :include(projectile.id, position.x, position.y, damage)
    :exclude(enemy_bullet)
    :spawn()

local player_query = ecs.builder()
    :include(interactor, position.x, position.y, health.current, shield.current, score)
    :spawn()

-- Frame-level scratch tables (reset each prologue, consumed in execute + epilogue).
local frame_bullets  = {}   -- { entity, x, y, damage, used }
local frame_players  = {}   -- { entity, x, y, hp, sh, score_val, changed }
local kills          = {}   -- enemy entity → true  (deduplication guard)
local bullets_dead   = {}   -- bullet entities to destroy
local enemies_dead   = {}   -- enemy entities to destroy

-- Weighted drop table: {type, weight}.
local DROP_TABLE = {
    { t = pickup_type_frag.COIN_100,     w = 40 },
    { t = pickup_type_frag.COIN_200,     w = 30 },
    { t = pickup_type_frag.COIN_300,     w = 20 },
    { t = pickup_type_frag.COIN_400,     w = 10 },
    { t = pickup_type_frag.HEART,        w = 10  },
    { t = pickup_type_frag.SHIELD,       w = 15  },
    { t = pickup_type_frag.BOOST,        w = 30  },
    { t = pickup_type_frag.AMMO,         w = 20  },
    { t = pickup_type_frag.DOUBLE_SHOOT, w = 10  },
}
local DROP_TOTAL = 0
for _, entry in ipairs(DROP_TABLE) do
    DROP_TOTAL = DROP_TOTAL + entry.w
end
local DROP_CHANCE = 0.35   -- 35% chance an enemy drops anything on death

local function pick_drop()
    local r = math.random() * DROP_TOTAL
    local acc = 0
    for _, entry in ipairs(DROP_TABLE) do
        acc = acc + entry.w
        if r <= acc then return entry.t end
    end
    return pickup_type_frag.COIN_100
end

return ecs.builder()
    :name("system.collision.update")
    :group(stages.UPDATE)
    :include(interactable, position.x, position.y, health.current, damage, spawn_grace)

    :prologue(function()
        frame_bullets = {}
        frame_players = {}
        kills         = {}
        bullets_dead  = {}
        enemies_dead  = {}

        -- Collect every live bullet this frame.
        for bchunk, bentity_list, bentity_count in ecs.execute(bullet_query) do
            local bx, by, bdmg = bchunk:components(position.x, position.y, damage)
            for j = 1, bentity_count do
                frame_bullets[#frame_bullets + 1] = {
                    entity = bentity_list[j],
                    x      = bx[j],
                    y      = by[j],
                    damage = bdmg[j],
                    used   = false,
                }
            end
        end

        -- Collect player data (typically a single entity).
        for pchunk, pentity_list, pentity_count in ecs.execute(player_query) do
            local ppx, ppy, php, psh, psc = pchunk:components(
                position.x, position.y, health.current, shield.current, score)
            for k = 1, pentity_count do
                frame_players[#frame_players + 1] = {
                    entity    = pentity_list[k],
                    x         = ppx[k],
                    y         = ppy[k],
                    hp        = php[k],
                    sh        = psh[k],
                    score_val = psc[k],
                    changed   = false,
                }
            end
        end
    end)

    :execute(function(chunk, entity_list, entity_count)
        local ex, ey, eh, edamage, egrace = chunk:components(
            position.x, position.y, health.current, damage, spawn_grace)

        local screen_h = GAME_HEIGHT * SCALE_FACTOR
        local margin   = 16 * SCALE_FACTOR

        for i = 1, entity_count do
            local eid = entity_list[i]

            -- Skip enemies already marked as dead this frame.
            if kills[eid] then goto continue end

            -- Cull enemies that have fallen past the bottom of the screen.
            if ey[i] > screen_h + margin then
                kills[eid] = true
                enemies_dead[#enemies_dead + 1] = eid
                goto continue
            end

            -- ---- Bullet → enemy collision ---- --
            if egrace[i] > 0 then goto continue end
            for _, b in ipairs(frame_bullets) do
                if not b.used and aabb(ex[i], ey[i], b.x, b.y) then
                    eh[i]  = eh[i] - b.damage
                    b.used = true
                    bullets_dead[#bullets_dead + 1] = b.entity

                    if eh[i] <= 0 then
                        kills[eid] = true
                        enemies_dead[#enemies_dead + 1] = eid
                        -- Award 100 score per kill, plus a 25% chance of +0–50 bonus.
                        for _, p in ipairs(frame_players) do
                            p.score_val = p.score_val + 100
                            if math.random() < 0.25 then
                                p.score_val = p.score_val + math.random(0, 50)
                            end
                            p.changed = true
                        end
                        break
                    end
                end
            end

            -- ---- Enemy → player collision ---- --
            if not kills[eid] then
                for _, p in ipairs(frame_players) do
                    if aabb(ex[i], ey[i], p.x, p.y) then
                        -- Damage only lands when the player is not invulnerable.
                        if player_state.invuln <= 0 then
                            if p.sh > 0 then
                                p.sh = p.sh - edamage[i]
                            else
                                p.hp = p.hp - edamage[i]
                            end
                            player_state.invuln = 0.5
                            p.changed = true
                        end
                        -- Enemy is always destroyed on contact.
                        kills[eid] = true
                        enemies_dead[#enemies_dead + 1] = eid
                        break
                    end
                end
            end

            ::continue::
        end
    end)

    :epilogue(function()
        for _, p in ipairs(frame_players) do
            if p.changed then
                ecs.set(p.entity, health.current, math.max(0, p.hp))
                ecs.set(p.entity, shield.current, math.max(0, p.sh))
                ecs.set(p.entity, score,          p.score_val)
            end
        end

        for _, e in ipairs(bullets_dead) do
            if ecs.alive(e) then ecs.destroy(e) end
        end

        -- Spawn explosion, maybe drop a pickup, then destroy each dead enemy.
        for _, e in ipairs(enemies_dead) do
            if ecs.alive(e) then
                local ex = ecs.get(e, position.x)
                local ey = ecs.get(e, position.y)
                if ex and ey then
                    local exp = explosion_ent:spawn()
                    ecs.set(exp, position.x,      ex)
                    ecs.set(exp, position.y,      ey)
                    ecs.set(exp, explosion_timer, 0)

                    if math.random() < DROP_CHANCE then
                        local pu = pickup_ent:spawn()
                        ecs.set(pu, position.x,      ex)
                        ecs.set(pu, position.y,      ey)
                        ecs.set(pu, pickup_type_frag.id, pick_drop())
                    end
                end
                ecs.destroy(e)
            end
        end
    end):spawn()
