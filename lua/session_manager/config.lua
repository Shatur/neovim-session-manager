local config = {
  defaults = {
    sessions_dir = vim.fn.stdpath('data') .. '/sessions',
    path_replacer = '__',
    colon_replacer = '++',
    autoload_last_session = true,
    autosave_last_session = true,
    autosave_ignore_paths = { '~' },
  },
}

setmetatable(config, { __index = config.defaults })

return config
