local ecs = require "libs.evolved"

local boost = ecs.builder()
    :name('fragments.size')
    :default(false) -- true if boost enabled, false if not
    :spawn()

return boost