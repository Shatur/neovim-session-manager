local config = require('session_manager.config')
local AutoloadMode = require('session_manager.config').AutoloadMode
local utils = require('session_manager.utils')
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

function session_manager.load_current_dir_session(bang)
  local session_name = utils.dir_to_session_filename(vim.loop.cwd())
  if session_name:exists() then
    utils.load_session(session_name.filename, bang and #bang ~= 0)
  end
end

function session_manager.save_current_session()
  utils.save_session(utils.dir_to_session_filename().filename)
end

function session_manager.autoload_session()
  if config.autoload_mode ~= AutoloadMode.Disabled and vim.fn.argc() == 0 and not vim.g.started_with_stdin then
    if config.autoload_mode == AutoloadMode.CurrentDir then
      session_manager.load_current_dir_session()
    elseif config.autoload_mode == AutoloadMode.LastSession then
      session_manager.load_last_session()
    end
  end
end

function session_manager.autosave_session()
  if not config.autosave_last_session then
    return
  end

  if config.autosave_only_in_session and not utils.is_session then
    return
  end

  if not config.autosave_ignore_not_normal or utils.is_normal_buffer_present() then
    session_manager.save_current_session()
  end
end

return session_manager
