--[[
  Load test call.
]]

require('support_functions')

dummy_caller_id = "4125551212"

-- debug_print("LUA VERSION: " .. _VERSION);

function usage()
  debug_print(string.format("Usage: %s <gateway> <server> <extension> <user_id> <mock_state_variable_name> <mock_play_phrase>", argv[0]));
end

function main()

  local gateway = argv[1]
  local server = argv[2]
  local extension = argv[3]
  local user_id = tonumber(argv[4])
  local mock_state_variable_name = argv[5] or "hangup_mock_call"
  local mock_play_phrase = argv[6]

  local hangup_user_var = string.format("%s_%s", mock_state_variable_name, user_id)
  local hangup_all_var = string.format("%s_all", mock_state_variable_name)

  debug_print(string.format("Mocking user ID %d to extension %s at %s@%s", user_id, extension, extension, server));

  function mock_call(user_id)
    local dialstring = string.format("[origination_caller_id_name='Test user #%02d',origination_caller_id_number=%s]sofia/gateway/%s/%s@%s", user_id, dummy_caller_id, gateway, extension, server)
    debug_print(string.format("Initializing mock call with dialstring: %s", dialstring))
    local call_session = freeswitch.Session(dialstring);
    local play_loop
    play_loop = function()
      if call_session:ready() == true and freeswitch.getGlobalVariable(hangup_user_var) ~= "true" and freeswitch.getGlobalVariable(hangup_all_var) ~= "true" then
        debug_print(string.format("Playing %s from mock caller: %d", mock_play_phrase, user_id))
        if mock_play_phrase then
          session:sayPhrase(mock_play_phrase)
          session:execute("sleep", "500")
        else
          session:execute("sleep", "2000")
        end
        return play_loop()
      else
        debug_print(string.format("Hangup caller #%d", user_id))
        return call_session:hangup()
      end
    end
    play_loop()
  end

  mock_call(user_id)
end

main()
