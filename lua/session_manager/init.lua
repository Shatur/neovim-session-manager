local config = require('session_manager.config')
local AutoloadMode = require('session_manager.config').AutoloadMode
local utils = require('session_manager.utils')
local Path = require('plenary.path')
local session_manager = {}

function session_manager.setup(values) setmetatable(config, { __index = vim.tbl_extend('force', config.defaults, values) }) end

local function shorten_path(filename)
  -- Shorten path if length exceeds defined max_path_length
  if config.max_path_length > 0 and #filename > config.max_path_length then
    return Path:new(filename):shorten()
  end

  -- Otherwise, use original path
  return filename
end

function session_manager.load_session(discard_current)
  local sessions = utils.get_sessions()

  local display_names = {}
  for _, session in ipairs(sessions) do
    table.insert(display_names, shorten_path(session.dir.filename))
  end

  vim.ui.select(display_names, { prompt = 'Load Session' }, function(_, idx)
    if idx then
      session_manager.autosave_session()
      utils.load_session(sessions[idx].filename, discard_current)
    end
  end)
end

function session_manager.load_last_session(discard_current)
  local last_session = utils.get_last_session_filename()
  if last_session then
    utils.load_session(last_session, discard_current)
  end
end

function session_manager.load_current_dir_session(discard_current)
  local session_name = utils.dir_to_session_filename(vim.loop.cwd())
  if session_name:exists() then
    utils.load_session(session_name.filename, discard_current)
  end
end

function session_manager.save_current_session() utils.save_session(utils.dir_to_session_filename().filename) end

function session_manager.autoload_session()
  if config.autoload_mode ~= AutoloadMode.Disabled and vim.fn.argc() == 0 and not vim.g.started_with_stdin then
    if config.autoload_mode == AutoloadMode.CurrentDir then
      session_manager.load_current_dir_session()
    elseif config.autoload_mode == AutoloadMode.LastSession then
      session_manager.load_last_session()
    end
  end
end

function session_manager.delete_session()
  local sessions = utils.get_sessions()

  local display_names = {}
  for _, session in ipairs(sessions) do
    table.insert(display_names, shorten_path(session.dir.filename))
  end

  vim.ui.select(display_names, { prompt = 'Delete Session' }, function(_, idx)
    if idx then
      Path:new(sessions[idx].filename):rm()
      session_manager.delete_session()
    end
  end)
end

function session_manager.autosave_session()
  if not config.autosave_last_session then
    return
  end

  if config.autosave_only_in_session and not utils.is_session then
    return
  end

  if not config.autosave_ignore_not_normal or utils.is_restorable_buffer_present() then
    session_manager.save_current_session()
  end
end

return session_manager
