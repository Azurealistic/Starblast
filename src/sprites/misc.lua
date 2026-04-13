local misc = {
    sheet = nil,
    quads = {},
}

function misc.load()
    misc.sheet = love.graphics.newImage("assets/sprites/misc.png")
    misc.sheet:setFilter("nearest", "nearest")

    local sw, sh = misc.sheet:getDimensions()
    local CELL = 8

    local idx = 1
    for row = 0, (sh / CELL) - 1 do
        for col = 0, (sw / CELL) - 1 do
            misc.quads[idx] = love.graphics.newQuad(
                col * CELL, row * CELL,
                CELL, CELL,
                sw, sh
            )
            idx = idx + 1
        end
    end
end

return misc
