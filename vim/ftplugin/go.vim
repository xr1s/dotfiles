" On buffer close or switch, go format
augroup format
  autocmd!
  autocmd BufWritePost * silent! :!goimports -w %
  autocmd BufWritePost * silent! :redraw!
augroup end

noremap <leader>] :vertical YcmCompleter GoTo<cr>

augroup reload
  autocmd CursorHold * checktime
augroup end
set autoread

" Go uses hard tabs
set shiftwidth=4
set tabstop=4
set noexpandtab
set softtabstop=0
