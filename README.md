# Neovim Session Manager

A Neovim plugin that use build-in `:mksession` to manage sessions in a convenient way. The plugin can automatically load the last session on startup, save the current one on exit and switch between sessions using Telescope.

The plugin saves the sessions in the specified folder (see [parameters](#parameters)). The session corresponds to the working directory. If a session already exists for the current folder, it will be overwritten.

## Dependencies

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) to select sessions.

## Commands

| Command                                   | Function                                                          | Description                                                                                                                                                                                |
| ----------------------------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `:SaveSession [<session>]`                | `require('session_manager').save_session(filename)`               | Works like `:mksession`, but saves/creates session in `g:sessions_dir`. If `filename` is not specified, the current directory name path will be used for the name.                         |
| `:LoadSession[!] [<session>]`             | `require('session_manager').load_session(filename, save_current)` | Will remove all buffers and `:source` specified session file. When [!] is included an existing session will not be saved. If `filename` is not specified, the last session will be loaded. |
| `:Telescope sessions [save_current=true]` | `require('telescope').extensions.sessions.sessions()`             | Select and load a session. You can pass `save_current=true` to save the current session. Use `d` in normal mode to delete selected session.                                                |

## Configuration

To configure the plugin, you can call `require('session_manager').setup(values)`, where `values` is a dictionary with the parameters you want to override. Here are the defaults:

```lua
require('session_manager').setup({
  sessions_dir = vim.fn.stdpath('data') .. '/sessions/', -- The directory where the session files will be saved. The path should ends with a trailing slash.
  path_replacer = '__', -- The character to which the path separator will be replaced for session files.
  colon_replacer = '++', -- The character to which the colon symbol will be replaced for session files. Used only on Windows.
  autoload_last_session = true, -- Automatically load last session on startup is started without arguments.
  autosave_last_session = true, -- Automatically save last session on exit.
  autosave_ignore_paths = { '~' }, -- Folders to ignore when autosaving a session.
})
```

To make sessions telescope pickers available you should call `require('telescope').load_extension('sessions')`.
