local utils = require('session_manager.utils')
local session_manager = {}

function session_manager.load_session(session_filename, save_current)
  -- Remove all non-file buffers first
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if #vim.api.nvim_buf_get_option(buffer, 'buftype') ~= 0 then
      -- Use vimscript API because vim.api.nvim_buf_delete causes issues with Lua callbacks
      vim.cmd('bdelete! ' .. tostring(buffer))
    end
  end

  -- Stop all LSP clients
  vim.lsp.stop_client(vim.lsp.get_active_clients())

  if save_current then
    session_manager.save_session()
  end

  -- Load last session
  if not session_filename then
    local last_session = utils.get_last_session()
    if not last_session.filename then
      return
    end
    session_filename = vim.g.sessions_dir .. last_session.filename
  end

  vim.cmd('bufdo bdelete') -- Remove all buffers

  vim.cmd('source ' .. session_filename)
end

function session_manager.save_session()
  local root = vim.fn.getcwd()
  if vim.fn.isdirectory(vim.g.sessions_dir) ~= 1 then
    vim.fn.mkdir(vim.g.sessions_dir)
  end
  root = root:gsub('/', vim.g.sessions_path_replacer)
  local session = vim.g.sessions_dir .. root
  vim.cmd('mksession! ' .. session)
end

return session_manager
