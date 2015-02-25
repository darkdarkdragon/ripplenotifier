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
local transStrTest2 = '{"engine_result":"tesSUCCESS","engine_result_code":0,"engine_result_message":"The transaction was applied. Only final in a validated ledger.","ledger_hash":"0A4576A7C68D2EA03F188FA762EE70C4020EE1E453FE5DB019232FBBABA264D9","ledger_index":11794464,"meta":{"AffectedNodes":[{"ModifiedNode":{"FinalFields":{"Account":"rfXnhhuqPEAn5dqqTqgBKyCqivykxkdtm5","Balance":"4331149529","Flags":0,"OwnerCount":6,"Sequence":50},"LedgerEntryType":"AccountRoot","LedgerIndex":"31E994FEDEF1FC707D0BBE43C3836662A452CD1ECB61F8FFD62476A6CE92C3C4","PreviousFields":{"Balance":"4331161529","Sequence":49},"PreviousTxnID":"B0C8CB440368E71B3A055AD33F94D59D96F0EA537E45D1E351153ADFBCEAADE0","PreviousTxnLgrSeq":11738041}},{"ModifiedNode":{"FinalFields":{"Balance":{"currency":"USD","issuer":"rrrrrrrrrrrrrrrrrrrrBZbvji","value":"0.699422741692601"},"Flags":1114112,"HighLimit":{"currency":"USD","issuer":"rMwjYedjc7qqtKYVLiAccJSmCwih4LnE2q","value":"0"},"HighNode":"000000000000028E","LowLimit":{"currency":"USD","issuer":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","value":"1000000000"},"LowNode":"0000000000000000"},"LedgerEntryType":"RippleState","LedgerIndex":"BF968B74560E2439E2CECC951F38E992183D42D68DF823E80D608DEF89664D8D","PreviousFields":{"Balance":{"currency":"USD","issuer":"rrrrrrrrrrrrrrrrrrrrBZbvji","value":"0.699322741692601"}},"PreviousTxnID":"6B6489978C8B253842EBE60524A9FF804752BEAFB2F17FF8935B70D1272768F9","PreviousTxnLgrSeq":11714007}},{"ModifiedNode":{"FinalFields":{"Balance":{"currency":"USD","issuer":"rrrrrrrrrrrrrrrrrrrrBZbvji","value":"0.0177874808972"},"Flags":1114112,"HighLimit":{"currency":"USD","issuer":"rMwjYedjc7qqtKYVLiAccJSmCwih4LnE2q","value":"0"},"HighNode":"0000000000000193","LowLimit":{"currency":"USD","issuer":"rfXnhhuqPEAn5dqqTqgBKyCqivykxkdtm5","value":"1000000000"},"LowNode":"0000000000000000"},"LedgerEntryType":"RippleState","LedgerIndex":"FACA6A2FAFA23FA99146D852BA33287A563D8596031D939DA26A194DB2066DFC","PreviousFields":{"Balance":{"currency":"USD","issuer":"rrrrrrrrrrrrrrrrrrrrBZbvji","value":"0.0178874808972"}},"PreviousTxnID":"0C89EBF344A39462D687AEE3D47CC80B370FD8B0F49DFC6431530DFA01AF2AAE","PreviousTxnLgrSeq":11127083}}],"TransactionIndex":4,"TransactionResult":"tesSUCCESS"},"status":"closed","transaction":{"Account":"rfXnhhuqPEAn5dqqTqgBKyCqivykxkdtm5","Amount":{"currency":"USD","issuer":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","value":"0.0001"},"Destination":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","Fee":"12000","Flags":0,"LastLedgerSequence":11794467,"Memos":[{"Memo":{"MemoFormat":"7274312E332E33","MemoType":"636C69656E74"}}],"SendMax":{"currency":"USD","issuer":"rMwjYedjc7qqtKYVLiAccJSmCwih4LnE2q","value":"0.0001001"},"Sequence":49,"SigningPubKey":"02760BE55D1C6861870F26E2413EE408FA2253F6D90BE648EAA6C100831579FCA8","TransactionType":"Payment","TxnSignature":"3045022100B90AF95EA0E6C399295C08ED31EEE73C92AC530EF5D8944EB7F52CD1AAC5881E02201781CBAB4521F411AB317BE2FE4BC809FA9098FA710A7CFEE559F5CE724703E5","date":477614130,"hash":"8C91E73E4AF0458B7CFDF4E932FDF9C6F263E56E8B56C413AAF3C92B1E06C6CB"},"type":"transaction","validated":true}'


local accountsNames = { }
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



function _M.getAccountName(account)
  if not accountsNames[account] then
    accountsNames[account] = blobClient.resolveName(account)
    if not accountsNames[account] then
      accountsNames[account] = account
    end
  end
  return accountsNames[account]
end

function _M.processIncomingMessage(incomingMessage)
  local sm = serverMessage:new(incomingMessage)
  if sm:isPayment() then
    local desc = monitored[sm.payment.destination]
    -- ngx.log(ngx.INFO, 'desc ' .. inspect(desc))
    if desc then
      local username = _M.getAccountName(sm.payment.destination)
      local senderUsername = _M.getAccountName(sm.payment.account)

      ngx.log(ngx.INFO, 'got payment transaction for ' .. username .. '(' .. sm.payment.destination .. ') amount ' .. sm.payment.amountHuman)
      -- sm.message = 'got payment transaction for ' .. username .. '(' .. k .. ') amount ' .. sm.payment.amountHuman
      -- sm.message = username .. ' received ' .. sm.payment.amountHuman
      local date = os.date('%Y-%m-%d %X', serverMessage.toTimestampSeconds(sm.payment.date))
      sm.payment.message = username .. ' received ' .. sm.payment.amountHuman .. ' from ' .. senderUsername .. ' at ' .. date
      sendToGoogleCloudServer(k, sm.payment)
    end
  end
end

function sendToGoogleCloudServer(account, sm)
  local desc = monitored[account]
  ngx.log(ngx.INFO, 'sendToGoogleCloudServer', inspect(desc))
  ngx.log(ngx.INFO, 'sendToGoogleCloudServer', inspect(sm))
  ngx.log(ngx.INFO, 'sendToGoogleCloudServer ', account)
  local dataToSend = { registration_ids = { "APA91bFVhUeSnepFYOaZhbm6v09r6nRXYxKogtPkK7fLcozQnH2i31asGlb_8Z6Jtfi1A0qHft3LMLacoNql3JHW-Hk0yQYWRlj2k3YW7dwGPO378-2avWb0H_z6i7eN04vJPcFmfck_9r8Y766o69RPir3eQPzVvQ" }, data = sm }
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
  -- for k,v in pairs(res.headers) do
    --
  -- end
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
  -- _M.processIncomingMessage(transStrTest1)
  _M.processIncomingMessage(transStrTest2)
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
