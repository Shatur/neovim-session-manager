local Path = require('plenary.path')
local Enum = require('plenary.enum')

local path_replacer = '__'
local colon_replacer = '++'

local config = {
  AutoloadMode = Enum({
    'Disabled',
    'CurrentDir',
    'LastSession',
    'GitSession',
  }),
}

--- Replaces symbols into separators and colons to transform filename into a session directory.
---@param filename string: Filename with expressions to replace.
---@return table: Session directory
local function session_filename_to_dir(filename)
  -- Get session filename.
  local dir = filename:sub(#tostring(config.sessions_dir) + 2)

  dir = dir:gsub(colon_replacer, ':')
  dir = dir:gsub(path_replacer, Path.path.sep)
  return Path:new(dir)
end

--- Replaces separators and colons into special symbols to transform session directory into a filename.
---@param dir string: Path to session directory.
---@return table: Session filename.
local function dir_to_session_filename(dir)
  local filename = dir:gsub(':', colon_replacer)
  filename = filename:gsub(Path.path.sep, path_replacer)
  return Path:new(config.sessions_dir):joinpath(filename)
end

config.defaults = {
  sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),
  session_filename_to_dir = session_filename_to_dir,
  dir_to_session_filename = dir_to_session_filename,
  autoload_mode = config.AutoloadMode.LastSession,
  autosave_last_session = true,
  autosave_ignore_not_normal = true,
  autosave_ignore_dirs = {},
  autosave_ignore_filetypes = {
    'gitcommit',
    'gitrebase',
  },
  autosave_ignore_buftypes = {},
  autosave_only_in_session = false,
  max_path_length = 80,
}

setmetatable(config, { __index = config.defaults })

return config
