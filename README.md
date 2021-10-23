# Neovim Session Manager

A Neovim plugin that use build-in `:mksession` to manage sessions like folders in VSCode. It allows you to save the current folder as a session to open it later. The plugin can also automatically load the last session on startup, save the current one on exit and switch between session folders using Telescope.

The plugin saves the sessions in the specified folder (see [parameters](#parameters)). The session corresponds to the working directory. If a session already exists for the current folder, it will be overwritten.

## Dependencies

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) to select sessions.

## Commands

| Command                                    | Description                                                                                                                                 |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `:SaveSession`                             | Works like `:mksession`, but saves/creates current directory as a session in `sessions_dir`.                                                |
| `:LoadSession[!]`                          | Will remove all buffers and `:source` the last saved session file. When `!` is specified, the modified buffers will not be saved.           |
| `:Telescope sessions [save_current=false]` | Select and load a session. You can pass `save_current=true` to save the current session. Use `d` in normal mode to delete selected session. |

## Configuration

To configure the plugin, you can call `require('session_manager').setup(values)`, where `values` is a dictionary with the parameters you want to override. Here are the defaults:

```lua
local Path = require('plenary.path')
require('session_manager').setup({
  sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'), -- The directory where the session files will be saved.
  path_replacer = '__', -- The character to which the path separator will be replaced for session files.
  colon_replacer = '++', -- The character to which the colon symbol will be replaced for session files.
  autoload_last_session = true, -- Automatically load last session on startup is started without arguments.
  autosave_last_session = true, -- Automatically save last session on exit.
  autosave_ignore_paths = { '~' }, -- Folders to ignore when autosaving a session.
  autosave_ignore_not_normal = true, -- Plugin will not save a session when no writable and listed buffers are opened.
})
```

To make sessions telescope pickers available you should call `require('telescope').load_extension('sessions')`.
