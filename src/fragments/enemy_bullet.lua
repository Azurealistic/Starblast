local ecs = require "libs.evolved"

-- Tag that distinguishes enemy-fired projectiles from player-fired ones.
-- Used to exclude enemy bullets from bullet→enemy collision checks and to
-- drive the ebullet→player collision system.
local ebullet = ecs.builder()
    :name('fragments.ebullet')
    :tag()
    :spawn()

return ebullet
