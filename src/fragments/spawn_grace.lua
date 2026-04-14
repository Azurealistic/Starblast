local ecs = require "libs.evolved"

local spawn_grace = ecs.builder()
    :name('fragments.spawn_grace')
    :default(5.0)  -- 1 second of invulnerability on spawn
    :spawn()

return spawn_grace
