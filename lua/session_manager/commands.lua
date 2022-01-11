local session_manager = require('session_manager')
local utils = require('session_manager.utils')
local commands = {}

function commands.match_commands(arg)
  local matches = {}
  for command in pairs(session_manager) do
    if vim.startswith(command, arg) and not vim.startswith(command, 'auto') and command ~= 'setup' then
      table.insert(matches, command)
    end
  end
  return matches
end

function commands.run_command(command, bang)
  local command_func = session_manager[command]
  if not command_func then
    utils.notify('No such command: ' .. command, vim.log.levels.ERROR)
    return
  end
  command_func(bang)
end

return commands
