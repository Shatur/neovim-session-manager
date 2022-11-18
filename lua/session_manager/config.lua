local Path = require('plenary.path')
local Enum = require('plenary.enum')

local config = {
  AutoloadMode = Enum({
    'Disabled',
    'CurrentDir',
    'LastSession',
  }),
}

--- Replaces symbols into separators and colons to transform filename into a session directory.
---@param filename string: Filename with expressions to replace.
---@return string: Session directory
function config.delimited_session_filename_to_dir(filename)
  local dir = filename
  dir = dir:gsub(config.colon_replacer, ':')
  dir = dir:gsub(config.path_replacer, Path.path.sep)
  return dir
end

--- Replaces separators and colons into special symbols to transform session directory into a filename.
---@param dir string: Path to session directory.
---@return string: Session filename.
function config.dir_to_delimited_session_filename(dir)
  local filename = dir
  filename = filename:gsub(':', config.colon_replacer)
  filename = filename:gsub(Path.path.sep, config.path_replacer)
  return filename
end

config.defaults = {
  sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),
  path_replacer = '__',
  colon_replacer = '++',
  dir_to_session_filename = config.dir_to_delimited_session_filename,
  session_filename_to_dir = config.delimited_session_filename_to_dir,
  autoload_mode = config.AutoloadMode.LastSession,
  autosave_last_session = true,
  autosave_ignore_not_normal = true,
  autosave_ignore_filetypes = {
    'gitcommit',
  },
  autosave_only_in_session = false,
  max_path_length = 80,
}

setmetatable(config, { __index = config.defaults })

return config
