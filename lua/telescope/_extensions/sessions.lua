local telescope = require('telescope')
local actions = require('telescope.actions')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local session_manager = require('session_manager')

local function select_session(opts)
  pickers.new(opts, {
    prompt_title = 'Select a session',
    finder = finders.new_table({
      results = session_manager.get_sessions(),
      entry_maker = function(entry)
        return {
          value = entry.filename,
          display = session_manager.session_name_to_path(entry.filename),
          ordinal = entry.filename,
        }
      end,
    }),
    sorter = sorters.get_fzy_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      local source_session = function()
        actions.close(prompt_bufnr)
        local entry = actions.get_selected_entry(prompt_bufnr)
        if entry then
          if opts['save_current'] then
            session_manager.save_session()
          end
          session_manager.load_session(entry.value)
        end
      end

      actions.select_default:replace(source_session)

      local delete_session = function()
        local entry = actions.get_selected_entry(prompt_bufnr)
        if entry then
          vim.fn.delete(vim.g.sessions_dir .. entry.value)
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
