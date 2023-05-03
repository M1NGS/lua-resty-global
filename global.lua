local ffi = ffi
local XXH32 = helper.XXH32
ffi.cdef [[
    //shmmgr
    int msync(void *addr, size_t length, int flags);
    void *mmap(void *start, size_t length, int prot, int flags, int fd, size_t offsize);
    int munmap(void *addr, size_t length);
    int strncmp(const char *s1, const char *s2, size_t n);
    //public
    void *malloc(size_t size);
    void free(void *ptr);
]]
local tonumber = tonumber
local tostring = tostring
local next = next
local type = type
local error = error
local setmetatable = setmetatable

local sprintf = string.format

local fill = ffi.fill
local copy = ffi.copy
local cast = ffi.cast
local sizeof = ffi.sizeof
local string = ffi.string
local new = ffi.new
local C = ffi.C

local ceil = math.ceil
local floor = math.floor

local insert = table.insert
local sort = table.sort

local stderr = io.stderr
local stdout = io.stdout
local sprintf = string.format

-----------------------LOG------------------------

function stderr(str, ...)
    stderr:write("\27[30;41m", sprintf(str, ...) .. "\27[0m\n")
end

function stdwar(str, ...)
    stdout:write("\27[30;43m", sprintf(str, ...) .. "\27[0m\n")
end

function stdinf(str, ...)
    stdout:write("\27[30;42m", sprintf(str, ...) .. "\27[0m\n")
end

----------------------SHMMGR----------------------
local _SHMMGR = {
    _VERSION = "0.1.0"
}

local shmmgr = {
    __index = _SHMMGR
}

local function mmap(size)
    --[[
        PROT_READ      0x1                /* Page can be read.  */
        PROT_WRITE     0x2                /* Page can be written.  */
        MAP_SHARED     0x01               /* Share changes.  */
        MAP_ANONYMOUS  0x20               /* Don't use a file.  */
    ]]
    local ptr = C.mmap(nil, size, 3, 33, -1, 0) -- MAP_ANONYMOUS | MAP_SHARED
    if ptr == cast("void *", -1) then
        return false, "mmap failed"
    end
    return ptr
end

local function munmap(ptr, size)
    if C.munmap(ptr, size) == -1 then
        return false, 'munmap failed'
    end
    return true
end

function _SHMMGR:destroyShm(is_force)

    local ok, err = munmap(ptr.ptr, ptr.size)
    if not ok and not is_force then
        -- log err
    end
    ptr.ptr = nil

    return true
end

function _SHMMGR:createShm(size)
    local ptr = self.ptr
    if ptr.ptr ~= nil then
        if ptr.size == size then -- 不需重复创建
            return true
        end
        local ok, err = munmap(ptr.ptr, ptr.size)
        if not ok then
            return false, err
        end
    end
    local shm, err = mmap(size)
    if not shm then
        return false, err
    end
    ptr.ptr = shm
    ptr.size = size
    ptr.owner = self.pid
    return true
end

----------------------GLOBAL-----------------------

local _GLOBAL = {
    _VERSION = "0.1.0"
}

local global = {
    __index = _GLOBAL
}
    
function _GLOBAL.init(dict)



end


local setter_mt = {
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
}


----------------------CONVERT----------------------
local function string2char(string, ptr)
    copy(ptr, string, #string)
    return true
end



local function char2string(char, len)
    return string(char, len)
end

local function double2number(double)
    return tonumber(double)
end

local function uchar2boolean(uchar)
    if uchar == 0U then
        return false
    end
    return true
end

----------------------SETTER-----------------------

local dt = {
    string = {'char[%d]', char2string},
    number = {'double', double2number},
    boolean = {'uint8_t', uchar2boolean},
}

function _POINTER.new(dict, size)
    if not dict or not dict.get then
        return false, "invalid dict"
    end
    local header
    local addr, csize = dict:get(DICT_KEY_NAME)
    if addr then
        header = cast("shm_header *", addr)
    else
        local ptr = C.malloc(size)
        if not ptr then
            return false, "alloc memory failed"
        end
        addr = tonumber(cast("intptr_t", ptr))
        local ok, err = dict:set(DICT_KEY_NAME, addr, 0, size)
        header = cast("shm_header *", ptr)
    end


    local arr = {
        name = "default",
        size = size,
        shm = header
    }
    if string(header.magic, 3) == MAGIC_CODE and header.version == VERSION then
        -- TODO reload things
    else
        init(arr)
    end

    return setmetatable(arr, pointer)
end

function _POINTER.fake(size)
    local header = cast("shm_header *", C.malloc(size))
    local arr = {
        name = "fake",
        size = size,
        shm = header
    }
    init(arr)
    return setmetatable(arr, pointer)
end

return _POINTER
