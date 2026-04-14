local ecs = require "libs.evolved"

local id = ecs.builder()
    :name('fragments.movement_pattern')
    :default(0)
    :spawn()

return {
    id           = id,
    STRAIGHT     = 0,  -- falls straight down
    SINE         = 1,  -- gentle side-to-side weave
    ZIGZAG       = 2,  -- sharp direction cuts
    DIVE_LEFT    = 3,  -- sweeps hard left then straightens
    DIVE_RIGHT   = 4,  -- sweeps hard right then straightens
    STRAFE_LEFT  = 5,  -- enters from right, glides left-down then drops
    STRAFE_RIGHT = 6,  -- enters from left, glides right-down then drops
}
