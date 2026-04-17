-- Shared mutable player state used across multiple systems.
-- Plain Lua table; require() caching means all modules get the same instance.
local player_state = {
    invuln       = 0.0,   -- seconds of invulnerability remaining; > 0 = invulnerable
    double_shoot = 0.0,   -- seconds of double-shot power-up remaining; > 0 = active
}
return player_state
