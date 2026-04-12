-- Starblast: Entrypoint

-- Disable requirement to include "src" when performing imports.
love.filesystem.setRequirePath(love.filesystem.getRequirePath() .. ";src/?.lua")

-- Libraries:
local fsm = require "libs.gamestate"
local ecs = require "libs.evolved"

-- Enable debugging features for various libraries if they have any.
ecs.debug_mode(true)

-- States:
local game = require "states.game"

-- Initalize the game.
function love.load()
    fsm.registerEvents() -- Register all events to be processed by the FSM.
    fsm.switch(game)   -- Switch to the initial state.
end

-- Everything else is handled in the gameplay loop and called automatically via the FSM.