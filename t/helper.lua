ffi = require("ffi")
log = require("lib.log")

ffi.cdef [[
    int getppid(void);
    int getpid(void);
    int fork(void);
]]
local C = ffi.C

function CLONE(number, init, is_daemon)
    if type(number) ~= "number" then
        return false, "bad number: " .. number
    end
    if number < 1 then
        return false, "invalid number: " .. number
    end
    local r
    for i = 0, number - 1 do
        r = C.fork()
        if r == 0 then
            if init then
                init(i)
            end
            break
        end
    end
    if r > 0 and is_daemon then
        os.exit()
    end
end

--[[
\27[ 1;2;37;4;5
1 => 粗体
2 => 50%亮度
3 =>
    0	黑色
    1	红色
    2	绿色
    3	棕色
    4	蓝色
    5	紫色
    6	青色
    7	白色
4 => 下划线
5 => 闪烁
]\27[0m
]]

function PHASE(name)
    io.stdout:write("\27[1;37;42m[", name, "]\27[0m\n")
end

function TITLE(name)
    io.stdout:write("\27[1;37;44m========= ", name, " =========\27[0m\n")
end

function SOURCE()
    local source = debug.getinfo(2, "S").source
    if not source or source:sub(1, 1) ~= "@" then
        return "NOSOURCE"
    end
    local filename = source:gmatch("/([%w-_.]+)$")()
    if not filename then
        return "NONAME"
    end
    return filename
end

function GETPID()
    return C.getpid()
end

function EXIT(msg, code)
    if msg then
        io.stdout:write("\27[1;37;44mReturn: ", msg, "\27[0m\n")
    end
    if code and type(code) == "number" then
        os.exit(code)
    end
    os.exit(0)
end