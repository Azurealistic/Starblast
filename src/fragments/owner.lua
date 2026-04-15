local ecs = require "libs.evolved"

-- Stores the entity ID of whatever spawned this entity.
-- Used so enemy bullets can be cleaned up when their owner dies.
local owner = ecs.builder()
    :name('fragments.owner')
    :default(0)
    :spawn()

return owner
