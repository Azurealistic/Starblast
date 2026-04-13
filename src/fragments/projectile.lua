local ecs = require "libs.evolved"

local id = ecs.builder()
    :name('fragments.projectile')
    :default(1)
    :spawn()

-- Type constants — the stored fragment value determines which sprite is drawn.
-- Add new entries here as projectile types are added.
return {
    id    = id,
    BASIC = 1,
    DENSE = 4,
}
