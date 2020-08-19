--[[
  Load test call.
]]

require('support_functions')

dummy_caller_id = "4125551212"

api = freeswitch.API();

-- debug_print("LUA VERSION: " .. _VERSION)

function usage()
  debug_print(string.format("Usage: %s <server> <extension> <user_id> <mock_state_variable_name> <mock_play_phrase>", argv[0]))
end

function main()

  local server = argv[1]
  local extension = argv[2]
  local user_id = tonumber(argv[3])
  local mock_state_variable_name = argv[4] or "hangup_mock_call"
  local mock_play_phrase = argv[5]

  local hangup_user_var = string.format("%s_%s", mock_state_variable_name, user_id)
  local hangup_all_var = string.format("%s_all", mock_state_variable_name)

  debug_print(string.format("Mocking user ID %d to extension %s at %s@%s", user_id, extension, extension, server))
  debug_print(string.format("Use 'global_setvar %s=true' to hang up this call, or 'global_setvar %s=true' to hang up all calls", hangup_user_var, hangup_all_var))

  function mock_call(user_id)
    local dialstring = string.format("{origination_caller_id_name='Test user #%02d',origination_caller_id_number=%s,sip_h_X-apartmentlines_skip_voicemail_to_email=1}sofia/external/%s@%s", user_id, dummy_caller_id, extension, server)
    debug_print(string.format("Initializing mock call with dialstring: %s", dialstring))
    local session = freeswitch.Session(dialstring)
    uuid = session:get_uuid()
    send_dtmf_command = string.format([[uuid_send_dtmf %s W1]], uuid)
    debug_print(string.format("Accessing voicemail by key press 1 from mock caller: %d", user_id))
    api:executeString(send_dtmf_command)
    local play_loop
    play_loop = function()
      if session:ready() == true and freeswitch.getGlobalVariable(hangup_user_var) ~= "true" and freeswitch.getGlobalVariable(hangup_all_var) ~= "true" then
        debug_print(string.format("Playing %s from mock caller: %d", mock_play_phrase, user_id))
        if mock_play_phrase then
          session:sayPhrase(mock_play_phrase)
        else
          session:execute("sleep", "2000")
        end
        return play_loop()
      else
        debug_print(string.format("Hangup caller #%d", user_id))
        return session:hangup()
      end
    end
    play_loop()
  end

  mock_call(user_id)
end

main()
