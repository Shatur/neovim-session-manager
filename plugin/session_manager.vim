if exists('g:loaded_session_manager')
  finish
endif
let g:loaded_session_manager = v:true

let g:sessions_dir = get(g:, 'sessions_dir', stdpath('data') .. '/sessions/')
let g:sessions_path_replacer = get(g:, 'sessions_path_replacer', '__')
let g:autoload_last_session = get(g:, 'autoload_last_session', v:true)
let g:autosave_last_session = get(g:, 'autosave_last_session', v:true)

command! -bang -nargs=? LoadSession lua require('session_manager').load_session(<args>, <bang>v:true)
command! SaveSession lua require('session_manager').save_session()

augroup session_manager
  autocmd!
  autocmd VimEnter * ++nested lua if vim.g.autoload_last_session and vim.fn.argc() == 0 then require('session_manager').load_session() end
  autocmd VimLeavePre * lua if vim.g.autosave_last_session then require('session_manager').save_session() end
augroup END
