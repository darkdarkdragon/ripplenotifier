
local JSON = require 'JSON'
local inspect = require 'inspect'
local http = require 'resty.http'

local authInfoBaseUri = 'https://id.ripple.com/v1/authinfo'

local blobClient = {}

function blobClient.resolveName(account)
  if not account then
    return ''
  end
  local httpc = http.new()
  local uri = authInfoBaseUri .. '?username=' .. account
  local res, err = httpc:request_uri(uri, { method = "GET", ssl_verify = false })

  if not res then
    ngx.log(ngx.WARN, "failed to request: ", err)
    return ''
  end

  if res.status ~= 200 then
    ngx.log(ngx.WARN, "failed to request: ", inspect(res))
    return ''
  end

  -- for k,v in pairs(res.headers) do
  --     ngx.log(ngx.INFO, k .. ' : ' .. v)
  -- end
  -- ngx.log(ngx.INFO, res.body)
  local status, name = pcall(function()
    local data = JSON:decode(res.body)
    if data.username then
      return data.username
    end
  end)
  -- print('status', status, 'err', err)
  if status then
    return name
  end
  ngx.log(ngx.WARN, 'Error in blobClient.resolveName ', inspect(name))

  return ''
end

return blobClient
