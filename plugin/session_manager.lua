if not vim.fn.has('nvim-0.7.0') then
  require('session_manager.utils').notify('Neovim 0.7+ is required for session manager plugin', vim.log.levels.ERROR)
  return
end

local subcommands = require('session_manager.subcommands')
local session_manager = require('session_manager')

vim.api.nvim_create_user_command('SessionManager', subcommands.run, { nargs = 1, bang = true, complete = subcommands.complete, desc = 'Run session manager command' })

local session_manager_group = vim.api.nvim_create_augroup('SessionManager', {})
vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  group = session_manager_group,
  nested = true,
  callback = session_manager.autoload_session,
})
vim.api.nvim_create_autocmd({ 'VimLeavePre' }, {
  group = session_manager_group,
  callback = session_manager.autosave_session,
})
vim.api.nvim_create_autocmd({ 'StdinReadPre' }, {
  group = session_manager_group,
  callback = function() vim.g.started_with_stdin = true end,
})
