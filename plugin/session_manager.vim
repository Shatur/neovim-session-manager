if exists('g:loaded_session_manager')
  finish
endif
let g:loaded_session_manager = v:true

let g:sessions_dir = get(g:, 'sessions_dir', stdpath('data') .. '/sessions/')
let g:sessions_path_replacer = get(g:, 'sessions_path_replacer', '__')
let g:sessions_colon_replacer = get(g:, 'sessions_colon_replacer', '++')
let g:autoload_last_session = get(g:, 'autoload_last_session', v:true)
let g:autosave_last_session = get(g:, 'autosave_last_session', v:true)
let g:autosave_ignore_paths = get(g:, 'autosave_ignore_paths', ['~'])

command! -bang -nargs=? -complete=file LoadSession lua require('session_manager').load_session(<args>, <bang>v:true)
command! SaveSession lua require('session_manager').save_session()

augroup session_manager
  autocmd!
  autocmd VimEnter * ++nested lua require('session_manager.utils').autoload_session()
  autocmd VimLeavePre * lua require('session_manager.utils').autosave_session()
augroup END
