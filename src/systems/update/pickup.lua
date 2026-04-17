local ecs = require "libs.evolved"

local stages      = require "groups.stages"
local position    = require "fragments.position"
local health      = require "fragments.health"
local shield      = require "fragments.shield"
local energy      = require "fragments.energy"
local ammo        = require "fragments.ammo"
local score       = require "fragments.score"
local interactor  = require "fragments.interactor"
local pickup      = require "fragments.pickup"
local pickup_type = require "fragments.pickup_type"
local player_state = require "player_state"

local function aabb(ax, ay, bx, by)
    local s = 8 * SCALE_FACTOR
    return ax < bx + s and ax + s > bx
       and ay < by + s and ay + s > by
end

-- Snapshot player components once per frame before the per-chunk execute runs.
local player_query = ecs.builder()
    :include(interactor, position.x, position.y,
             health.current,  health.max,
             shield.current,  shield.max,
             energy.current,  energy.max,
             ammo.current,    ammo.max,
             score)
    :spawn()

local frame_players = {}
local pickups_dead  = {}

return ecs.builder()
    :name("system.pickup.update")
    :group(stages.UPDATE)
    :include(pickup, position.x, position.y, pickup_type.id)

    :prologue(function()
        frame_players = {}
        pickups_dead  = {}

        for pchunk, pentity_list, pentity_count in ecs.execute(player_query) do
            local ppx, ppy, php, phmax, psh, pshmax, pen, penmax, pam, pammax, psc =
                pchunk:components(
                    position.x,    position.y,
                    health.current, health.max,
                    shield.current, shield.max,
                    energy.current, energy.max,
                    ammo.current,   ammo.max,
                    score)
            for k = 1, pentity_count do
                frame_players[#frame_players + 1] = {
                    entity  = pentity_list[k],
                    x       = ppx[k],
                    y       = ppy[k],
                    hp      = php[k],  hp_max = phmax[k],
                    sh      = psh[k],  sh_max = pshmax[k],
                    en      = pen[k],  en_max = penmax[k],
                    am      = pam[k],  am_max = pammax[k],
                    sc      = psc[k],
                    changed = false,
                }
            end
        end
    end)

    :execute(function(chunk, entity_list, entity_count)
        local ppx, ppy, ptype = chunk:components(position.x, position.y, pickup_type.id)

        local screen_h = GAME_HEIGHT * SCALE_FACTOR
        local margin   = 16 * SCALE_FACTOR

        for i = 1, entity_count do
            local eid = entity_list[i]

            -- Cull pickups that have drifted off the bottom of the screen.
            if ppy[i] > screen_h + margin then
                pickups_dead[#pickups_dead + 1] = eid
                goto continue
            end

            -- Check collision with each player.
            for _, p in ipairs(frame_players) do
                if aabb(ppx[i], ppy[i], p.x, p.y) then
                    local t = ptype[i]
                    if     t == pickup_type.COIN_100     then p.sc = p.sc + 100
                    elseif t == pickup_type.COIN_200     then p.sc = p.sc + 200
                    elseif t == pickup_type.COIN_300     then p.sc = p.sc + 300
                    elseif t == pickup_type.COIN_400     then p.sc = p.sc + 400
                    elseif t == pickup_type.HEART        then p.hp = math.min(p.hp_max, p.hp + 1)
                    elseif t == pickup_type.SHIELD       then p.sh = math.min(p.sh_max, p.sh + 1)
                    elseif t == pickup_type.BOOST        then p.en = p.en_max
                    elseif t == pickup_type.AMMO         then p.am = p.am_max
                    elseif t == pickup_type.DOUBLE_SHOOT then player_state.double_shoot = 10.0
                    end
                    p.changed = true
                    pickups_dead[#pickups_dead + 1] = eid
                    break
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
                ecs.set(p.entity, energy.current, math.max(0, p.en))
                ecs.set(p.entity, ammo.current,   math.max(0, p.am))
                ecs.set(p.entity, score,          p.sc)
            end
        end

        for _, e in ipairs(pickups_dead) do
            if ecs.alive(e) then ecs.destroy(e) end
        end
    end):spawn()
