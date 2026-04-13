-- Projectile sprites from assets/sprites/projectiles.png.
-- Call projectiles.load() once during state setup (e.g. game:enter()) before rendering.
--
-- projectiles.quads[n]  →  nth 8×8 quad from the sheet (row-major, 1-indexed)
-- Type constants map projectile types to quad indices.

local projectiles = {
    sheet = nil,
    quads = {},
}

function projectiles.load()
    projectiles.sheet = love.graphics.newImage("assets/sprites/projectiles.png")
    projectiles.sheet:setFilter("nearest", "nearest")

    local sw, sh = projectiles.sheet:getDimensions()
    local CELL = 8

    local idx = 1
    for row = 0, (sh / CELL) - 1 do
        for col = 0, (sw / CELL) - 1 do
            projectiles.quads[idx] = love.graphics.newQuad(
                col * CELL, row * CELL,
                CELL, CELL,
                sw, sh
            )
            idx = idx + 1
        end
    end
end

return projectiles
