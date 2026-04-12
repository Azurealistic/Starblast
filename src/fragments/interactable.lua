local ecs = require "libs.evolved"

local interactable = ecs.builder()
    :name('fragments.interactable')
    :tag()
    :spawn()

return interactable