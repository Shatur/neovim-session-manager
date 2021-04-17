local utils = require('session_manager.utils')
local session_manager = {}

function session_manager.load_session(session_filename, save_current)
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

  -- Remove all buffers
  for _, handle in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_delete(handle, {force = #vim.api.nvim_buf_get_option(handle, 'buftype') ~= 0})
  end

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
