local ecs = require "libs.evolved"

local max = ecs.builder()
    :name('fragments.health.max')
    :default(0)
    :spawn()

local current = ecs.builder()
    :name('fragments.health.current')
    :default(0)
    :spawn()
    
return {
    max = max,
    current = current
}