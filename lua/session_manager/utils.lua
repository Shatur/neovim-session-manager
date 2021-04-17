local utils = {}

function utils.get_sessions()
  local sessions = {}
  for _, session_filename in ipairs(vim.fn.readdir(vim.g.sessions_dir)) do
    table.insert(sessions, {timestamp = vim.fn.getftime(vim.g.sessions_dir .. session_filename), filename = session_filename})
  end
  return sessions
end

function utils.get_last_session()
  local most_recent_session = {timestamp = 0, filename = ''}
  for _, session in ipairs(utils.get_sessions()) do
    if session.timestamp > most_recent_session.timestamp then
      most_recent_session = session
    end
  end
  return most_recent_session
end

return utils
