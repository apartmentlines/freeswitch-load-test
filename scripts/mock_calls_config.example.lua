--[[
  Configuration for mocking calls.
]]

_M = {
  -- Name of the gateway to use for outbound calls.
  gateway = "flowroute",
  -- Server domain of the server to be tested.
  server = "[freeswitch_server_ip]",
  -- Name of phrase macro to play into the call, set to nil to skip.
  mock_play_phrase = "screaming_monkeys",
}

return _M
