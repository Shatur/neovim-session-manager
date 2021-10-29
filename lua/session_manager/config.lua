local Path = require('plenary.path')

local config = {
  defaults = {
    sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),
    path_replacer = '__',
    colon_replacer = '++',
    autoload_last_session = true,
    autosave_last_session = true,
    autosave_ignore_not_normal = true,
    autosave_only_in_session = true
  },
}

setmetatable(config, { __index = config.defaults })

return config
