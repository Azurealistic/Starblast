local fsm       = require "libs.gamestate"
local game      = require "states.game"

local gameover = {}

local final_score  = 0
local timer        = 0
local blink_timer  = 0
local INPUT_DELAY  = 0.6   -- seconds before restart is accepted

local font_title   = nil
local font_score   = nil
local font_prompt  = nil

-- Parallax state passed in from game on death
local bg_sheet   = nil
local bg_quads   = nil
local parallax   = nil
local speed_mult = 2

function gameover:enter(_, score, sheet, quads, par, spd)
    final_score = score or 0
    timer       = 0
    blink_timer = 0

    font_title  = love.graphics.newFont("assets/fonts/80s-retro-future.ttf", 72)
    font_score  = love.graphics.newFont("assets/fonts/80s-retro-future.ttf", 36)
    font_prompt = love.graphics.newFont("assets/fonts/80s-retro-future.ttf", 22)

    bg_sheet   = sheet
    bg_quads   = quads
    parallax   = par
    speed_mult = spd or 2
end

function gameover:update(dt)
    timer       = timer + dt
    blink_timer = blink_timer + dt

    -- Keep the background scrolling.
    if parallax then
        local screen_h = GAME_HEIGHT * SCALE_FACTOR
        for _, layer in ipairs(parallax) do
            layer.y = layer.y + layer.speed * dt * speed_mult
            if layer.y >= screen_h then
                layer.y = layer.y - screen_h
            end
        end
    end

    if timer > INPUT_DELAY then
        if love.keyboard.isDown("space") or love.keyboard.isDown("return") then
            fsm.switch(game)
        end
    end
end

function gameover:draw()
    local sw = GAME_WIDTH  * SCALE_FACTOR
    local sh = GAME_HEIGHT * SCALE_FACTOR

    -- Scrolling parallax background (same layers as in-game).
    if parallax and bg_sheet and bg_quads then
        local screen_h = sh
        for _, layer in ipairs(parallax) do
            local q = bg_quads[layer.quad_idx]
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(bg_sheet, q, 0, layer.y,            0, SCALE_FACTOR, SCALE_FACTOR)
            love.graphics.draw(bg_sheet, q, 0, layer.y - screen_h, 0, SCALE_FACTOR, SCALE_FACTOR)
        end
    else
        -- Fallback: static dark background.
        love.graphics.setColor(0.01, 0.01, 0.06, 1)
        love.graphics.rectangle("fill", 0, 0, sw, sh)
    end

    -- Dark overlay so the text is legible over the stars.
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    -- GAME OVER — pulsing red/orange
    local t   = love.timer.getTime()
    local p   = (math.sin(t * 2.5) + 1) / 2
    local prev = love.graphics.getFont()

    ---@diagnostic disable-next-line: param-type-mismatch
    love.graphics.setFont(font_title) 
    -- Glow halo
    love.graphics.setColor(1, 0.2, 0, 0.18 + 0.12 * p)
    love.graphics.printf("GAME OVER", -4, sh * 0.26 + 3, sw, "center")
    love.graphics.printf("GAME OVER",  4, sh * 0.26 + 3, sw, "center")
    -- Main text
    love.graphics.setColor(1, 0.12 + 0.18 * p, 0, 1)
    love.graphics.printf("GAME OVER", 0, sh * 0.26, sw, "center")

    -- Final score
    ---@diagnostic disable-next-line: param-type-mismatch
    love.graphics.setFont(font_score)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("SCORE", 0, sh * 0.50, sw, "center")
    love.graphics.setColor(0.95, 0.85, 0.2, 1)
    love.graphics.printf(tostring(final_score), 0, sh * 0.58, sw, "center")

    -- Blinking restart prompt (only after input delay)
    if timer > INPUT_DELAY and math.floor(blink_timer * 1.8) % 2 == 0 then
        ---@diagnostic disable-next-line: param-type-mismatch
        love.graphics.setFont(font_prompt)
        love.graphics.setColor(0.75, 0.85, 1, 0.9)
        love.graphics.printf("PRESS SPACE TO PLAY AGAIN", 0, sh * 0.73, sw, "center")
    end

    love.graphics.setFont(prev)
    love.graphics.setColor(1, 1, 1, 1)
end

function gameover:leave() end

return gameover
