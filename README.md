# freeswitch-load-test

Set of Lua scripts to assist in mocking/load testing FreeSWITCH servers.

## Usage

 * Drop all .lua files in the ```scripts``` directory into the scripts directory of the testing installation.
 * Copy ```mock_calls_config.example.lua``` to ```mock_calls_config.lua```, and edit the variables to taste.
 * Set up proper gateways/extensions on the installation to be tested, and the mocking installation (see ```freeswitch-example-configs``` for examples).
 * From FreeSWITCH CLI on the testing installation run ```luarun mock_calls.lua``` for usage instructions.
