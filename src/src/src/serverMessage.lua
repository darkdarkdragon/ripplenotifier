local JSON = require 'JSON'
local inspect = require 'inspect'
local serverMessage = {}

-- local log = print
local log = function() end
if ngx then
  log = ngx.log
else
  ngx = { INFO = 'info' }
end

function serverMessage:new(strMessageData)
  -- log(ngx.INFO, 'serverMessage:new', strMessageData)
  local o = { valid = false, type = 'none', status = 'none', parsed =  {} }
  setmetatable(o, self)
  self.__index = self

  if strMessageData then
    self.parseMessage(o, strMessageData)
  end

  return o
end

function serverMessage.create(strMessageData)
  local sm = serverMessage:new()
  sm:parseMessage(strMessageData)
  return sm
end


function serverMessage:parseMessage(strMessageData)
  local status, err = pcall(function()
    -- log(ngx.INFO, 'serverMessage:parseMessage', strMessageData)
    local im = JSON:decode(strMessageData)
    -- ngx.log(ngx.INFO, "received type: ", im.type, ' status:', im.status)
    log(ngx.INFO, "received type: ", im.type, ' status:', im.status)
    if not im.type then
      return
    end
    self.valid = true
    
    self.data = im
    self.type = im.type
    self.status = im.status
    -- self.TransactionType = im.TransactionType
    self.engine_result = im.engine_result
    -- print (inspect(im))

    if self:isTransaction() then
      -- ngx.log(ngx.INFO, "got transaction ", im.type, ' status:', im.status, ' TransactionType:', im.TransactionType)
      self.transaction = im.transaction
      log(ngx.INFO, 'got transaction ', im.type, ' status:', im.status, ' TransactionType:', self.transaction.TransactionType)
      if self:isPayment() then
        self:parsePayment()
      end
    end
  end)
  -- print('status', status, 'err', err)
  if err then
    log(ngx.INFO, 'Error in serverMessage:parseMessage', inspect(err))
  end
end

function serverMessage:parsePayment()
  local data = self.data
  local payment = {}
  
  payment.account = data.transaction.Account
  payment.amount = data.transaction.Amount
  payment.amountHuman = serverMessage.amountToHuman(payment.amount)
  payment.destination = data.transaction.Destination
  payment.fee = data.transaction.Fee
  payment.date = data.transaction.date
  payment.hash = data.transaction.hash

  self.payment = payment
  -- log(ngx.INFO, 'payment:', inspect(self.payment))
  -- @TODO all this:
  -- parse date
  -- check how to parse amount currency
  -- make amount human readable
  -- make message for notification
  -- check destination (?account) if in base to push notification
  -- call api that make notification call
end

function serverMessage:isPayment()
  return (self.valid and self.type == 'transaction' and self.status == 'closed' and self.engine_result == 'tesSUCCESS' and self.transaction and self.transaction.TransactionType == 'Payment')
end

function serverMessage:isTransaction()
  return (self.valid and self.type == 'transaction')
end

function serverMessage.amountToHuman(amount)
  if type(amount) == 'table' then
    if amount.currency and amount.value then
      return amount.value .. ' ' .. amount.currency
    end
  elseif type(amount) == 'string' then
    return (amount / 1000000) .. ' XRP'
  end
  return 'invalid'
end

-- /**
--  * Convert a ripple epoch to a JavaScript timestamp.
--  *
--  * JavaScript timestamps are unix epoch in milliseconds.
--  */
function serverMessage.toTimestamp(rpepoch)
  return (rpepoch + 0x386D4380) * 1000
end

-- /**
--  * Convert a ripple epoch to a JavaScript timestamp.
--  *
--  * JavaScript timestamps are unix epoch in seconds.
--  */
function serverMessage.toTimestampSeconds(rpepoch)
  return rpepoch + 0x386D4380
end

-- /**
--  * Convert a JavaScript timestamp or Date to a Ripple epoch.
--  *
--  * JavaScript timestamps are unix epoch in milliseconds.
--  */
-- function fromTimestamp(rpepoch) {
--   if (rpepoch instanceof Date) {
--     rpepoch = rpepoch.getTime();
--   }

--   return Math.round(rpepoch / 1000) - 0x386D4380;
-- };


return serverMessage
