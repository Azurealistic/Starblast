local ecs = require("libs.evolved")

local UPDATE = ecs.builder()
    :name("stages.UPDATE")
    :spawn()

local DRAW = ecs.builder()
    :name("stages.DRAW")
    :spawn()

return {
    UPDATE = UPDATE,
    DRAW = DRAW,
}
