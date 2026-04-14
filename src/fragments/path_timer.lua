local ecs = require "libs.evolved"

local path_timer = ecs.builder()
    :name('fragments.path_timer')
    :default(0)
    :spawn()

return path_timer
