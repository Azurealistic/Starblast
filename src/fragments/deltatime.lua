local ecs = require "libs.evolved"

local deltatime = ecs.builder()
    :name('fragments.deltatime')
    :default(0)
    :spawn()

return deltatime
