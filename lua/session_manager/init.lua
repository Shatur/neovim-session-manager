local utils = require('session_manager.utils')
local session_manager = {}

function session_manager.load_session(session_filename, save_current)
  -- Load last session
  if not session_filename or #session_filename == 0 then
    local last_session = utils.get_last_session()
    if not last_session.filename then
      print('Sessions list is empty')
      return
    end
    session_filename = last_session.filename
  end

  if save_current then
    session_manager.save_session()
  end

  -- Ask to save files in current session before closing them
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buffer, 'modified') then
      local choice = vim.fn.confirm('The files in the current session have changed. Save changes?', '&Yes\n&No\n&Cancel')
      if choice == 3 then
        return -- Cancel
      elseif choice == 1 then
        vim.cmd('silent wall')
      end
      break
    end
  end

  -- Stop all LSP clients first
  vim.lsp.stop_client(vim.lsp.get_active_clients())

  -- Scedule buffers cleanup to avoid callback issues and source the session
  vim.schedule(function()
    -- Delete all buffers first except the current one to avoid entering buffers scheduled for deletion
    local current_buffer = vim.api.nvim_get_current_buf()
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buffer) and buffer ~= current_buffer then
        vim.api.nvim_buf_delete(buffer, { force = true })
      end
    end
    vim.api.nvim_buf_delete(current_buffer, { force = true })

    vim.cmd('silent source ' .. vim.g.sessions_dir .. session_filename)
  end)
end

function session_manager.save_session(filename)
  if vim.fn.isdirectory(vim.g.sessions_dir) ~= 1 then
    vim.fn.mkdir(vim.g.sessions_dir)
  end

  -- Remove all non-file and utility buffers because they cannot be saved
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buffer) then
      if #vim.api.nvim_buf_get_option(buffer, 'buftype') ~= 0 or not vim.api.nvim_buf_get_option(buffer, 'buflisted') then
        vim.api.nvim_buf_delete(buffer, { force = true })
      end
    end
  end

  -- Clear all passed arguments to avoid re-executing them
  if vim.fn.argc() > 0 then
    vim.cmd('%argdel')
  end

  if not filename or #filename == 0 then
    filename = vim.fn.getcwd()
  end

  vim.cmd('mksession! ' .. vim.g.sessions_dir .. utils.path_to_session_name(filename))
end

return session_manager
