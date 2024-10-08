local config = require('session_manager.config')
local AutoloadMode = require('session_manager.config').AutoloadMode
local utils = require('session_manager.utils')
local Job = require('plenary.job')
local session_manager = {}

--- Apply user settings.
---@param values table
function session_manager.setup(values) setmetatable(config, { __index = vim.tbl_extend('force', config.defaults, values) }) end

-- Displays action selection menu for :SessionManager
function session_manager.available_commands()
  local commands = {}
  for cmd, _ in pairs(session_manager) do
    if cmd ~= 'setup' and cmd ~= 'available_commands' and cmd ~= 'autosave_session' then
      table.insert(commands, cmd)
    end
  end
  vim.ui.select(commands, {
    prompt = 'Session Manager',
    format_item = function(item) return item:sub(1, 1):upper() .. item:sub(2):gsub('_', ' ') end,
  }, function(item)
    if item then
      session_manager[item]()
    end
  end)
end

--- Selects a session a loads it.
---@param discard_current boolean: If `true`, do not check for unsaved buffers.
function session_manager.load_session(discard_current)
  local sessions = utils.get_sessions()
  vim.ui.select(sessions, {
    prompt = 'Load Session',
    format_item = function(item) return utils.shorten_path(item.dir) end,
  }, function(item)
    if item then
      session_manager.autosave_session()
      utils.load_session(item.filename, discard_current)
    end
  end)
end

--- Tries to load the last saved session.
---@param discard_current boolean?: If `true`, do not check for unsaved buffers.
---@return boolean: `true` if session was loaded, `false` otherwise.
function session_manager.load_last_session(discard_current)
  local last_session = utils.get_last_session_filename()
  if last_session then
    utils.load_session(last_session, discard_current)
    return true
  end
  return false
end

--- Tries to load a session for the current working directory.
---@return boolean: `true` if session was loaded, `false` otherwise.
function session_manager.load_current_dir_session(discard_current)
  local cwd = vim.uv.cwd()
  if cwd then
    local session = config.dir_to_session_filename(cwd)
    if session:exists() then
      utils.load_session(session.filename, discard_current)
      return true
    end
  end
  return false
end

--- Checks if a session for the current working directory exists.
---@return boolean: `true` if session was found, `false` otherwise.
function session_manager.current_dir_session_exists()
  local cwd = vim.uv.cwd()
  if cwd then
    local session = config.dir_to_session_filename(cwd)
    return session:exists()
  end
  return false
end

--- If in a git repo, tries to load a session for the repo's root directory
---@return boolean: `true` if session was loaded, `false` otherwise.
function session_manager.load_git_session(discard_current)
  local job = Job:new({
    command = 'git',
    args = { 'rev-parse', '--show-toplevel' },
  })
  job:sync()
  local git_dir = job:result()[1]
  if git_dir then
    local session = config.dir_to_session_filename(git_dir)
    if session:exists() then
      utils.load_session(session.filename, discard_current)
      return true
    end
  end
  return false
end

--- Saves a session for the current working directory.
function session_manager.save_current_session()
  local cwd = vim.uv.cwd()
  if cwd then
    utils.save_session(config.dir_to_session_filename(cwd).filename)
  end
end

local autoloaders = {
  [AutoloadMode.Disabled] = function() return true end,
  [AutoloadMode.CurrentDir] = session_manager.load_current_dir_session,
  [AutoloadMode.LastSession] = session_manager.load_last_session,
  [AutoloadMode.GitSession] = session_manager.load_git_session,
}

--- Loads a session based on settings. Executed after starting the editor.
function session_manager.autoload_session()
  if vim.fn.argc() > 0 or vim.g.started_with_stdin then
    return
  end

  local modes = config.autoload_mode
  if not vim.isarray(config.autoload_mode) then
    modes = { config.autoload_mode }
  end

  for _, mode in ipairs(modes) do
    if autoloaders[mode]() then
      return
    end
  end
end

function session_manager.delete_session()
  local sessions = utils.get_sessions()
  vim.ui.select(sessions, {
    prompt = 'Delete Session',
    format_item = function(item) return utils.shorten_path(item.dir) end,
  }, function(item)
    if item then
      utils.delete_session(item.filename)
      session_manager.delete_session()
    end
  end)
end

--- Deletes the session for the current working directory.
function session_manager.delete_current_dir_session()
  local cwd = vim.uv.cwd()
  if cwd then
    local session = config.dir_to_session_filename(cwd)
    if session:exists() then
      utils.delete_session(session.filename)
    end
  end
end

--- Saves a session based on settings. Executed before exiting the editor.
function session_manager.autosave_session()
  if not config.autosave_last_session then
    return
  end

  if config.autosave_only_in_session and not utils.exists_in_session() then
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
