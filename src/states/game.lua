-- Game State
-- All of the logic and various gameplay related stuff will happen in this file.

-- Imports:
local ecs = require "libs.evolved"
local fsm = require "libs.gamestate"

-- Sprites:
local ships = require "sprites.ships"
local projectiles = require "sprites.projectiles"
local misc = require "sprites.misc"

-- ECS:
-- Utility fragments:
local deltatime = require "fragments.deltatime"
local sprite    = require "fragments.sprite"
local speed     = require "fragments.speed"
local score     = require "fragments.score"
local health       = require "fragments.health"
local position     = require "fragments.position"
local player_state = require "player_state"

-- System related:
local stages = require "groups.stages"

require "systems.draw.projectile"
require "systems.draw.boost"
require "systems.draw.ships"
require "systems.draw.enemy"
require "systems.draw.explosion"
require "systems.draw.pickup"
require "systems.draw.ui"

require "systems.update.input"
require "systems.update.shooting"
require "systems.update.movement_pattern"
require "systems.update.physics"
require "systems.update.clamp"
require "systems.update.projectile"
require "systems.update.spawn"
require "systems.update.collision"
require "systems.update.enemy_shoot"
require "systems.update.enemy_bullet_collision"
require "systems.update.spawn_grace"
require "systems.update.explosion"
require "systems.update.pickup"
require "systems.update.damage_timer"

-- Entities:
local player = require "entities.player"
local player_ship_ids = {2, 12, 22, 32, 42}

-- Game State:
local game = {}

-- Query used in leave() to clean up all ECS entities.
local cleanup_query = ecs.builder():include(position.x):spawn()

-- Other variables used:
local bg_sheet
local bg_quads = {}
local speed_multipler = 0 -- This multiplier will affect everything in how fast paced the game is, allowing for it to get harder as it goes on!
local move_multipler = 200 -- This one is used alongside the speed multiplier to allow us to move our ship at a relatively good pace.

-- Parallax layers: #5 (slow, distant stars) and #6 (faster, closer stars)
-- Base speeds are multiplied by speed_multipler each update, so don't pre-multiply here.
local parallax = {
    { quad_idx = 3, y = 0, speed = 64 },
    { quad_idx = 5, y = 0, speed = 128 },
    { quad_idx = 6, y = 0, speed = 256 },
}

-- FSM Hooked functionality which auto runs during loop!
function game:enter()
    -- Load the sprites!
    ships.load()
    projectiles.load()
    misc.load()

    --  Load background stuff!
    bg_sheet = love.graphics.newImage("assets/sprites/backgrounds.png")
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

    -- Reset per-run player state.
    player_state.invuln       = 0
    player_state.double_shoot = 0

    -- Player initial setup!
    self.player = player:spawn()
    -- Always starts on first ship then we can potentially upgrade it!
    ecs.set(self.player, sprite.base, player_ship_ids[1])
    ecs.set(self.player, sprite.direction, 0) -- For indicating left or right movement!
    -- Load music (only once; keep it playing through the gameover screen and restarts).
    if not self.source then
        self.source = love.audio.newSource("assets/music/7.wav", "stream")
    end
end

function game:update(dt)
    -- We need a way to keep track of how much time has elapsed in the game, so we use deltatime!
    ecs.set(deltatime, deltatime, dt)

    -- Process all update systems!
    ecs.process(stages.UPDATE)

    -- If we need to make the gameplay faster based off the score, we can do so automatically here!
    speed_multipler = ((ecs.get(self.player, score) / 5000) + 2)
    -- Set the speed we are allowed to move with!
    ecs.set(self.player, speed, speed_multipler * move_multipler)

    -- Update the parallax for the background.
    local screen_h = 256 * SCALE_FACTOR
    for _, layer in ipairs(parallax) do
        layer.y = layer.y + layer.speed * dt * speed_multipler
        if layer.y >= screen_h then
            layer.y = layer.y - screen_h
        end
    end

    -- Check for player death.
    local hp = ecs.get(self.player, health.current)
    if hp and hp <= 0 then
        local final = ecs.get(self.player, score) or 0
        fsm.switch(require("states.gameover"), final, bg_sheet, bg_quads, parallax, speed_multipler)
        return
    end

    -- If music is not playing, play it!
    if not self.source:isPlaying() then
        love.audio.play(self.source)
    end
end

function game:draw()
    -- Figure out draw height for game!
    local screen_h = 256 * SCALE_FACTOR

    -- Parallax star layers: draw twice (current + one copy above) for seamless looping
    -- Essentially the parallax layers are of height 256 * SCALE_FACTOR * 2, so it looks like they never end!
    for _, layer in ipairs(parallax) do
        local q = bg_quads[layer.quad_idx]
        love.graphics.draw(bg_sheet, q, 0, layer.y,           0, SCALE_FACTOR, SCALE_FACTOR)
        love.graphics.draw(bg_sheet, q, 0, layer.y,           0, SCALE_FACTOR, SCALE_FACTOR)
        love.graphics.draw(bg_sheet, q, 0, layer.y - screen_h, 0, SCALE_FACTOR, SCALE_FACTOR)
    end

     -- Draw all entities required!
    ecs.process(stages.DRAW)
end

function game:leave()
    local to_destroy = {}
    for _, entity_list, entity_count in ecs.execute(cleanup_query) do
        for i = 1, entity_count do
            to_destroy[#to_destroy + 1] = entity_list[i]
        end
    end
    for _, e in ipairs(to_destroy) do
        if ecs.alive(e) then ecs.destroy(e) end
    end
end

return game
