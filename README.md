# Neovim Session Manager

A Neovim 0.7+ plugin that use built-in `:mksession` to manage sessions like folders in VSCode. It allows you to save the current folder as a session to open it later. The plugin can also automatically load the last session on startup, save the current one on exit and switch between session folders.

The plugin saves the sessions in the specified folder (see [configuration](#configuration)). The session corresponds to the working directory. If a session already exists for the current folder, it will be overwritten.

## Dependencies

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for internal helpers.

## Commands

Use the command `:SessionManager[!]` with one of the following arguments:

| Argument                   | Description                                                                                  |
| -------------------------- | -------------------------------------------------------------------------------------------- |
| `load_session`             | Select and load session. (Your current session won't appear on the list).                    |
| `load_last_session`        | Will remove all buffers and `:source` the last saved session.                                |
| `load_current_dir_session` | Will remove all buffers and `:source` the last saved session file of the current dirtectory. |
| `save_current_session`     | Works like `:mksession`, but saves/creates current directory as a session in `sessions_dir`. |
| `delete_session`           | Select and delete session.                                                                   |

When `!` is specified, the modified buffers will not be saved.

Commands `load_session` and `delete_session` use `vim.ui.select()`. To use your favorite picker like Telescope, consider installing [dressing.nvim](https://github.com/stevearc/dressing.nvim) or [telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim).

## Configuration

To configure the plugin, you can call `require('session_manager').setup(values)`, where `values` is a dictionary with the parameters you want to override. Here are the defaults:

```lua
local Path = require('plenary.path')
local config = require('session_manager.config')
require('session_manager').setup({
  sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'), -- The directory where the session files will be saved.
  session_filename_to_dir = session_filename_to_dir, -- Function that replaces symbols into separators and colons to transform filename into a session directory.
  dir_to_session_filename = dir_to_session_filename, -- Function that replaces separators and colons into special symbols to transform session directory into a filename. Should use `vim.loop.cwd()` if the passed `dir` is `nil`.
  autoload_mode = config.AutoloadMode.LastSession, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
  autosave_last_session = true, -- Automatically save last session on exit and on session switch.
  autosave_ignore_not_normal = true, -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
  autosave_ignore_dirs = {}, -- A list of directories where the session will not be autosaved.
  autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
    'gitcommit',
    'gitrebase',
  },
  autosave_ignore_buftypes = {}, -- All buffers of these bufer types will be closed before the session is saved.
  autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
  max_path_length = 80,  -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
})
```

## Autocommands

You can specify commands to be executed automatically after saving or loading a session using the following events:

| Event           | Description                         |
| --------------- | ----------------------------------- |
| SessionSavePre  | Executed before a session is saved  |
| SessionSavePost | Executed after a session is saved   |
| SessionLoadPre  | Executed before a session is loaded |
| SessionLoadPost | Executed after a session is loaded  |

For example, if you would like to have NvimTree or any other file tree automatically opened after a session load, have this somewhere in your config file:

```lua
local config_group = vim.api.nvim_create_augroup('MyConfigGroup', {}) -- A global group for all your config autocommands

vim.api.nvim_create_autocmd({ 'User' }, {
  pattern = "SessionLoadPost",
  group = config_group,
  callback = function()
    require('nvim-tree.api').tree.toggle(false, true)
  end,
})
```

## Save session on BufWrite

You can enable this opt in feature with

```lua
-- Auto save session
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  callback = function ()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      -- Don't save while there's any 'nofile' buffer open.
      if vim.api.nvim_get_option_value("buftype", { buf = buf }) == 'nofile' then
        return
      end
    end
    session_manager.save_current_session()
  end
})
```

For more information about autocmd and its event, see also:

- [`:help autocmd`](https://neovim.io/doc/user/autocmd.html)
- [`:help events`](https://neovim.io/doc/user/autocmd.html#events)
- [`:help User`](https://neovim.io/doc/user/autocmd.html#User)
