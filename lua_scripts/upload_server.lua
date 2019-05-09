local str = require "resty.string"
local resty_md5 = require "resty.md5"
local upload = require "resty.upload"
local helper = require "helper"
local cjson = require "cjson"
if helper == nil then
    ngx.say("not find helper lib")
    return
end

local chunk_size = 4096
local form, err = upload:new(chunk_size)
if not form then
    ngx.log(ngx.ERR, "failed to new upload: ", err)
    ngx.exit(500)
end
local md5 = resty_md5:new()
local file
local tmp = {}
local ret = {}
getPath=function(str,sep)
    sep=sep or'/'
    return str:match("(.*"..sep..")")
end
while true do
    local typ, res, err = form:read()

    if not typ then
         ngx.say("failed to read: ", err)
         if file then
	     file:close()
	     file = nil
         end
         return
    end

    if typ == "header" then
        if #res == 3 and res[1] == "Content-Disposition" then
            local file_name = helper.find_filename(res)
            if file_name then
                local path = "/fileserver/download/" .. file_name
		local dir = getPath(path)
		local status = os.execute('mkdir -p '..dir)
                if not status then
                    ngx.say(cjson.encode({code=501, msg=status}))
                    return
                end
                file = io.open(path, "w+")
                if not file then
                    ngx.say("failed to open file ", file_name)
                    return
                else
                    tmp[file] = file_name 
                end
            end
        end

     elseif typ == "body" then
        if file then
            file:write(res)
            md5:update(res)
        end

    elseif typ == "part_end" then
        if file then
            local md5_sum = md5:final()
            local url = "http://172.16.30.25/download/" .. tmp[file]	
            table.insert(ret, {url=url, md5=str.to_hex(md5_sum)})
            tmp[file] = nil
            file:close()
        end
        file = nil
        md5:reset()

    elseif typ == "eof" then
        ngx.say(cjson.encode(ret))
	if file then
	    file:close()
            file = nil
        end
        ret = nil
        break

    else
	if file then
	    file:close()
            file = nil
        end
    end
end

