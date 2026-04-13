local ecs = require "libs.evolved"

local sprite = ecs.builder()
    :name('fragments.sprite')
    :default(nil)
    :spawn()

return sprite