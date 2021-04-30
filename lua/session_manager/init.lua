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

  -- Stop all LSP clients first
  vim.lsp.stop_client(vim.lsp.get_active_clients())

  -- Scedule buffers cleanup to avoid callback issues and source the session
  vim.schedule(vim.schedule_wrap(function()
    -- Delete all buffers first except the current one to avoid entering buffers scheduled for deletion
    local current_buffer = vim.api.nvim_get_current_buf()
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buffer) and buffer ~= current_buffer then
          vim.api.nvim_buf_delete(buffer, {})
      end
    end
    vim.api.nvim_buf_delete(current_buffer, {})

    vim.cmd('silent source ' .. session_filename)
  end))
end

function session_manager.save_session()
  if vim.fn.isdirectory(vim.g.sessions_dir) ~= 1 then
    vim.fn.mkdir(vim.g.sessions_dir)
  end

  -- Remove all non-file and utility buffers because they cannot be saved
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buffer) then
      if #vim.api.nvim_buf_get_option(buffer, 'buftype') ~= 0 or vim.api.nvim_buf_get_option(buffer, 'buflisted') == 0 then
        vim.api.nvim_buf_delete(buffer, {force = true})
      end
    end
  end

  -- Clear all passed arguments to avoid re-executing them
  if vim.fn.argc() > 0 then
    vim.cmd('%argdel')
  end

  vim.cmd('mksession! ' .. vim.g.sessions_dir .. utils.path_to_session_name(vim.fn.getcwd()))
end

return session_manager
