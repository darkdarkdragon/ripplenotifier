local _M = {}


function _M.run()
    ngx.log(ngx.INFO, 'Hello from request handler!');
    ngx.say("<p>hello, again, A, B, C, world</p>")
    ngx.flush(true)
    --ngx.sleep(5)
    ngx.say("<p>hello, again, A, B, C, D, world</p>")
    local client = require "resty.websocket.client"

    local wb, err = client:new()
    local uri = "ws://s-west.ripple.com:443"
    local ok, err = wb:connect(uri)
    if not ok then
        ngx.say("failed to connect: " .. err)
        return
    end

    local bytes, err = wb:send_text("{\"id\": 1, \"command\": \"server_info\" }")
    if not bytes then
        ngx.say("failed to send frame: ", err)
        return
    end

    local data, typ, err = wb:recv_frame()
    if not data then
        ngx.say("failed to receive the frame: ", err)
        return
    end

    ngx.say("received: ", data, " (", typ, "): ", err)

    local bytes, err = wb:send_close()
    if not bytes then
        ngx.say("failed to send close: ", err)
        return
    end
--  ngx.exit(0)
end

--run()
return _M
