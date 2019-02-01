local cjson = require("cjson")
local fpath = string.gsub(ngx.var.uri, "redirect", "download", 1)

local f = io.open("/mnt/ceph" .. fpath)
if not f then
    ngx.exit(404)
end

local route = f:read()
f:close()

ngx.redirect(route)
