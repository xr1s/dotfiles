" augroup organize_imports
"   autocmd! BufWritePre *.py silent! :call CocAction('organizeImport')<CR>
" augroup END

noremap <silent> <Leader>= :call CocAction('organizeImport')<CR>
