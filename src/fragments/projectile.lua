local ecs = require "libs.evolved"

-- Numeric type ID; matches keys in sprites.projectiles
-- 1 = basic straight shot
local projectile = ecs.builder()
    :name('fragments.projectile')
    :default(1)
    :spawn()

return projectile
