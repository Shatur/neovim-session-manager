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

function session_manager.load_current_session(bang)
  local session_name = utils.dir_to_session_filename(vim.loop.cwd())
  if Path:new(session_name):exists() then
    utils.load_session(session_name, bang and #bang ~= 0)
  end
end

function session_manager.save_current_session()
  utils.save_session(utils.dir_to_session_filename())
end

function session_manager.autoload_session()
  if config.autoload_last_session and vim.fn.argc() == 0 then
    if config.autoload_current_session then
      session_manager.load_current_session()
    else
      session_manager.load_last_session()
    end
  end
end

function session_manager.autosave_session()
  if not config.autosave_last_session then
    return
  end

  if not config.autosave_ignore_not_normal or utils.is_normal_buffer_present() then
    session_manager.save_current_session()
  end
end

return session_manager
