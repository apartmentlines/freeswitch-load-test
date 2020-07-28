--[[
  Load test calls.
]]

require('support_functions')
local config = require('mock_calls_config')

mock_state_variable_name = "hangup_mock_call"

api = freeswitch.API();

-- debug_print("LUA VERSION: " .. _VERSION)

function usage()
  local usage = [[
Usage: %s <action> <extension> [mock_user_list]

  action: One of:
    add: Adds users in list by dialing in
    remove: Removes users in list by hangup up call
    stop: Removes all users being mocked. extension not required in
          this case.

  extension: FreeSWITCH extension being called

  mock_user_list: Numeric range of IDs for the mock users to add/remove
    Can be a single number, or a range of numbers separated by a dash, eg.
    5-10.
]]
  debug_print(string.format(usage, argv[0]))
end

function main()
  local first
  local last

  local action = argv[1]
  local extension = argv[2]
  local mock_user_list = argv[3] or "1"

  first, last = string.match(mock_user_list, "^(%d+)-(%d+)$")
  if first == nil then
    first = string.match(mock_user_list, "^(%d+)$")
  end

  if action ~= "add" and action ~= "remove" and action ~= "stop" then
    debug_print("ERROR: invalid action")
    return usage()
  end

  if extension == nil and action ~= "stop" then
    debug_print("ERROR: extension required")
    return usage()
  end

  if first == nil then
    debug_print("ERROR: invalid mock_user_list")
    return usage()
  end

  if last == nil then
    last = first
  end

  debug_print(string.format("Executing mock command with action %s, extension %s, first mock user %s, last mock user %s", action, extension, first, last))

  api:executeString(string.format("global_setvar %s_all=", mock_state_variable_name))

  for i = first, last, 1 do
    if action == "add" then
      debug_print(string.format("Adding mock user #%d", i))
      api:executeString(string.format("global_setvar %s_%s=", mock_state_variable_name, i))
      api:executeString(string.format("luarun mock_call.lua %s %s %s %d %s %s", config.gateway, config.server, config.extension, i, mock_state_variable_name, config.mock_play_phrase))
    elseif action == "remove" then
      debug_print(string.format("Removing mock user #%d", i))
      api:executeString(string.format("global_setvar %s_%s=true", mock_state_variable_name, i))
    else
      debug_print("Removing all mock users")
      api:executeString(string.format("global_setvar %s_all=true", mock_state_variable_name))
    end
  end
end

main()
