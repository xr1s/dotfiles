" On buffer close or switch, go format
autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')

augroup reload
  autocmd CursorHold * checktime
augroup end
set autoread

" Go uses hard tabs
set shiftwidth=4
set tabstop=4
set noexpandtab
set softtabstop=0

