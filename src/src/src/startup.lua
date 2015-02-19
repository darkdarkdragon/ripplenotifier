local _M = {}

local client = require "resty.websocket.client"
local JSON = require "JSON"
local serverMessage = require 'serverMessage'
local blobClient = require 'blobClient'
local inspect = require 'inspect'
local http = require 'resty.http'

-- function _M.run()
--     ngx.log(ngx.INFO, 'Hello from startup!');
-- end

local transStrTest1 = '{"engine_result":"tesSUCCESS","engine_result_code":0,"engine_result_message":"The transaction was applied. Only final in a validated ledger.","ledger_hash":"36DF35E2D134162423B84098B71BE363F3137FE8DC2AC6ACB40942F467214BC3","ledger_index":11200596,"meta":{"AffectedNodes":[{"ModifiedNode":{"FinalFields":{"Account":"rp8rJYTpodf8qbSCHVTNacf8nSW8mRakFw","Balance":"50819800","Flags":0,"OwnerCount":4,"Sequence":16},"LedgerEntryType":"AccountRoot","LedgerIndex":"8B24E55376A65D68542C17F3BF446231AC7062CB43BED28817570128A1849819","PreviousFields":{"Balance":"50831900","Sequence":15},"PreviousTxnID":"4A4DF610DEDD5A5C7097C92B2AF976AD60CCD926721C216AD62BAE71F596FA4B","PreviousTxnLgrSeq":11046902}},{"ModifiedNode":{"FinalFields":{"Account":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","Balance":"118539447","Flags":0,"OwnerCount":8,"Sequence":549},"LedgerEntryType":"AccountRoot","LedgerIndex":"E47087B762FD22F5F36E8B7188BEA18659F443092041684A6C0C757609E1DF86","PreviousFields":{"Balance":"118539347"},"PreviousTxnID":"EB5E7456F73416CF21F3EC4912E43F3052F347A0B56B50F7C255B4028C66DC5E","PreviousTxnLgrSeq":11159108}}],"TransactionIndex":3,"TransactionResult":"tesSUCCESS"},"status":"closed","transaction":{"Account":"rp8rJYTpodf8qbSCHVTNacf8nSW8mRakFw","Amount":"100","Destination":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","Fee":"12000","Flags":0,"LastLedgerSequence":11200598,"Memos":[{"Memo":{"MemoData":"7274312E322E31","MemoType":"636C69656E74"}}],"Sequence":15,"SigningPubKey":"023DF3A034F5C7F4FE9F247ECCD7ABAC5DC3F2819F3C62AD9B9D2E9690DBAA84EB","TransactionType":"Payment","TxnSignature":"3045022100823FB809DEB35C47607B0AEDA8962543EDA3E4401C2B5013878BFCDDD83DCADA02203CBA1D999BFE0A6FA56EEDAB4FC3D5981CFA663BC4C18B3F0DF45C8F049ADB0D","date":474942980,"hash":"60B9CF1647EF6E4E86F588F0729A3CBE3C17380321C01294F39B780DE266E38F"},"type":"transaction","validated":true}'


local monitored = { 
  -- vakula
  rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR = {   } }

-- local authInfoBaseUri = 'https://id.ripple.com/v1/authinfo'
-- local authInfoBaseUri = '/rippleauth/v1/authinfo'

function connect()
    --local wb, err = client:new({timeout = 60000})
    local wb, err = client:new{timeout = 10000}
    --local uri = "ws://s-west.ripple.com:443"
    local uri = "ws://s1.ripple.com:443"
    local ok, err = wb:connect(uri)
    return wb, ok, err
end



function _M.processIncomingMessage(incomingMessage)
  local sm = serverMessage:new(incomingMessage)
  if sm:isPayment() then
    for k,v in pairs(monitored) do
      if sm.payment.destination == k then
        local username = v.username
        if not username then
          username = blobClient.resolveName(sm.payment.destination)
          v.username = username
        end

        ngx.log(ngx.INFO, 'got payment transaction for ' .. username .. '(' .. k .. ') amount ' .. sm.payment.amountHuman)
        sendToGoogleCloudServer(k, sm)
      end
    end
  end
end

function sendToGoogleCloudServer(account, sm)
  local desc = monitored[account]
  -- ngx.log(ngx.INFO, 'sendToGoogleCloudServer', inspect(desc))
  ngx.log(ngx.INFO, 'sendToGoogleCloudServer ', account)
  local dataToSend = { registration_ids = { "1" }, data = sm }
  local httpc = http.new()
  local res, err = httpc:request_uri("https://android.googleapis.com/gcm/send", {
    ssl_verify = false,
    method = "POST",
    body = JSON:encode(dataToSend),
    headers = {
      ['Content-Type'] = 'application/json',
      ["Authorization"] = 'key=AIzaSyAeyN5dT-TZHHJ5Z4C9mWHpkz8XADRKxWI'
    }
  })

  if not res then
    ngx.log(ngx.ERR, "failed to request: ", err)
    return
  end  
  for k,v in pairs(res.headers) do
    --
  end
  ngx.log(ngx.INFO, 'status ', res.status)
  ngx.log(ngx.INFO, res.body)
  local response
  local status, err = pcall(function()
    response = JSON:decode(res.body)
  end)
  -- print('status', status, 'err', err)
  if not status then
    -- error happened
    return
  end
  -- ngx.log(ngx.INFO, 'response ', inspect(response))
  for k, v in pairs(response.results) do
    -- ngx.log(ngx.INFO, 'result ', inspect(v))
    if v.error == 'InvalidRegistration' then
      -- @TODO remove registration id
      ngx.log(ngx.INFO, 'result error - need to remove registration id', inspect(v))
    end
  end 
end

function timed()
  ngx.log(ngx.INFO, 'worker init timed function starting');

    --local wb, err = client:new()
    --local uri = "ws://s-west.ripple.com:443"
    --local ok, err = wb:connect(uri)
    --if not ok then
    --   ngx.log(ngx.ERR, "failed to connect: ", err)
    --    return
    --end
    --local wb, ok, err = connect({'timeout': 60000})
    local wb, ok, err = connect()
    if not ok then
       ngx.log(ngx.ERR, "failed to connect: ", err)
        return
    end

    local bytes, err = wb:send_text("{\"id\": 1, \"command\": \"server_info\" }")
    if not bytes then
        ngx.log(ngx.ERR, "failed to send frame: ", err)
        return
    end

    local data, typ, err = wb:recv_frame()
    if not data then
        ngx.log(ngx.ERR, "failed to receive the frame: ",  err)
        return
    end

    --ngx.log(ngx.INFO, "received: ", data, " (", typ, "): ", err)
    ngx.log(ngx.INFO, "received: ", data)
    
    -- bitstamp
    --local bytes, err = wb:send_text('{"id": 2,"command": "subscribe","accounts": ["rrpNnNLKrartuEqfJGpqyDwPj1AFPg9vn1"]}')
    -- varhat - rp8rJYTpodf8qbSCHVTNacf8nSW8mRakFw
    -- vakula - rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR
    local bytes, err = wb:send_text('{"id": 2,"command": "subscribe","accounts": ["rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR"]}')

    local bytes, err = wb:send_text('{"command":"subscribe","id":3,"streams":["ledger","server"]}')
    
    if not bytes then
        ngx.log(ngx.ERR, "failed to send frame: ", err)
        return
    end

    local idc = 4
    while true do
        local data, typ, err = wb:recv_frame()
        if not data then
            if string.find(err, 'timeout') then
              local bytes, err = wb:send_text('{"id": ' .. idc .. ',"command": "ping"}')
              idc = idc + 1
            elseif string.find(err, 'closed') then
                wb, ok, err = connect()
                if not ok then
                   ngx.log(ngx.ERR, "failed to re-connect: ", err)
                    return
                end
                ngx.log(ngx.INFO, 'reconnected to server')
            else
              ngx.log(ngx.ERR, "failed to receive the frame: ", typ, err)
              return
            end
        end
        ngx.log(ngx.INFO, "received: ", data)
        local exiting = ngx.worker.exiting()
        if exiting then
            return
        end
        if (data and data ~= 'ping') then
            _M.processIncomingMessage(data)
        end
    end

    --local bytes, err = wb:send_close()
    --if not bytes then
    --    ngx.say("failed to send close: ", err)
    --    return
    --end
end

function _M.test1()
    _M.processIncomingMessage(transStrTest1)
end

-- location.capture not working in timer or init context. need to use pure socket
-- https://github.com/pintsized/lua-resty-http
-- so skip by now
function _M.getNameByProxy(account)
  if not account then
    return ''
  end
  -- local uri = authInfoBaseUri .. '?username=' .. account
  -- res = ngx.location.capture(uri, options?)

  -- search for "openresty" in google over https:
  local uri = authInfoBaseUri
  local res = ngx.location.capture(uri, { args = { username = account } })
  if res.status ~= 200 then
      ngx.say("failed to query google: ", res.status, ": ", res.body)
      return
  end

  -- here we just forward the Google search result page intact:
  ngx.header["Content-Type"] = "text/html; charset=UTF-8"
  ngx.say(res.body)  
  ngx.log(ngx.INFO, 'res:', inspect(res))

end

function _M.testName1()
  local name = blobClient.resolveName('rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR')
  ngx.log(ngx.INFO, 'got name: ' .. name)
end


ngx.log(ngx.INFO, 'Starting worker init');
--_M.run()

-- ngx.timer.at(0, timed)
ngx.timer.at(0, _M.test1)
-- ngx.timer.at(0, _M.testName1)
-- _M.testName1()

return _M
