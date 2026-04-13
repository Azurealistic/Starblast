local ecs = require "libs.evolved"

local base = ecs.builder()
    :name('fragments.sprite.base')
    :default(nil)
    :spawn()

local direction = ecs.builder()
    :name('fragments.sprite.direction')
    :default(nil)
    :spawn()

return {
    base = base,
    direction = direction
}