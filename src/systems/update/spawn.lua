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

local SPAWN_INTERVAL_BASE = 2.5   -- seconds between spawns at score 0
local SPAWN_INTERVAL_MIN  = 0.25  -- fastest spawn rate at full difficulty
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
local SCREEN_W  = GAME_WIDTH * SCALE_FACTOR

local spawn_timer = 0

local P = movement_pattern  -- shorthand

-- Spawn a single enemy at an absolute screen position.
-- phase initialises path_timer so fleet members animate out of sync.
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
-- Each fleet is a function(cx, ey, spd).
-- cx = random horizontal centre, ey = entry row just above screen.

local fleets = {}

-- 1. Single — random solo pattern
fleets[1] = function(cx, ey, spd)
    local solo = { P.STRAIGHT, P.STRAIGHT, P.SINE, P.ZIGZAG, P.DIVE_LEFT, P.DIVE_RIGHT }
    spawn_one(cx, ey, spd, solo[math.random(#solo)], 0)
end

-- 2. Horizontal line (3–5) with staggered sine
fleets[2] = function(cx, ey, spd)
    local count = math.random(3, 5)
    local gap   = SPRITE_PX * 2
    local total = (count - 1) * gap
    for i = 1, count do
        spawn_one(cx - total / 2 + (i - 1) * gap, ey, spd, P.SINE, (i - 1) * 0.35)
    end
end

-- 3. V formation (5) — straight down
fleets[3] = function(cx, ey, spd)
    local g = SPRITE_PX * 2
    spawn_one(cx,       ey,       spd, P.STRAIGHT, 0)
    spawn_one(cx - g,   ey + g,   spd, P.STRAIGHT, 0)
    spawn_one(cx + g,   ey + g,   spd, P.STRAIGHT, 0)
    spawn_one(cx - g*2, ey + g*2, spd, P.STRAIGHT, 0)
    spawn_one(cx + g*2, ey + g*2, spd, P.STRAIGHT, 0)
end

-- 4. Pincer — two enemies strafe inward from opposite sides
fleets[4] = function(_, ey, spd)
    spawn_one(0,                    ey, spd, P.STRAFE_RIGHT, 0)
    spawn_one(SCREEN_W - SPRITE_PX, ey, spd, P.STRAFE_LEFT,  0)
end

-- 5. Column (4) with zigzag, staggered phase
fleets[5] = function(cx, ey, spd)
    for i = 1, 4 do
        spawn_one(cx, ey - (i - 1) * SPRITE_PX * 2, spd, P.ZIGZAG, (i - 1) * 0.18)
    end
end

-- 6. Arrowhead (7) — tip leads, wingtips dive outward
fleets[6] = function(cx, ey, spd)
    local g = SPRITE_PX * 1.5
    spawn_one(cx,       ey,       spd, P.STRAIGHT,  0)
    spawn_one(cx - g,   ey - g,   spd, P.STRAIGHT,  0)
    spawn_one(cx + g,   ey - g,   spd, P.STRAIGHT,  0)
    spawn_one(cx - g*2, ey - g*2, spd, P.STRAIGHT,  0)
    spawn_one(cx + g*2, ey - g*2, spd, P.STRAIGHT,  0)
    spawn_one(cx - g*3, ey - g*3, spd, P.DIVE_LEFT,  0)
    spawn_one(cx + g*3, ey - g*3, spd, P.DIVE_RIGHT, 0)
end

-- 7. Dive pair — two enemies from opposite sides of the screen
fleets[7] = function(_, ey, spd)
    local left  = math.random(0,                         math.floor(SCREEN_W / 3))
    local right = math.random(math.floor(SCREEN_W * 2 / 3), SCREEN_W - SPRITE_PX)
    spawn_one(left,  ey, spd, P.DIVE_RIGHT, 0)
    spawn_one(right, ey, spd, P.DIVE_LEFT,  0)
end

-- 8. Diamond (4) — zigzag with staggered phase
fleets[8] = function(cx, ey, spd)
    local g = SPRITE_PX * 2
    spawn_one(cx,     ey - g, spd, P.ZIGZAG, 0.0)  -- top
    spawn_one(cx - g, ey,     spd, P.ZIGZAG, 0.2)  -- left
    spawn_one(cx + g, ey,     spd, P.ZIGZAG, 0.4)  -- right
    spawn_one(cx,     ey + g, spd, P.ZIGZAG, 0.6)  -- bottom
end

-- 9. Wall (6–9) — wide straight line, very dense
fleets[9] = function(_, ey, spd)
    local count = math.random(6, 9)
    local gap   = SPRITE_PX * 1.4
    local total = (count - 1) * gap
    local sx    = SCREEN_W / 2 - total / 2
    for i = 1, count do
        spawn_one(sx + (i - 1) * gap, ey, spd, P.STRAIGHT, 0)
    end
end

-- 10. Flankers — 3 enemies from each side strafing inward in echelon
fleets[10] = function(_, ey, spd)
    local g = SPRITE_PX * 1.8
    for i = 1, 3 do
        spawn_one((i - 1) * g,                          ey - (i - 1) * g, spd, P.STRAFE_RIGHT, (i - 1) * 0.2)
        spawn_one(SCREEN_W - SPRITE_PX - (i - 1) * g,  ey - (i - 1) * g, spd, P.STRAFE_LEFT,  (i - 1) * 0.2)
    end
end

-- 11. Swarm (8–10) — arc of enemies with mixed patterns
fleets[11] = function(cx, ey, spd)
    local pats  = { P.SINE, P.ZIGZAG, P.ORBIT, P.STRAIGHT }
    local count = math.random(8, 10)
    local spread = SPRITE_PX * 1.8
    for i = 1, count do
        local dx = (i - (count + 1) / 2) * spread
        local dy = -math.abs(dx) * 0.25  -- arc shape, top of arc at centre
        spawn_one(cx + dx, ey + dy, spd, pats[math.random(#pats)], (i - 1) * 0.12)
    end
end

-- 12. Sweepers (3–4) — fast horizontal sweep across the screen
fleets[12] = function(_, ey, spd)
    local count = math.random(3, 4)
    local goLeft = math.random() < 0.5
    local pat, sx, step
    if goLeft then
        pat  = P.SWEEP_LEFT
        sx   = SCREEN_W - SPRITE_PX * 2
        step = -SPRITE_PX * 1.5
    else
        pat  = P.SWEEP_RIGHT
        sx   = SPRITE_PX
        step = SPRITE_PX * 1.5
    end
    for i = 1, count do
        spawn_one(sx + (i - 1) * step, ey - (i - 1) * SPRITE_PX, spd, pat, (i - 1) * 0.15)
    end
end

-- 13. Chargers (4) — staggered dives: some already diving when grace expires
fleets[13] = function(cx, ey, spd)
    local g = SPRITE_PX * 2
    for i = 1, 4 do
        -- Phase 0, 0.4, 0.8, 1.2 → dives hit at real-times 1.5, 1.1, 0.7, 0.3 after spawn
        spawn_one(cx + (i - 2.5) * g, ey, spd, P.CHARGE, (i - 1) * 0.4)
    end
end

-- 14. Orbital pair — two enemies circling in opposite phases
fleets[14] = function(cx, ey, spd)
    spawn_one(cx, ey, spd, P.ORBIT, 0)
    spawn_one(cx, ey, spd, P.ORBIT, math.pi)  -- opposite phase = mirror spiral
end

-- 15. Cross (+) — centre plus 4 cardinal arms, all straight
fleets[15] = function(cx, ey, spd)
    local g = SPRITE_PX * 2
    spawn_one(cx,     ey,     spd, P.STRAIGHT, 0)
    spawn_one(cx - g, ey,     spd, P.DIVE_RIGHT, 0)
    spawn_one(cx + g, ey,     spd, P.DIVE_LEFT,  0)
    spawn_one(cx,     ey - g, spd, P.STRAIGHT, 0)
    spawn_one(cx,     ey - g*2, spd, P.STRAIGHT, 0)
end

-- 16. Reverse-V / wedge (5) — converging from both sides toward centre
fleets[16] = function(cx, ey, spd)
    local g = SPRITE_PX * 2
    spawn_one(cx,       ey + g*2, spd, P.STRAIGHT,  0)  -- tip at bottom (enters last)
    spawn_one(cx - g,   ey + g,   spd, P.DIVE_RIGHT, 0)
    spawn_one(cx + g,   ey + g,   spd, P.DIVE_LEFT,  0)
    spawn_one(cx - g*2, ey,       spd, P.DIVE_RIGHT, 0)
    spawn_one(cx + g*2, ey,       spd, P.DIVE_LEFT,  0)
end

-- 17. Dual columns — two parallel columns of 3 with opposite zigzag phase
fleets[17] = function(cx, ey, spd)
    local col = SPRITE_PX * 3
    for i = 1, 3 do
        spawn_one(cx - col, ey - (i - 1) * SPRITE_PX * 2, spd, P.ZIGZAG, (i - 1) * 0.18)
        spawn_one(cx + col, ey - (i - 1) * SPRITE_PX * 2, spd, P.ZIGZAG, (i - 1) * 0.18 + 0.175)
    end
end

-- ── Weighted difficulty-scaled fleet selection ────────────────────────────────
-- {fleet_index, base_weight, late_bonus}
-- Effective weight = base + late_bonus * difficulty  (clamped ≥ 0)
-- At difficulty 0: mostly singles and small fleets
-- At difficulty 1: walls, swarms, flankers dominate

local WEIGHTED = {
    { 1,  28, -15 },  -- single        (common early, fades)
    { 2,  14,   2 },  -- line
    { 3,  10,   4 },  -- V formation
    { 4,  10,   4 },  -- pincer
    { 5,  10,   4 },  -- column
    { 6,   6,   5 },  -- arrowhead
    { 7,   6,   5 },  -- dive pair
    { 8,   5,   5 },  -- diamond
    { 9,   0,  14 },  -- wall          (late game)
    { 10,  0,  12 },  -- flankers      (late game)
    { 11,  0,  12 },  -- swarm         (late game)
    { 12,  5,   6 },  -- sweepers
    { 13,  4,   7 },  -- chargers
    { 14,  3,   7 },  -- orbital pair
    { 15,  4,   5 },  -- cross
    { 16,  4,   5 },  -- reverse-V
    { 17,  3,   6 },  -- dual columns
}

local function pick_fleet(difficulty)
    local total = 0
    local weights = {}
    for i, w in ipairs(WEIGHTED) do
        local eff = math.max(0, w[2] + w[3] * difficulty)
        weights[i] = eff
        total = total + eff
    end

    local r = math.random() * total
    local acc = 0
    for i, w in ipairs(WEIGHTED) do
        acc = acc + weights[i]
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

        pick_fleet(difficulty)(cx, ey, spd)
    end):spawn()
