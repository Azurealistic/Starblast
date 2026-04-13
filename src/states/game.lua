-- Game State
-- All of the logic and various gameplay related stuff will happen in this file.

-- Imports:
local ecs = require "libs.evolved"
local camera = require "libs.camera"
local ships = require "sprites.ships"

-- ECS:
-- Utility fragments:
local deltatime = require "fragments.deltatime"
local sprite = require "fragments.sprite"
local speed = require "fragments.speed"

-- System related:
local stages = require "groups.stages"

require "systems.draw"
require "systems.input"
require "systems.physics"

-- Entities:
local player = require "entities.player"
local player_ship_ids = {2, 12, 22, 32, 42}

-- Game State:
local game = {}

-- Other variables used:
local bg_sheet
local bg_quads = {}
local speed_multipler = 2 -- This multiplier will affect everything in how fast paced the game is, allowing for it to get harder as it goes on!
local move_multipler = 200 -- This one is used alongside the speed multiplier to allow us to move our ship at a relatively good pace.

-- Parallax layers: #5 (slow, distant stars) and #6 (faster, closer stars)
local parallax = {
    { quad_idx = 5, y = 0, speed = 128 * speed_multipler },
    { quad_idx = 6, y = 0, speed = 256 * speed_multipler },
}

-- FSM Hooked functionality which auto runs during loop!
function game:enter()
    print("Entering game state!")

    -- Load the ships!
    ships.load()

    --  Load background stuff!
    bg_sheet = love.graphics.newImage("assets/backgrounds.png")
    bg_sheet:setFilter("nearest", "nearest")

    local cw, ch = 128, 256  -- cell width/height
    local sw, sh = bg_sheet:getDimensions()

    -- Number backgrounds left-to-right, top-to-bottom: #1..#3 top row, #4..#6 bottom row
    for row = 0, 1 do
        for col = 0, 2 do
            local idx = row * 3 + col + 1
            bg_quads[idx] = love.graphics.newQuad(col * cw, row * ch, cw, ch, sw, sh)
        end
    end

    -- Player initial setup!
    self.player = player:spawn() 

    -- Choose one of the random ships to pick from
    -- Set the initial ship we use!
    ecs.set(self.player, sprite.base, player_ship_ids[1])
    ecs.set(self.player, sprite.direction, 0) -- For indicating left or right movement!
    -- Set the initial speed we are allowed to move with!
    ecs.set(self.player, speed, speed_multipler * move_multipler)
end

function game:update(dt)
    -- We need a way to keep track of how much time has elapsed in the game, so we use deltatime!
    ecs.set(deltatime, deltatime, dt)

    -- Process all update systems!
    ecs.process(stages.UPDATE)

    -- Update the parallax for the background.
    local screen_h = 256 * SCALE_FACTOR
    for _, layer in ipairs(parallax) do
        layer.y = layer.y + layer.speed * dt
        if layer.y >= screen_h then
            layer.y = layer.y - screen_h
        end
    end
end

function game:draw()
    -- Figure out draw height for game!
    local screen_h = 256 * SCALE_FACTOR

    -- Background #3 (top-right): base static layer
    love.graphics.draw(bg_sheet, bg_quads[3], 0, 0, 0, SCALE_FACTOR, SCALE_FACTOR)

    -- Parallax star layers: draw twice (current + one copy above) for seamless looping
    -- Essentially the parallax layers are of height 256 * SCALE_FACTOR * 2, so it looks like they never end!
    for _, layer in ipairs(parallax) do
        local q = bg_quads[layer.quad_idx]
        love.graphics.draw(bg_sheet, q, 0, layer.y,           0, SCALE_FACTOR, SCALE_FACTOR)
        love.graphics.draw(bg_sheet, q, 0, layer.y - screen_h, 0, SCALE_FACTOR, SCALE_FACTOR)
    end

     -- Draw all entities required!
    ecs.process(stages.DRAW)
end

function game:leave()
    print("Leaving game state!")
end

return game
