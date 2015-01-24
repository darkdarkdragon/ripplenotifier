local _M = {}

local client = require "resty.websocket.client"
local JSON = require "JSON"

function _M.run()
    ngx.log(ngx.INFO, 'Hello from startup!');
end


function connect()
    --local wb, err = client:new({timeout = 60000})
    local wb, err = client:new{timeout = 10000}
    --local uri = "ws://s-west.ripple.com:443"
    local uri = "ws://s1.ripple.com:443"
    local ok, err = wb:connect(uri)
    return wb, ok, err
end

local transStrTest = '{"engine_result":"tesSUCCESS","engine_result_code":0,"engine_result_message":"The transaction was applied. Only final in a validated ledger.","ledger_hash":"36DF35E2D134162423B84098B71BE363F3137FE8DC2AC6ACB40942F467214BC3","ledger_index":11200596,"meta":{"AffectedNodes":[{"ModifiedNode":{"FinalFields":{"Account":"rp8rJYTpodf8qbSCHVTNacf8nSW8mRakFw","Balance":"50819800","Flags":0,"OwnerCount":4,"Sequence":16},"LedgerEntryType":"AccountRoot","LedgerIndex":"8B24E55376A65D68542C17F3BF446231AC7062CB43BED28817570128A1849819","PreviousFields":{"Balance":"50831900","Sequence":15},"PreviousTxnID":"4A4DF610DEDD5A5C7097C92B2AF976AD60CCD926721C216AD62BAE71F596FA4B","PreviousTxnLgrSeq":11046902}},{"ModifiedNode":{"FinalFields":{"Account":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","Balance":"118539447","Flags":0,"OwnerCount":8,"Sequence":549},"LedgerEntryType":"AccountRoot","LedgerIndex":"E47087B762FD22F5F36E8B7188BEA18659F443092041684A6C0C757609E1DF86","PreviousFields":{"Balance":"118539347"},"PreviousTxnID":"EB5E7456F73416CF21F3EC4912E43F3052F347A0B56B50F7C255B4028C66DC5E","PreviousTxnLgrSeq":11159108}}],"TransactionIndex":3,"TransactionResult":"tesSUCCESS"},"status":"closed","transaction":{"Account":"rp8rJYTpodf8qbSCHVTNacf8nSW8mRakFw","Amount":"100","Destination":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","Fee":"12000","Flags":0,"LastLedgerSequence":11200598,"Memos":[{"Memo":{"MemoData":"7274312E322E31","MemoType":"636C69656E74"}}],"Sequence":15,"SigningPubKey":"023DF3A034F5C7F4FE9F247ECCD7ABAC5DC3F2819F3C62AD9B9D2E9690DBAA84EB","TransactionType":"Payment","TxnSignature":"3045022100823FB809DEB35C47607B0AEDA8962543EDA3E4401C2B5013878BFCDDD83DCADA02203CBA1D999BFE0A6FA56EEDAB4FC3D5981CFA663BC4C18B3F0DF45C8F049ADB0D","date":474942980,"hash":"60B9CF1647EF6E4E86F588F0729A3CBE3C17380321C01294F39B780DE266E38F"},"type":"transaction","validated":true}'

function processIncomingMessage(incomingMessage)
    pcall(function()
      local im = JSON:decode(data)
      ngx.log(ngx.INFO, "received type: ", im.type, ' status:', im.status)
      if (im.type == 'transaction' and im.status == 'closed ' and im.engine_result == 'tesSUCCESS') then
        ngx.log(ngx.INFO, "got transaction ", im.type, ' status:', im.status, ' TransactionType:', im.TransactionType)
        if im.TransactionType == 'Payment' then
          local account = im.Account
          local amount = im.Amount
          local destination = im.Destination
          local fee = im.Fee
          local date = im.date
          -- @TODO all this:
          -- parse date
          -- check how to parse amount currency
          -- make amount human readable
          -- make message for notification
          -- check destination (?account) if in base to push notification
          -- call api that make notification call
        end
      end
    end)

end

function timed()
  ngx.log(ngx.INFO, 'starting timed function!');

    processIncomingMessage(transStrTest)

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
            processIncomingMessage(data)
        end
    end

    --local bytes, err = wb:send_close()
    --if not bytes then
    --    ngx.say("failed to send close: ", err)
    --    return
    --end

end

ngx.log(ngx.INFO, 'Hello from startup 1!');
--_M.run()

ngx.timer.at(0, timed)

return _M
