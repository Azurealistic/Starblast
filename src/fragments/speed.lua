local ecs = require "libs.evolved"

local speed = ecs.builder()
    :name('fragments.speed')
    :default(0)
    :spawn()

return speed