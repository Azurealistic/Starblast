local ecs = require "libs.evolved"

-- Counts down from 0.5 → 0 after a hit.  While > 0, the player is invulnerable
-- and the ship sprite blinks.  Default 0 = not invulnerable.
local damage_timer = ecs.builder()
    :name("fragments.damage_timer")
    :default(0)
    :spawn()

return damage_timer
