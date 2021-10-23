local config = require('session_manager.config')
local utils = require('session_manager.utils')
local Path = require('plenary.path')
local session_manager = {}

function session_manager.setup(values)
  setmetatable(config, { __index = vim.tbl_extend('force', config.defaults, values) })
end

function session_manager.load_last_session(bang)
  local last_session = utils.get_last_session_filename()
  if last_session then
    utils.load_session(last_session, bang and #bang ~= 0)
  end
end

function session_manager.save_current_session()
  utils.save_session(utils.dir_to_session_filename())
end

function session_manager.autoload_session()
  if config.autoload_last_session and vim.fn.argc() == 0 then
    session_manager.load_last_session()
  end
end

function session_manager.autosave_session()
  if not config.autosave_last_session then
    return
  end

  for _, path in ipairs(config.autosave_ignore_paths) do
    if Path:new(path):expand() == vim.fn.getcwd() then
      return
    end
  end

  if config.autoload_ignore_non_normal then
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if utils.what_buffer(buffer) == 0 then
          return
      end
    end
  end

  session_manager.save_current_session()
end

return session_manager
