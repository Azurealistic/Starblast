-- Game State
-- All of the logic and various gameplay related stuff will happen in this file.

-- Imports:
local ecs = require "libs.evolved"

-- Game State:
local game = {}

-- FSM Hooked functionality which auto runs during loop!
function game:enter()
    print("Entering game state!")
end

function game:update(dt)
end

function game:draw()
end

function game:leave()
    print("Leaving game state!")
end

return game