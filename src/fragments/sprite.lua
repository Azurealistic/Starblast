local ecs = require "libs.evolved"

local image = ecs.builder()
    :name('fragments.sprite.image')
    :default(nil)
    :spawn()

local id = ecs.builder()
    :name('fragments.sprite.id')
    :default(0)
    :spawn()

return {
    image = image,
    id = id
}