local ecs = require "libs.evolved"

local interactor = ecs.builder()
    :name('fragments.interactor')
    :tag()
    :spawn()

return interactor