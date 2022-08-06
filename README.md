# Neovim Session Manager

A Neovim 0.7+ plugin that use built-in `:mksession` to manage sessions like folders in VSCode. It allows you to save the current folder as a session to open it later. The plugin can also automatically load the last session on startup, save the current one on exit and switch between session folders.

The plugin saves the sessions in the specified folder (see [configuration](#configuration)). The session corresponds to the working directory. If a session already exists for the current folder, it will be overwritten.

## Dependencies

- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for internal helpers.

## Commands

Use the command `:SessionManager[!]` with one of the following arguments:

| Argument                   | Description                                                                                  |
| -------------------------- | -------------------------------------------------------------------------------------------- |
| `load_session`             | Select and load session.                                                                     |
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
require('session_manager').setup({
  sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'), -- The directory where the session files will be saved.
  path_replacer = '__', -- The character to which the path separator will be replaced for session files.
  colon_replacer = '++', -- The character to which the colon symbol will be replaced for session files.
  autoload_mode = require('session_manager.config').AutoloadMode.LastSession, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
  autosave_last_session = true, -- Automatically save last session on exit and on session switch.
  autosave_ignore_not_normal = true, -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
  autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
    'gitcommit',
  }, 
  autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
  max_path_length = 80,  -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
})
```

## Autocommands

You can specify commands to be executed automatically after saving or loading a session using the following events:

| Event           | Description                        |
| --------------- | ---------------------------------- |
| SessionSavePost | Executed after a session is saved  |
| SessionLoadPost | Executed after a session is loaded |

For example, if you would like to have NvimTree or any other file tree automatically opened after a session load, have this somewhere in your config file:

```lua
local config_group = vim.api.nvim_create_augroup('MyConfigGroup', {}) -- A global group for all your config autocommands

vim.api.nvim_create_autocmd({ 'User' }, {
  pattern = "SessionLoadPost",
  group = config_group,
  callback = function()
    require('nvim-tree').toggle(false, true)
  end,
})
```

For more information about autocmd and its event, see also:
- [`:help autocmd`](https://neovim.io/doc/user/autocmd.html)
- [`:help events`](https://neovim.io/doc/user/autocmd.html#events)
- [`:help User`](https://neovim.io/doc/user/autocmd.html#User)
