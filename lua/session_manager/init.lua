local session_manager = {}

local function get_last_session()
  local most_recent_session = { timestamp = 0, filename = nil }

  if vim.fn.isdirectory(vim.g.sessions_dir) ~= 1 then
    return most_recent_session
  end

  for _, session_filename in ipairs(vim.fn.readdir(vim.g.sessions_dir)) do
    if vim.fn.isdirectory(session_manager.session_name_to_path(session_filename)) == 1 then
      local timestamp = vim.fn.getftime(vim.g.sessions_dir .. session_filename)
      if most_recent_session.timestamp < timestamp then
        most_recent_session.timestamp = timestamp
        most_recent_session.filename = session_filename
      end
    end
  end
  return most_recent_session
end

function session_manager.load_session(session_filename, save_current)
  -- Load last session
  if not session_filename or #session_filename == 0 then
    local last_session = get_last_session()
    if not last_session.filename then
      vim.notify('Sessions list is empty', vim.log.levels.INFO, { title = 'Session manager' })
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

  vim.cmd('mksession! ' .. vim.g.sessions_dir .. session_manager.path_to_session_name(filename))
end

function session_manager.get_sessions()
  local sessions = {}
  for _, session_filename in ipairs(vim.fn.readdir(vim.g.sessions_dir)) do
    if vim.fn.isdirectory(session_manager.session_name_to_path(session_filename)) == 1 then
      table.insert(sessions, { timestamp = vim.fn.getftime(vim.g.sessions_dir .. session_filename), filename = session_filename })
    else
      vim.fn.delete(session_filename)
    end
  end
  table.sort(sessions, function(a, b)
    return a.timestamp > b.timestamp
  end)

  -- If the last session is the current one, then preselect the previous one
  if #sessions >= 2 and sessions[1].filename == session_manager.path_to_session_name(vim.fn.getcwd()) then
    sessions[1], sessions[2] = sessions[2], sessions[1]
  end

  return sessions
end

function session_manager.path_to_session_name(path)
  if vim.fn.has('win32') == 1 then
    path = path:gsub(':', vim.g.sessions_colon_replacer)
    if not vim.o.shellslash then
      path = path:gsub('\\', vim.g.sessions_path_replacer)
    end
  else
    path = path:gsub('/', vim.g.sessions_path_replacer)
  end

  return path
end

function session_manager.session_name_to_path(session_name)
  if vim.fn.has('win32') == 1 then
    session_name = session_name:gsub(vim.g.sessions_colon_replacer, ':')
    if not vim.o.shellslash then
      session_name = session_name:gsub(vim.g.sessions_path_replacer, '\\')
    end
  else
    session_name = session_name:gsub(vim.g.sessions_path_replacer, '/')
  end

  return session_name
end

function session_manager.autoload_session()
  if vim.g.autoload_last_session and vim.fn.argc() == 0 then
    session_manager.load_session()
  end
end

function session_manager.autosave_session()
  if not vim.g.autosave_last_session then
    return
  end

  for _, path in ipairs(vim.g.autosave_ignore_paths) do
    if vim.fn.expand(path) == vim.fn.getcwd() then
      return
    end
  end

  session_manager.save_session()
end

return session_manager
