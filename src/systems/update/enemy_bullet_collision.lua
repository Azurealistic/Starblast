local ecs = require "libs.evolved"

local stages       = require "groups.stages"
local position     = require "fragments.position"
local health       = require "fragments.health"
local shield       = require "fragments.shield"
local damage       = require "fragments.damage"
local interactor   = require "fragments.interactor"
local score        = require "fragments.score"
local enemy_bullet = require "fragments.enemy_bullet"

-- AABB test matching the 8-game-pixel sprite size used everywhere.
local function aabb(ax, ay, bx, by)
    local s = 8 * SCALE_FACTOR
    return ax < bx + s and ax + s > bx
       and ay < by + s and ay + s > by
end

-- Query to snapshot live player data each frame in the prologue.
local player_query = ecs.builder()
    :include(interactor, position.x, position.y, health.current, shield.current)
    :spawn()

-- Frame-level scratch state.
local frame_players = {}   -- { entity, x, y, hp, sh, changed }
local bullets_dead  = {}   -- bullet entities to destroy this frame

return ecs.builder()
    :name("system.enemy_bullet_collision.update")
    :group(stages.UPDATE)
    :include(enemy_bullet, position.x, position.y, damage)
    :prologue(function()
        frame_players = {}
        bullets_dead  = {}

        for pchunk, pentity_list, pentity_count in ecs.execute(player_query) do
            local ppx, ppy, php, psh = pchunk:components(
                position.x, position.y, health.current, shield.current)
            for k = 1, pentity_count do
                frame_players[#frame_players + 1] = {
                    entity  = pentity_list[k],
                    x       = ppx[k],
                    y       = ppy[k],
                    hp      = php[k],
                    sh      = psh[k],
                    changed = false,
                }
            end
        end
    end)
    :execute(function(chunk, entity_list, entity_count)
        local bx, by, bdmg = chunk:components(position.x, position.y, damage)

        for i = 1, entity_count do
            for _, p in ipairs(frame_players) do
                if aabb(bx[i], by[i], p.x, p.y) then
                    -- Shields absorb hits before health.
                    if p.sh > 0 then
                        p.sh = p.sh - bdmg[i]
                    else
                        p.hp = p.hp - bdmg[i]
                    end
                    p.changed = true
                    bullets_dead[#bullets_dead + 1] = entity_list[i]
                    break  -- one bullet hits one player at most
                end
            end
        end
    end)
    :epilogue(function()
        for _, p in ipairs(frame_players) do
            if p.changed then
                ecs.set(p.entity, health.current, math.max(0, p.hp))
                ecs.set(p.entity, shield.current, math.max(0, p.sh))
            end
        end

        for _, e in ipairs(bullets_dead) do
            if ecs.alive(e) then ecs.destroy(e) end
        end
    end):spawn()
