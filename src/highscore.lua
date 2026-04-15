local highscore = {}

local FILENAME = "highscore.txt"
local _value   = 0

-- Load persisted value on first require.
local raw = love.filesystem.read(FILENAME)
if raw then _value = tonumber(raw) or 0 end

function highscore.get()
    return _value
end

-- Updates the persisted high score only when score beats the current best.
function highscore.update(score)
    if score > _value then
        _value = score
        love.filesystem.write(FILENAME, tostring(score))
    end
end

return highscore
