local function _us(req)
    print(123)
    print(req)
end
-- end

local type_map = setmetatable({}, {
    __index = function(t, k)
        print("get")
        print(k)
        return 123;
    end,
    __newindex = function(t, k, v)
        print("set")
        print(k, v)
        return 123;
    end
})

print(type_map["aaa"])

type_map["aaa"] = 100


local ffi = require("ffi")

local char = ffi.new("char[128]")

local str = "hello world"

