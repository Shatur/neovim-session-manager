# Neovim Session Manager

A Neovim plugin that use build-in `:mksession` to manage sessions in a convenient way. The plugin can automatically load the last session on startup, save the current one on exit and switch between sessions using Telescope.

The plugin saves the sessions in the specified folder (see [parameters](#parameters)). The session corresponds to the working directory. If a session already exists for the current folder, it will be overwritten.

## Dependencies

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) to select sessions.

## Setup

To make sessions telescope pickers available you should call `require('telescope').load_extension('session_manager')`.

## Commands

| Command                       | Function                                                          | Description                                                                                                                                                                                |
| ----------------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `:SaveSession [<session>]`    | `require('session_manager').save_session(filename)`               | Works like `:mksession`, but saves/creates session in `g:sessions_dir`. If `filename` is not specified, the current directory name path will be used for the name.                         |
| `:LoadSession[!] [<session>]` | `require('session_manager').load_session(filename, save_current)` | Will remove all buffers and `:source` specified session file. When [!] is included an existing session will not be saved. If `filename` is not specified, the last session will be loaded. |
| `:Telescope sessions`         | `require('telescope').extensions.sessions.load{}`                 | Select and load a session. Use `d` in normal mode to selected session.                                                                                                                     |

## Parameters

| Variable                    | Default value                      | Description                                                                                    |
| --------------------------- | ---------------------------------- | ---------------------------------------------------------------------------------------------- |
| `g:loaded_session_manager`  | `v:true`                           | Set this value to `v:false` to disable plugin loading.                                         |
| `g:sessions_dir`            | `stdpath('data') .. '/sessions/')` | The directory where the session files will be saved.                                           |
| `g:sessions_path_replacer`  | `'__'`                             | The character to which the path separator will be replaced for session files.                  |
| `g:sessions_colon_replacer` | `'++'`                             | The character to which the colon symbol will be replaced for session files (only for Windows). |
| `g:autoload_last_session`   | `v:true`                           | Automatically load last session on startup is started without arguments.                       |
| `g:autosave_last_session`   | `v:true`                           | Automatically save last session on exit.                                                       |
| `g:autosave_ignore_paths`   | `['~']`                            | Folders to ignore when autosaving a session.                                                   |
