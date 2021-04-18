local utils = {}

function utils.get_sessions()
  local sessions = {}
  for _, session_filename in ipairs(vim.fn.readdir(vim.g.sessions_dir)) do
    table.insert(sessions, {timestamp = vim.fn.getftime(vim.g.sessions_dir .. session_filename), filename = session_filename})
  end
  table.sort(sessions, function(a, b) return a.timestamp > b.timestamp end)

  -- If the last session is the current one, then preselect the previous one
  if sessions[1].filename == vim.fn.getcwd():gsub('/', vim.g.sessions_path_replacer) then
    sessions[1], sessions[2] = sessions[2], sessions[1]
  end

  return sessions
end

function utils.get_last_session()
  local most_recent_session = {timestamp = 0, filename = nil}
  for _, session_filename in ipairs(vim.fn.readdir(vim.g.sessions_dir)) do
    local timestamp = vim.fn.getftime(vim.g.sessions_dir .. session_filename)
    if most_recent_session.timestamp < timestamp then
      most_recent_session.timestamp = timestamp
      most_recent_session.filename = session_filename
    end
  end
  return most_recent_session
end

return utils
