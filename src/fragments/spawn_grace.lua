local ecs = require "libs.evolved"

local spawn_grace = ecs.builder()
    :name('fragments.spawn_grace')
    :default(0.3)
    :spawn()

return spawn_grace
