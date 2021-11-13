local telescope = require('telescope')
local actions = require('telescope.actions')
local state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local themes = require('telescope.themes')
local utils = require('session_manager.utils')
local config = require('session_manager.config')
local Path = require('plenary.path')

local function select_session(opts)
  -- Use dropdown theme by default
  opts = themes.get_dropdown(opts)

  pickers.new(opts, {
    prompt_title = 'Select a session',
    finder = finders.new_table({
      results = utils.get_sessions(),
      entry_maker = function(entry)
        return {
          value = entry.filename,
          display = entry.dir.filename,
          ordinal = entry.dir.filename,
        }
      end,
    }),
    sorter = sorters.get_fzy_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      local source_session = function()
        actions.close(prompt_bufnr)
        local entry = state.get_selected_entry()
        if entry then
          if opts['save_current'] and (not config.autosave_ignore_not_normal or utils.is_normal_buffer_present()) then
            utils.save_session(utils.dir_to_session_filename().filename)
          end
          utils.load_session(entry.value)
        end
      end

      actions.select_default:replace(source_session)

      local delete_session = function()
        local entry = state.get_selected_entry()
        if entry then
          Path:new(entry.value):rm()
          select_session(opts)
        end
      end

      map('n', 'd', delete_session, { nowait = true })
      return true
    end,
  }):find()
end

return telescope.register_extension({
  exports = {
    sessions = select_session,
  },
})
