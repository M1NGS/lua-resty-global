local global = require("global")

local setter = global.init(ngx.shared.global)

--[[
    ----LUA----
    string
    number
    boolean
    ---CDATA---
    int64
    uint64
    int32
    uint32
    int16
    uint16
    int8
    uint8
    --PRIVATE--
    queue
    struct

    name = {type, init [,size] [,lock]}
]]


local sets1 = setter:new({
    path = {'string', '/usr/bin', 4096},
    version = {'number', 1500},
    debug = {'boolean', true},
    timer = {'uint64', 0}, --cdata

})

sets1:importToGlobal("server_info")



print(server_info.path) -- /usr/bin

server_info.path = '/usr/sbin'

print(server_info.version) -- 1500

server_info.debug = false