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
Usage: %s <action> < extension | extension_file_list > [mock_user_list]

  action: One of:
    add: Adds users in list by dialing in to the provided extension
    add_from_list: Adds users in list by dialing in to a matching extension
                   in extension_file_list.
    remove: Removes users in list by hanging up call
    stop: Removes all users being mocked. extension | extension_file_list
          not required in this case.

  extension: FreeSWITCH extension being called
  extension_file_list: File containing FreeSWITCH extensions to be called
                       one extension per line.

  mock_user_list: Numeric range of IDs for the mock users to add/remove
    Can be a single number, or a range of numbers separated by a dash, eg.
    5-10. When using add_from_list, the extension is pulled from
    extension_file_list based on the user number, so make sure there are
    enough extensions in there.
]]
  debug_print(string.format(usage, argv[0]))
end

function main()
  local first
  local last

  local action = argv[1]
  local extension = argv[2]
  local mock_user_list = argv[3] or "1"
  local extension_file_list = {}

  first, last = string.match(mock_user_list, "^(%d+)-(%d+)$")
  if first == nil then
    first = string.match(mock_user_list, "^(%d+)$")
  end

  if action ~= "add" and action ~= "add_from_list" and action ~= "remove" and action ~= "stop" then
    debug_print("ERROR: invalid action")
    return usage()
  end

  if extension == nil and action ~= "stop" then
    debug_print("ERROR: extension or extension_file_list required")
    return usage()
  end

  if first == nil then
    debug_print("ERROR: invalid mock_user_list")
    return usage()
  end

  if last == nil then
    last = first
  end

  if action == "add_from_list" then
    local script_dir = api:executeString("global_getvar script_dir")
    local f = io.input(string.format([[%s/%s]], script_dir, extension))
    for line in f:lines () do
      table.insert(extension_file_list, line)
    end
    f:close ()
  end

  debug_print(string.format("Executing mock command with action %s, extension %s, first mock user %s, last mock user %s", action, extension, first, last))

  api:executeString(string.format("global_setvar %s_all=", mock_state_variable_name))

  for i = first, last, 1 do
    if action == "add" or action == "add_from_list" then
      local dial_extension
      if action == "add_from_list" then
        dial_extension = extension_file_list[i]
      else
        dial_extension = extension
      end
      debug_print(string.format("Adding mock user #%d", i))
      api:executeString(string.format("global_setvar %s_%s=", mock_state_variable_name, i))
      api:executeString(string.format("luarun  %s %s %s %d %s %s", config.mock_call_script, config.server, dial_extension, i, mock_state_variable_name, config.mock_play_phrase))
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
