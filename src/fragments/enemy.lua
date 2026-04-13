local ecs = require "libs.evolved"

local enemy = ecs.builder()
    :name('fragments.enemy')
    :tag()
    :spawn()

return enemy
