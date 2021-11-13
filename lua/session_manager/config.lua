local Path = require('plenary.path')
local autoloadModes = require('session_manager.autoloadModes')

local config = {
  defaults = {
    sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'),
    path_replacer = '__',
    colon_replacer = '++',
    autoload_mode = autoloadModes.CurrentDir,
    autosave_last_session = true,
    autosave_ignore_not_normal = true,
  },
}

setmetatable(config, { __index = config.defaults })

return config
