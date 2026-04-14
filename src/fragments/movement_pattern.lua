local ecs = require "libs.evolved"

local id = ecs.builder()
    :name('fragments.movement_pattern')
    :default(0)
    :spawn()

return {
    id           = id,
    STRAIGHT     = 0,   -- falls straight down
    SINE         = 1,   -- gentle side-to-side weave
    ZIGZAG       = 2,   -- sharp direction cuts
    DIVE_LEFT    = 3,   -- sweeps hard left then straightens
    DIVE_RIGHT   = 4,   -- sweeps hard right then straightens
    STRAFE_LEFT  = 5,   -- glides left-down then drops
    STRAFE_RIGHT = 6,   -- glides right-down then drops
    SWEEP_LEFT   = 7,   -- fast horizontal sweep right-to-left, then drops
    SWEEP_RIGHT  = 8,   -- fast horizontal sweep left-to-right, then drops
    ORBIT        = 9,   -- circular spiral descent
    CHARGE       = 10,  -- slow hover then sudden fast dive
}
