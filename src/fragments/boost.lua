local ecs = require "libs.evolved"

local boost = ecs.builder()
    :name('fragments.size')
    :default(false) -- True = Boost enabled!
    :spawn()

return boost