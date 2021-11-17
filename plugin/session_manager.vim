if exists('g:loaded_session_manager')
  finish
endif
let g:loaded_session_manager = v:true

command! -bang LoadLastSession lua require('session_manager').load_last_session(<q-bang>)
command! -bang LoadCurrentDirSession lua require('session_manager').load_current_dir_session(<q-bang>)
command! SaveSession lua require('session_manager').save_current_session()

augroup session_manager
  autocmd!
  autocmd VimEnter * ++nested lua require('session_manager').autoload_session()
  autocmd VimLeavePre * lua require('session_manager').autosave_session()
  autocmd StdinReadPre * let g:started_with_stdin = v:true
augroup END
