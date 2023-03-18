local config = require('session_manager.config')
local AutoloadMode = require('session_manager.config').AutoloadMode
local utils = require('session_manager.utils')
local Path = require('plenary.path')
local session_manager = {}

--- Apply user settings.
---@param values table
function session_manager.setup(values) setmetatable(config, { __index = vim.tbl_extend('force', config.defaults, values) }) end

--- Selects a session a loads it.
---@param discard_current boolean: If `true`, do not check for unsaved buffers.
function session_manager.load_session(discard_current)
  local sessions = utils.get_sessions()

  local display_names = {}
  for _, session in ipairs(sessions) do
    table.insert(display_names, utils.shorten_path(session.dir))
  end

  vim.ui.select(display_names, { prompt = 'Load Session' }, function(_, idx)
    if idx then
      session_manager.autosave_session()
      utils.load_session(sessions[idx].filename, discard_current)
    end
  end)
end

--- Loads saved used session.
---@param discard_current boolean?: If `true`, do not check for unsaved buffers.
function session_manager.load_last_session(discard_current)
  local last_session = utils.get_last_session_filename()
  if last_session then
    utils.load_session(last_session, discard_current)
  end
end

--- Loads a session for the current working directory.
function session_manager.load_current_dir_session(discard_current)
  local session_name = utils.dir_to_session_filename(vim.loop.cwd())
  if session_name:exists() then
    utils.load_session(session_name.filename, discard_current)
  end
end

--- Saves a session for the current working directory.
function session_manager.save_current_session() utils.save_session(utils.dir_to_session_filename().filename) end

--- Loads a session based on settings. Executed after starting the editor.
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
    table.insert(display_names, utils.shorten_path(session.dir))
  end

  vim.ui.select(display_names, { prompt = 'Delete Session' }, function(_, idx)
    if idx then
      Path:new(sessions[idx].filename):rm()
      session_manager.delete_session()
    end
  end)
end

--- Delete a session by its directory. Used by third-party plugins
function session_manager.delete_session_by_dir(path)
  local sessions = utils.get_sessions()

  for idx, session in ipairs(sessions) do
    if session.dir.filename == path then
      return Path:new(sessions[idx].filename):rm()
    end
  end
end

--- Saves a session based on settings. Executed before exiting the editor.
function session_manager.autosave_session()
  if not config.autosave_last_session then
    return
  end

  if config.autosave_only_in_session and not utils.is_session then
    return
  end

  if config.autosave_ignore_dirs and utils.is_dir_in_ignore_list() then
    return
  end

  if not config.autosave_ignore_not_normal or utils.is_restorable_buffer_present() then
    session_manager.save_current_session()
  end
end

return session_manager
