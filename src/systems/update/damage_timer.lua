local ecs          = require "libs.evolved"
local stages       = require "groups.stages"
local deltatime    = require "fragments.deltatime"
local controllable = require "fragments.controllable"
local player_state = require "player_state"

-- Runs once per frame (matches only the player entity via controllable).
-- Decrements the plain-Lua invulnerability timer; no ECS writes needed.
return ecs.builder()
    :name("system.damage_timer.update")
    :group(stages.UPDATE)
    :include(controllable)
    :execute(function(_, _, _)
        local dt = ecs.get(deltatime, deltatime)
        if player_state.invuln > 0 then
            player_state.invuln = math.max(0, player_state.invuln - dt)
        end
        if player_state.double_shoot > 0 then
            player_state.double_shoot = math.max(0, player_state.double_shoot - dt)
        end
    end):spawn()
