local ecs = require "libs.evolved"

local controllable = ecs.builder()
    :name('fragments.controllable')
    :tag()
    :spawn()

return controllable