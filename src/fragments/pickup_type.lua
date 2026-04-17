local ecs = require "libs.evolved"

local frag = ecs.builder()
    :name('fragments.pickup_type')
    :default(0)
    :spawn()

-- Pickup type constants
local COIN_100     = 1
local COIN_200     = 2
local COIN_300     = 3
local COIN_400     = 4
local HEART        = 5
local SHIELD       = 6
local BOOST        = 7
local AMMO         = 8
local DOUBLE_SHOOT = 9

return {
    id           = frag,
    COIN_100     = COIN_100,
    COIN_200     = COIN_200,
    COIN_300     = COIN_300,
    COIN_400     = COIN_400,
    HEART        = HEART,
    SHIELD       = SHIELD,
    BOOST        = BOOST,
    AMMO         = AMMO,
    DOUBLE_SHOOT = DOUBLE_SHOOT,
    -- Maps each pickup type constant to its misc.quads index.
    QUADS = {
        [COIN_100]     = 1,
        [COIN_200]     = 2,
        [COIN_300]     = 14,
        [COIN_400]     = 15,
        [HEART]        = 53,
        [SHIELD]       = 40,
        [BOOST]        = 16,
        [AMMO]         = 87,
        [DOUBLE_SHOOT] = 17,
    },
}
