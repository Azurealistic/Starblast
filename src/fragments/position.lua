local ecs = require "libs.evolved"

local x = ecs.builder()
    :name('fragments.position.x')
    :default(0)
    :spawn()

local y = ecs.builder()
    :name('fragments.position.y')
    :default(0)
    :spawn()

return {
    x = x,
    y = y
}
