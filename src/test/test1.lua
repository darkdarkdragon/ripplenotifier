
package.path = '../src/src/?.lua;' .. package.path

-- print (package.path)

local serverMessage = require 'serverMessage'
local inspect = require 'inspect'
local JSON = require 'JSON'

local transStrTest1 = '{"engine_result":"tesSUCCESS","engine_result_code":0,"engine_result_message":"The transaction was applied. Only final in a validated ledger.","ledger_hash":"36DF35E2D134162423B84098B71BE363F3137FE8DC2AC6ACB40942F467214BC3","ledger_index":11200596,"meta":{"AffectedNodes":[{"ModifiedNode":{"FinalFields":{"Account":"rp8rJYTpodf8qbSCHVTNacf8nSW8mRakFw","Balance":"50819800","Flags":0,"OwnerCount":4,"Sequence":16},"LedgerEntryType":"AccountRoot","LedgerIndex":"8B24E55376A65D68542C17F3BF446231AC7062CB43BED28817570128A1849819","PreviousFields":{"Balance":"50831900","Sequence":15},"PreviousTxnID":"4A4DF610DEDD5A5C7097C92B2AF976AD60CCD926721C216AD62BAE71F596FA4B","PreviousTxnLgrSeq":11046902}},{"ModifiedNode":{"FinalFields":{"Account":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","Balance":"118539447","Flags":0,"OwnerCount":8,"Sequence":549},"LedgerEntryType":"AccountRoot","LedgerIndex":"E47087B762FD22F5F36E8B7188BEA18659F443092041684A6C0C757609E1DF86","PreviousFields":{"Balance":"118539347"},"PreviousTxnID":"EB5E7456F73416CF21F3EC4912E43F3052F347A0B56B50F7C255B4028C66DC5E","PreviousTxnLgrSeq":11159108}}],"TransactionIndex":3,"TransactionResult":"tesSUCCESS"},"status":"closed","transaction":{"Account":"rp8rJYTpodf8qbSCHVTNacf8nSW8mRakFw","Amount":"100","Destination":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","Fee":"12000","Flags":0,"LastLedgerSequence":11200598,"Memos":[{"Memo":{"MemoData":"7274312E322E31","MemoType":"636C69656E74"}}],"Sequence":15,"SigningPubKey":"023DF3A034F5C7F4FE9F247ECCD7ABAC5DC3F2819F3C62AD9B9D2E9690DBAA84EB","TransactionType":"Payment","TxnSignature":"3045022100823FB809DEB35C47607B0AEDA8962543EDA3E4401C2B5013878BFCDDD83DCADA02203CBA1D999BFE0A6FA56EEDAB4FC3D5981CFA663BC4C18B3F0DF45C8F049ADB0D","date":474942980,"hash":"60B9CF1647EF6E4E86F588F0729A3CBE3C17380321C01294F39B780DE266E38F"},"type":"transaction","validated":true}'
local transStrTest2 = '{"engine_result":"tesSUCCESS","engine_result_code":0,"engine_result_message":"The transaction was applied. Only final in a validated ledger.","ledger_hash":"0A4576A7C68D2EA03F188FA762EE70C4020EE1E453FE5DB019232FBBABA264D9","ledger_index":11794464,"meta":{"AffectedNodes":[{"ModifiedNode":{"FinalFields":{"Account":"rfXnhhuqPEAn5dqqTqgBKyCqivykxkdtm5","Balance":"4331149529","Flags":0,"OwnerCount":6,"Sequence":50},"LedgerEntryType":"AccountRoot","LedgerIndex":"31E994FEDEF1FC707D0BBE43C3836662A452CD1ECB61F8FFD62476A6CE92C3C4","PreviousFields":{"Balance":"4331161529","Sequence":49},"PreviousTxnID":"B0C8CB440368E71B3A055AD33F94D59D96F0EA537E45D1E351153ADFBCEAADE0","PreviousTxnLgrSeq":11738041}},{"ModifiedNode":{"FinalFields":{"Balance":{"currency":"USD","issuer":"rrrrrrrrrrrrrrrrrrrrBZbvji","value":"0.699422741692601"},"Flags":1114112,"HighLimit":{"currency":"USD","issuer":"rMwjYedjc7qqtKYVLiAccJSmCwih4LnE2q","value":"0"},"HighNode":"000000000000028E","LowLimit":{"currency":"USD","issuer":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","value":"1000000000"},"LowNode":"0000000000000000"},"LedgerEntryType":"RippleState","LedgerIndex":"BF968B74560E2439E2CECC951F38E992183D42D68DF823E80D608DEF89664D8D","PreviousFields":{"Balance":{"currency":"USD","issuer":"rrrrrrrrrrrrrrrrrrrrBZbvji","value":"0.699322741692601"}},"PreviousTxnID":"6B6489978C8B253842EBE60524A9FF804752BEAFB2F17FF8935B70D1272768F9","PreviousTxnLgrSeq":11714007}},{"ModifiedNode":{"FinalFields":{"Balance":{"currency":"USD","issuer":"rrrrrrrrrrrrrrrrrrrrBZbvji","value":"0.0177874808972"},"Flags":1114112,"HighLimit":{"currency":"USD","issuer":"rMwjYedjc7qqtKYVLiAccJSmCwih4LnE2q","value":"0"},"HighNode":"0000000000000193","LowLimit":{"currency":"USD","issuer":"rfXnhhuqPEAn5dqqTqgBKyCqivykxkdtm5","value":"1000000000"},"LowNode":"0000000000000000"},"LedgerEntryType":"RippleState","LedgerIndex":"FACA6A2FAFA23FA99146D852BA33287A563D8596031D939DA26A194DB2066DFC","PreviousFields":{"Balance":{"currency":"USD","issuer":"rrrrrrrrrrrrrrrrrrrrBZbvji","value":"0.0178874808972"}},"PreviousTxnID":"0C89EBF344A39462D687AEE3D47CC80B370FD8B0F49DFC6431530DFA01AF2AAE","PreviousTxnLgrSeq":11127083}}],"TransactionIndex":4,"TransactionResult":"tesSUCCESS"},"status":"closed","transaction":{"Account":"rfXnhhuqPEAn5dqqTqgBKyCqivykxkdtm5","Amount":{"currency":"USD","issuer":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","value":"0.0001"},"Destination":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","Fee":"12000","Flags":0,"LastLedgerSequence":11794467,"Memos":[{"Memo":{"MemoFormat":"7274312E332E33","MemoType":"636C69656E74"}}],"SendMax":{"currency":"USD","issuer":"rMwjYedjc7qqtKYVLiAccJSmCwih4LnE2q","value":"0.0001001"},"Sequence":49,"SigningPubKey":"02760BE55D1C6861870F26E2413EE408FA2253F6D90BE648EAA6C100831579FCA8","TransactionType":"Payment","TxnSignature":"3045022100B90AF95EA0E6C399295C08ED31EEE73C92AC530EF5D8944EB7F52CD1AAC5881E02201781CBAB4521F411AB317BE2FE4BC809FA9098FA710A7CFEE559F5CE724703E5","date":477614130,"hash":"8C91E73E4AF0458B7CFDF4E932FDF9C6F263E56E8B56C413AAF3C92B1E06C6CB"},"type":"transaction","validated":true}'
-- https://id.ripple.com/v1/authinfo?username=rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR
local nameTest = '{"version":3,"blobvault":"https://id.ripple.com","pakdf":{"exponent":"010001","modulus":"c7f1bc1dfb1be82d244aef01228c1409c198894eca9e21430f1669b4aa3864c9f37f3d51b2b4ba1ab9e80f59d267fda1521e88b05117993175e004543c6e3611242f24432ce8efa3b81f0ff660b4f91c5d52f2511a6f38181a7bf9abeef72db056508bbb4eeb5f65f161dd2d5b439655d2ae7081fcc62fdcb281520911d96700c85cdaf12e7d1f15b55ade867240722425198d4ce39019550c4c8a921fc231d3e94297688c2d77cd68ee8fdeda38b7f9a274701fef23b4eaa6c1a9c15b2d77f37634930386fc20ec291be95aed9956801e1c76601b09c413ad915ff03bfdc0b6b233686ae59e8caf11750b509ab4e57ee09202239baee3d6e392d1640185e1cd","alpha":"7283d19e784f48a96062271a4fa6e2c3addf14e6edf78a4bb61364856d580f13552008d7b9e3b60ebd9555e9f6c7778ec69f976757d206134e54d61ba9d588a7e37a77cf48060522478352d76db000366ef669a1b1ca93c5e3e05bc344afa1e8ccb15d3343da94180dccf590c2c32408c3f3f176c8885e95d988f1565ee9b80c12f72503ab49917792f907bbb9037487b0afed967fefc9ab090164597fcd391c43fab33029b38e66ff4af96cbf6d90a01b891f856ddd3d94e9c9b307fe01e1353a8c30edd5a94a0ebba5fe7161569000ad3b0d3568872d52b6fbdfce987a687e4b346ea702e8986b03b6b1b85536c813e46052a31ed64ec490d3ba38029544aa","url":"https://auth1.ripple.com/api/sign","host":"auth1.ripple.com"},"exists":true,"username":"vakula","address":"rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR","emailVerified":true,"recoverable":true,"profile_verified":false,"identity_verified":false}'

function test1()
  -- body
  -- local sm = serverMessage:new(transStrTest1)
  local sm = serverMessage:new(transStrTest1)
  -- local sm = serverMessage.create(transStrTest)
  -- print ('type:', sm.type)
  -- print ('isTransaction:', sm:isTransaction())
  -- print ('isPayment:', sm:isPayment())
  -- print ('payment:', inspect(sm.payment))
  assert(sm.valid)
  assert(sm:isTransaction())
  assert(sm:isPayment())
  assert(sm.payment.amount == '100')
  assert(sm.payment.amountHuman == '0.0001 XRP')
  assert(sm.payment.destination == 'rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR')
  assert(sm.payment.account == 'rp8rJYTpodf8qbSCHVTNacf8nSW8mRakFw')
end

function test2()
  local sm = serverMessage:new(transStrTest2)
  -- print ('payment:', inspect(sm.payment))
  assert(sm.valid)
  assert(sm:isTransaction())
  assert(sm:isPayment())
  assert(type(sm.payment.amount) == 'table', 'Bad amount type')
  assert(sm.payment.amount.value == '0.0001', 'Bad amount')
  assert(sm.payment.amount.currency == 'USD', 'Bad amount currency')
  assert(sm.payment.amountHuman == '0.0001 USD', 'Bad human amount')
  assert(sm.payment.destination == 'rfXK4fN2AAqH7H5Uo94JQwT88qQkv69pqR')
  assert(sm.payment.account == 'rfXnhhuqPEAn5dqqTqgBKyCqivykxkdtm5')
end

function testName1()
  local n1 = JSON:decode(nameTest)
  -- print(inspect(n1))
  -- print(n1.username)
  assert(n1.username == 'vakula')
end


function run()
  test1()
  test2()
  testName1()
  print 'OK'
end

run()
