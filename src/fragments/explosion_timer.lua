local ecs = require "libs.evolved"

local explosion_timer = ecs.builder()
    :name('fragments.explosion_timer')
    :default(0)
    :spawn()

return explosion_timer
