-- Shared mutable player state used across multiple systems.
-- Plain Lua table; require() caching means all modules get the same instance.
local player_state = {
    invuln = 0.0,   -- seconds of invulnerability remaining; > 0 = invulnerable
}
return player_state
