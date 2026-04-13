-- Ships spritesheet + quad registry.
-- Call ships.load() once during state setup (e.g. game:enter()) before using.
--
-- ships.small[n]  →  nth quad from the 8×8 grid  (100 quads, row-major)
-- ships.large[n]  →  nth quad from the 16×16 grid  (25 quads, row-major)

local ships = {
    sheet = nil,
    small = {},
    large = {},
}

function ships.load()
    ships.sheet = love.graphics.newImage("assets/sprites/ships.png")
    ships.sheet:setFilter("nearest", "nearest")

    local sw, sh = ships.sheet:getDimensions()

    -- Small ships: 8×8 cells (10 cols × 10 rows = 100 quads)
    local SMALL = 8
    local idx = 1
    for row = 0, (sh / SMALL) - 1 do
        for col = 0, (sw / SMALL) - 1 do
            ships.small[idx] = love.graphics.newQuad(
                col * SMALL, row * SMALL,
                SMALL, SMALL,
                sw, sh
            )
            idx = idx + 1
        end
    end

    -- Large ships: 16×16 cells (5 cols × 5 rows = 25 quads)
    local LARGE = 16
    idx = 1
    for row = 0, (sh / LARGE) - 1 do
        for col = 0, (sw / LARGE) - 1 do
            ships.large[idx] = love.graphics.newQuad(
                col * LARGE, row * LARGE,
                LARGE, LARGE,
                sw, sh
            )
            idx = idx + 1
        end
    end
end

return ships
