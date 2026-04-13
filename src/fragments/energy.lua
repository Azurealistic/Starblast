local ecs = require "libs.evolved"

local max = ecs.builder()
    :name('fragments.energy.max')
    :default(0)
    :spawn()

local current = ecs.builder()
    :name('fragments.energy.current')
    :default(0)
    :spawn()

return {
    max     = max,
    current = current,
}
