local ecs = require "libs.evolved"

local stages           = require "groups.stages"
local deltatime        = require "fragments.deltatime"
local position         = require "fragments.position"
local velocity         = require "fragments.velocity"
local speed            = require "fragments.speed"
local sprite           = require "fragments.sprite"
local score            = require "fragments.score"
local controllable     = require "fragments.controllable"
local cooldown         = require "fragments.cooldown"
local movement_pattern = require "fragments.movement_pattern"
local path_timer       = require "fragments.path_timer"

local enemy_ent = require "entities.enemy"

local SPAWN_INTERVAL_BASE = 5
local SPAWN_INTERVAL_MIN  = 0.35
local ENEMY_SPEED_BASE    = 300
local ENEMY_SPEED_MAX     = 1000

local ENEMY_SPRITES = {  5,  6,  7,  8,  9, 10,
                        15, 16, 17, 18, 19, 20,
                        25, 26, 27, 28, 29, 30,
                        35, 36, 37, 38, 39, 40,
                        45, 46, 47, 48, 49, 50,
                        55, 56, 57, 58, 59, 60,
                    }

local SPRITE_PX = 8 * SCALE_FACTOR
local SCREEN_W  = GAME_WIDTH  * SCALE_FACTOR

local spawn_timer = 0

-- Spawn a single enemy at an absolute screen position with a given pattern.
-- phase offsets the path_timer so fleet members animate out of sync.
local function spawn_one(ex, ey, spd, pat, phase)
    ex = math.max(0, math.min(SCREEN_W - SPRITE_PX, ex))
    local e = enemy_ent:spawn()
    ecs.set(e, position.x,          ex)
    ecs.set(e, position.y,          ey)
    ecs.set(e, velocity.x,          0)
    ecs.set(e, velocity.y,          spd)
    ecs.set(e, speed,               spd)
    ecs.set(e, sprite.base,         ENEMY_SPRITES[math.random(#ENEMY_SPRITES)])
    ecs.set(e, sprite.direction,    0)
    ecs.set(e, cooldown,            math.random() * 0.5)
    ecs.set(e, movement_pattern.id, pat)
    ecs.set(e, path_timer,          phase or 0)
end

-- ── Fleet definitions ────────────────────────────────────────────────────────
-- Each fleet is a function(cx, ey, spd) that spawns its enemies.
-- cx = horizontal centre of the formation, ey = top-of-screen entry row.

local fleets = {}

-- 1. Single enemy — picks a random solo pattern
fleets[1] = function(cx, ey, spd)
    local solo = { movement_pattern.STRAIGHT, movement_pattern.STRAIGHT,
                   movement_pattern.SINE,     movement_pattern.ZIGZAG,
                   movement_pattern.DIVE_LEFT, movement_pattern.DIVE_RIGHT }
    spawn_one(cx, ey, spd, solo[math.random(#solo)], 0)
end

-- 2. Horizontal line (3–5 enemies) with staggered sine
fleets[2] = function(cx, ey, spd)
    local count = math.random(3, 5)
    local gap   = SPRITE_PX * 2
    local total = (count - 1) * gap
    for i = 1, count do
        local dx = -total / 2 + (i - 1) * gap
        spawn_one(cx + dx, ey, spd, movement_pattern.SINE, (i - 1) * 0.35)
    end
end

-- 3. V formation (5 enemies) falling straight down
fleets[3] = function(cx, ey, spd)
    local gap = SPRITE_PX * 2
    spawn_one(cx,           ey,           spd, movement_pattern.STRAIGHT, 0)
    spawn_one(cx - gap,     ey + gap,     spd, movement_pattern.STRAIGHT, 0)
    spawn_one(cx + gap,     ey + gap,     spd, movement_pattern.STRAIGHT, 0)
    spawn_one(cx - gap * 2, ey + gap * 2, spd, movement_pattern.STRAIGHT, 0)
    spawn_one(cx + gap * 2, ey + gap * 2, spd, movement_pattern.STRAIGHT, 0)
end

-- 4. Pincer — two enemies enter from opposite sides and strafe inward
fleets[4] = function(_, ey, spd)
    spawn_one(0,                    ey, spd, movement_pattern.STRAFE_RIGHT, 0)
    spawn_one(SCREEN_W - SPRITE_PX, ey, spd, movement_pattern.STRAFE_LEFT,  0)
end

-- 5. Column (4 enemies stacked vertically) with zigzag
fleets[5] = function(cx, ey, spd)
    for i = 1, 4 do
        spawn_one(cx, ey - (i - 1) * SPRITE_PX * 2, spd, movement_pattern.ZIGZAG, (i - 1) * 0.18)
    end
end

-- 6. Arrowhead (7 enemies, tight arrow pointing down)
fleets[6] = function(cx, ey, spd)
    local g = SPRITE_PX * 1.5
    spawn_one(cx,         ey,             spd, movement_pattern.STRAIGHT, 0)
    spawn_one(cx - g,     ey - g,         spd, movement_pattern.STRAIGHT, 0)
    spawn_one(cx + g,     ey - g,         spd, movement_pattern.STRAIGHT, 0)
    spawn_one(cx - g * 2, ey - g * 2,     spd, movement_pattern.STRAIGHT, 0)
    spawn_one(cx + g * 2, ey - g * 2,     spd, movement_pattern.STRAIGHT, 0)
    spawn_one(cx - g * 3, ey - g * 3,     spd, movement_pattern.DIVE_LEFT,  0)
    spawn_one(cx + g * 3, ey - g * 3,     spd, movement_pattern.DIVE_RIGHT, 0)
end

-- 7. Two dive bombers — one from each side
fleets[7] = function(_, ey, spd)
    local left  = math.random(0,                    math.floor(SCREEN_W / 3))
    local right = math.random(math.floor(SCREEN_W * 2 / 3), SCREEN_W - SPRITE_PX)
    spawn_one(left,  ey, spd, movement_pattern.DIVE_RIGHT, 0)
    spawn_one(right, ey, spd, movement_pattern.DIVE_LEFT,  0)
end

-- Weighted fleet table: higher weight = more frequent.
-- {fleet_index, weight}
local WEIGHTED = {
    { 1, 30 },   -- single
    { 2, 18 },   -- line
    { 3, 12 },   -- V formation
    { 4, 12 },   -- pincer
    { 5, 12 },   -- column
    { 6,  8 },   -- arrowhead
    { 7,  8 },   -- dive pair
}

local TOTAL_WEIGHT = 0
for _, w in ipairs(WEIGHTED) do TOTAL_WEIGHT = TOTAL_WEIGHT + w[2] end

local function pick_fleet()
    local r = math.random(TOTAL_WEIGHT)
    local acc = 0
    for _, w in ipairs(WEIGHTED) do
        acc = acc + w[2]
        if r <= acc then return fleets[w[1]] end
    end
    return fleets[1]
end

-- ── System ───────────────────────────────────────────────────────────────────

return ecs.builder()
    :name("system.spawn.update")
    :group(stages.UPDATE)
    :include(controllable, score)
    :execute(function(chunk, _, entity_count)
        local dt = ecs.get(deltatime, deltatime)
        local scores = chunk:components(score)

        spawn_timer = spawn_timer + dt

        local current_score = (entity_count > 0) and scores[1] or 0
        local difficulty     = math.min(current_score / 10000, 1)
        local spawn_interval = SPAWN_INTERVAL_BASE
            - (SPAWN_INTERVAL_BASE - SPAWN_INTERVAL_MIN) * difficulty

        if spawn_timer < spawn_interval then return end
        spawn_timer = 0

        local cx  = math.random(SPRITE_PX, SCREEN_W - SPRITE_PX)
        local ey  = -SPRITE_PX
        local spd = ENEMY_SPEED_BASE + (ENEMY_SPEED_MAX - ENEMY_SPEED_BASE) * difficulty

        pick_fleet()(cx, ey, spd)
    end):spawn()
