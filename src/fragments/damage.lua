local ecs = require "libs.evolved"

local damage = ecs.builder()
    :name('fragments.damage')
    :default(1)
    :spawn()

return damage
