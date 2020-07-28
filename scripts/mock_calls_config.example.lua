--[[
  Configuration for mocking calls.
]]

_M = {
  -- Name of the gateway to use for outbound calls.
  gateway = "flowroute",
  -- Server domain of the server to be tested.
  server = "[freeswitch_server_ip]",
  -- Full path to the audio file to play for the tests, including format.
  mock_play_phrase = "screaming_monkeys",
}

return _M
