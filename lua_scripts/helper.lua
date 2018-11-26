local _M = {}

local function split(str, sep)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

local function find_filename(res)
    for i, v in ipairs(res) do
        if string.find(v, ';') ~= nil then
            local ret = find_filename(split(v, ';'))
            if ret ~= nil then
                return ret
            end
        else
            local ret = string.match(v, 'name="(%S+)"')
            if ret ~= nil then
                return ret
            end
        end
    end
    return nil
end

local function file_exists(path)
    local f = io.open(path, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

_M['find_filename'] = find_filename
_M['file_exists'] = file_exists
_M['_Version'] = '0.1'

return _M
