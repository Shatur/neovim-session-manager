local Path = require('plenary.path')
local Enum = require('plenary.enum')

local config = {
  AutoloadMode = Enum({
    'Disabled',
    'CurrentDir',
    'LastSession',
  }),
}

config.defaults = {
  sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),
  path_replacer = '__',
  colon_replacer = '++',
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
