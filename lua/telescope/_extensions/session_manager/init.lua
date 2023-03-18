-- print notice message
local function echo(str) print('[telescope.session_manager]' .. str) end

-- check telescope and neovim-session-manager
local ok, telescope = pcall(require, 'telescope')
if not ok then
  echo('please install telescope.nvim first')
  return
end

-- telescope & session_manager builtin utils
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local actions = require('telescope.actions')
local state = require('telescope.actions.state')
local session_utils = require('session_manager.utils')

-- get keyed sessions by neovime-session-manager utils
local get_keyed_sessions = function()
  local raw_sessions = session_utils.get_sessions()
  local keyed_sessions = {}
  for _, item in ipairs(raw_sessions) do
    keyed_sessions[item.dir.filename] = item.filename
  end
  return keyed_sessions
end

-- generate sub commands
local gen_subcommand = function(title, opts, handler)
  return function(_)
    local sessions = get_keyed_sessions()
    pickers
        .new(_, {
          prompt_title = title,
          sorter = sorters.get_generic_fuzzy_sorter(),
          finder = finders.new_table({
            results = vim.tbl_keys(sessions),
          }),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              -- close telescope prompt && execute sub command handle function
              actions.close(prompt_bufnr)
              handler(opts, sessions, state.get_selected_entry())
            end)
            return true
          end,
        })
        :find()
  end
end

-- load command
local load = function(options, sessions, selected)
  -- Reserved options for easy expansion
  session_utils.load_session(sessions[selected[1]], false)
end

-- delete command
local delete = function(options, sessions, selected)
  -- Reserved options for easy expansion
  session_utils.delete_session(sessions[selected[1]], false)
end

-- register telescope extension
local opts = {}
return telescope.register_extension({
  setup = function(user_opts) opts = vim.tbl_extend('force', opts, user_opts) end,
  exports = {
    load = gen_subcommand('Load Sessions', opts, load),
    delete = gen_subcommand('Delete Sessions', opts, delete),
  },
})
