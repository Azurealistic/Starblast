local ecs = require "libs.evolved"

local speed = ecs.builder()
    :name('fragments.size')
    :default(0) -- 0 is small ship, 1 is large ship
    :spawn()

return speed