local config = require('session_manager.config')
local scandir = require('plenary.scandir')
local Path = require('plenary.path')
local utils = { is_session = false }

function utils.get_last_session_filename()
  if not Path:new(config.sessions_dir):is_dir() then
    vim.notify('Sessions list is empty', vim.log.levels.INFO, { title = 'Session manager' })
    return nil
  end

  local most_recent_filename = nil
  local most_recent_timestamp = 0
  for _, session_filename in ipairs(scandir.scan_dir(tostring(config.sessions_dir))) do
    if utils.session_filename_to_dir(session_filename):is_dir() then
      local timestamp = vim.fn.getftime(session_filename)
      if most_recent_timestamp < timestamp then
        most_recent_timestamp = timestamp
        most_recent_filename = session_filename
      end
    end
  end
  return most_recent_filename
end

function utils.load_session(filename, discard_current)
  if not discard_current then
    -- Ask to save files in current session before closing them
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_option(buffer, 'modified') then
        local choice = vim.fn.confirm('The files in the current session have changed. Save changes?', '&Yes\n&No\n&Cancel')
        if choice == 3 or choice == 0 then
          return -- Cancel
        elseif choice == 1 then
          vim.api.nvim_command('silent wall')
        end
        break
      end
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

    utils.is_session = true
    vim.api.nvim_command('silent source ' .. filename)
  end)
end

function utils.save_session(filename)
  local sessions_dir = Path:new(tostring(config.sessions_dir))
  if not sessions_dir:is_dir() then
    sessions_dir:mkdir()
  end

  -- Remove all non-file and utility buffers because they cannot be saved
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buffer) then
      if not utils.is_normal_buffer(buffer) then
        vim.api.nvim_buf_delete(buffer, { force = true })
      end
    end
  end

  -- Clear all passed arguments to avoid re-executing them
  if vim.fn.argc() > 0 then
    vim.api.nvim_command('%argdel')
  end

  utils.is_session = true
  vim.api.nvim_command('mksession! ' .. filename)
end

function utils.get_sessions()
  local sessions = {}
  for _, session_filename in ipairs(scandir.scan_dir(tostring(config.sessions_dir))) do
    local dir = utils.session_filename_to_dir(session_filename)
    if dir:is_dir() then
      table.insert(sessions, { timestamp = vim.fn.getftime(session_filename), filename = session_filename, dir = dir })
    else
      Path:new(session_filename):rm()
    end
  end
  table.sort(sessions, function(a, b)
    return a.timestamp > b.timestamp
  end)

  -- If the last session is the current one, then preselect the previous one
  if #sessions >= 2 and sessions[1].filename == utils.dir_to_session_filename().filename then
    sessions[1], sessions[2] = sessions[2], sessions[1]
  end

  return sessions
end

function utils.session_filename_to_dir(filename)
  -- Get session filename
  local dir = filename:sub(#tostring(config.sessions_dir) + 2)

  dir = dir:gsub(config.colon_replacer, ':')
  dir = dir:gsub(config.path_replacer, Path.path.sep)
  return Path:new(dir)
end

function utils.dir_to_session_filename(dir)
  local filename = dir and dir.filename or vim.loop.cwd()
  filename = filename:gsub(':', config.colon_replacer)
  filename = filename:gsub(Path.path.sep, config.path_replacer)
  return Path:new(config.sessions_dir):joinpath(filename)
end

function utils.is_normal_buffer(buffer)
  return #vim.api.nvim_buf_get_option(buffer, 'buftype') == 0 and vim.api.nvim_buf_get_option(buffer, 'buflisted')
end

function utils.is_normal_buffer_present()
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buffer) and utils.is_normal_buffer(buffer) then
      return true
    end
  end
  return false
end

return utils
