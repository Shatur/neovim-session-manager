local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local conf = require('telescope.config').values
local scandir = require('plenary.scandir')
local config = require('session_manager.config')
local entry_display = require('telescope.pickers.entry_display')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local telescope = require('telescope')
local utils = require('session_manager.utils')
local Path = require('plenary.path')

local get_sessions_with_local = function(opts)
  local sessions = {}
  for _, session_filename in ipairs(scandir.scan_dir(tostring(config.sessions_dir), opts)) do
    local dir = config.session_filename_to_dir(session_filename)
    if dir:is_dir() then
      table.insert(sessions, { timestamp = vim.fn.getftime(session_filename), filename = session_filename, dir = dir })
    else
      Path:new(session_filename):rm()
    end
  end
  table.sort(sessions, function(a, b) return a.timestamp > b.timestamp end)

  -- If no sessions to list, send a notification.
  if not (opts and opts.silent) and #sessions == 0 then
    vim.notify('The only available session is your current session. Nothing to select from.', vim.log.levels.INFO)
  end

  return sessions
end

local get_path_parts = function(path_str)
  -- remove ending /
  if string.sub(path_str, #path_str, #path_str) == Path.path.sep then
    path_str = string.sub(path_str, 1, #path_str - 1)
  end

  return vim.split(path_str, Path.path.sep)
end

local get_basename = function(path_str)
  local parts = get_path_parts(path_str)
  return parts[#parts]
end

local generate_sessions = function()
  local sessions = {}
  local raw = get_sessions_with_local()
  for _, path in ipairs(raw) do
    table.insert(sessions, {
      name = get_basename(path.dir.filename),
      path = path.dir,
    })
  end
  return sessions
end

local open = function(path)
  local format_name = utils.shorten_path(path)
  local session_filename = config.dir_to_session_filename(format_name).filename
  utils.load_session(session_filename, false)
end

local session_picker = function(opts)
  -- compute spacing
  local session_list = generate_sessions()
  local width = 10
  for _, session in ipairs(session_list) do
    if #session.name > width then
      width = #session.name + 2
    end
  end

  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = width },
      {},
    },
  })

  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = 'Sessions',

      finder = finders.new_table({
        results = session_list,
        entry_maker = function(entry)
          return {
            value = entry,
            ---@diagnostic disable-next-line: redefined-local
            display = function(entry)
              local filename = string.gsub(entry.value.path.filename, '^/home/[^/]+/', '~/')
              return displayer({
                { entry.ordinal },
                { filename, 'String' },
              })
            end,
            ordinal = entry.name,
          }
        end,
      }),

      sorter = conf.generic_sorter(opts),

      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local session = selection.value
          if session and session ~= '' then
            open(session.path)
          end
        end)
        actions.select_tab:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local session = selection.value
          if session and session ~= '' then
            open(session.path)
          end
        end)
        return true
      end,
    })
    :find()
end

return telescope.register_extension({
  exports = {
    session_manager = function(opts) session_picker(opts) end,
  },
})
