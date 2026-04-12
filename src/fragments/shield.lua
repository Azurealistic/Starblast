local ecs = require "libs.evolved"

local max = ecs.builder()
    :name('fragments.shield.max')
    :default(0)
    :spawn()

local current = ecs.builder()
    :name('fragments.shield.current')
    :default(0)
    :spawn()
    
return {
    max = max,
    current = current
}