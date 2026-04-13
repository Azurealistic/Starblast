local ecs = require "libs.evolved"

local score = ecs.builder()
    :name('fragments.score')
    :default(0) -- Starting with a score of 0!
    :spawn()

return score