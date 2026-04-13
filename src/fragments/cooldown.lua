local ecs = require "libs.evolved"

local cooldown = ecs.builder()
    :name('fragments.cooldown')
    :default(0)
    :spawn()

return cooldown
