local utils = {}

function utils.path_to_session_name(path)
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

function utils.session_name_to_path(session_name)
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

function utils.get_sessions()
  local sessions = {}
  for _, session_filename in ipairs(vim.fn.readdir(vim.g.sessions_dir)) do
    if vim.fn.isdirectory(utils.session_name_to_path(session_filename)) == 1 then
      table.insert(sessions, {timestamp = vim.fn.getftime(vim.g.sessions_dir .. session_filename), filename = session_filename})
    else
      vim.fn.delete(session_filename)
    end
  end
  table.sort(sessions, function(a, b) return a.timestamp > b.timestamp end)

  -- If the last session is the current one, then preselect the previous one
  if #sessions >= 2 and sessions[1].filename == utils.path_to_session_name(vim.fn.getcwd()) then
    sessions[1], sessions[2] = sessions[2], sessions[1]
  end

  return sessions
end

function utils.get_last_session()
  local most_recent_session = {timestamp = 0, filename = nil}

  if vim.fn.isdirectory(vim.g.sessions_dir) ~= 1 then
    return most_recent_session
  end

  for _, session_filename in ipairs(vim.fn.readdir(vim.g.sessions_dir)) do
    if vim.fn.isdirectory(utils.session_name_to_path(session_filename)) == 1 then
      local timestamp = vim.fn.getftime(vim.g.sessions_dir .. session_filename)
      if most_recent_session.timestamp < timestamp then
        most_recent_session.timestamp = timestamp
        most_recent_session.filename = session_filename
      end
    end
  end
  return most_recent_session
end

function utils.autoload_session()
  if vim.g.autoload_last_session and vim.fn.argc() == 0 then
    require('session_manager').load_session()
  end
end

function utils.autosave_session()
  if not vim.g.autosave_last_session then
    return
  end

  for _, path in ipairs(vim.g.autosave_ignore_paths) do
    if vim.fn.expand(path) == vim.fn.getcwd() then
      return
    end
  end

  require('session_manager').save_session()
end

return utils
