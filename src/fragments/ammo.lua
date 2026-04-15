local ecs = require "libs.evolved"

local max = ecs.builder()
    :name('fragments.ammo.max')
    :default(0)
    :spawn()

local current = ecs.builder()
    :name('fragments.ammo.current')
    :default(0)
    :spawn()

return {
    max     = max,
    current = current,
}
