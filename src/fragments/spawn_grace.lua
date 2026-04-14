local ecs = require "libs.evolved"

local spawn_grace = ecs.builder()
    :name('fragments.spawn_grace')
    :default(0.5)  -- 1 second of invulnerability on spawn
    :spawn()

return spawn_grace
