if exists('g:loaded_session_manager')
  finish
endif
let g:loaded_session_manager = v:true

command! -bang -nargs=? -complete=file LoadSession lua require('session_manager').load_session(<q-args>, <q-bang>)
command! -nargs=? SaveSession lua require('session_manager').save_session(<q-args>)

augroup session_manager
  autocmd!
  autocmd VimEnter * ++nested lua require('session_manager').autoload_session()
  autocmd VimLeavePre * lua require('session_manager').autosave_session()
augroup END
