if !has('nvim-0.6.0')
  echoerr 'neovim-session-manager requires at least nvim-0.6.0'
  finish
end

if exists('g:loaded_session_manager')
  finish
endif
let g:loaded_session_manager = v:true

function! s:match_commands(arg, line, pos)
  return luaeval('require("session_manager.commands").match_commands("' .. a:arg .. '")')
endfunction

command! -bang -nargs=1 -complete=customlist,s:match_commands SessionManager lua require('session_manager.commands').run_command(<q-args>, <q-bang>)

augroup session_manager
  autocmd!
  autocmd VimEnter * ++nested lua require('session_manager').autoload_session()
  autocmd VimLeavePre * lua require('session_manager').autosave_session()
  autocmd StdinReadPre * let g:started_with_stdin = v:true
augroup END
