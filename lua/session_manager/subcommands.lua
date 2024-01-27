local session_manager = require('session_manager')
local utils = require('session_manager.utils')
local subcommands = {}

--- Completes `:SessionManager` command.
---@param arg string: Current argument under cursor.
---@param cmd_line string: All arguments.
---@return table: List of all commands matched with `arg`.
function subcommands.complete(arg, cmd_line)
  local matches = {}

  local words = vim.split(cmd_line, ' ', { trimempty = true })
  if not vim.endswith(cmd_line, ' ') then
    -- Last word is not fully typed, don't count it.
    table.remove(words, #words)
  end

  if #words == 1 then
    for subcommand in pairs(session_manager) do
      if vim.startswith(subcommand, arg) and not vim.startswith(subcommand, 'auto') and subcommand ~= 'setup' then
        table.insert(matches, subcommand)
      end
    end
  end

  return matches
end

--- Run specified subcommand received from completion.
---@param subcommand table
function subcommands.run(subcommand)
  if subcommand.args == '' then
    session_manager.available_commands()
    return
  end
  local subcommand_func = session_manager[subcommand.fargs[1]]
  if not subcommand_func then
    utils.notify('No such subcommand: ' .. subcommand.fargs[1], vim.log.levels.ERROR)
    return
  end
  subcommand_func(subcommand.bang)
end

return subcommands
