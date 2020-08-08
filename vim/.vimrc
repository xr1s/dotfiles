" Vim-Plug
call plug#begin('~/.vim/plugged')
Plug 'flazz/vim-colorschemes'
Plug 'sheerun/vim-polyglot'
Plug 'thinca/vim-quickrun'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'w0rp/ale'
Plug 'ycm-core/YouCompleteMe', {
\ 'do': './install.py --clangd-completer --rust-completer --java-completer --go-completer',
\ 'for':  ['c', 'cpp', 'python', 'rust', 'java', 'go', 'kotlin'],
\}
call plug#end()

" Reload after vimrc changed
augroup reload-vimrc
  autocmd! BufWritePost .vimrc source $MYVIMRC
augroup end

filetype on
filetype plugin on
filetype indent on
syntax on

" Move cursor
noremap <expr> j v:count ? 'j' : 'gj'
noremap <expr> k v:count ? 'k' : 'gk'
noremap gj j
noremap gk k
nnoremap { {zz
nnoremap } }zz

" Leader
let mapleader = ' '
let maplocalleader = ' '

" Language
let $LANG = 'en'
set langmenu=en
set encoding=utf-8
scriptencoding utf-8

set backspace=indent,eol,start

" Search
set ignorecase
set smartcase
set hlsearch
set incsearch
set magic

" Indent
set tabstop=2
set softtabstop=2
set shiftwidth=2
set shiftround
set autoindent
set smartindent
set expandtab
set smarttab
xnoremap > >gv
xnoremap < <gv

" Mark
noremap ' `
noremap ` '

" Accelerate
set ttyfast
set lazyredraw

" C-mode completion
set wildmenu
set wildmode=list:full
set wildignore=*/.git,*/.hg,*/.svn

" Window
set splitbelow
set splitright
nnoremap - <c-w>-
nnoremap = <c-w>+
nnoremap , <c-w><
nnoremap . <c-w>>
nnoremap <m-h> <c-w>h
nnoremap <m-j> <c-w>j
nnoremap <m-k> <c-w>k
nnoremap <m-l> <c-w>l

" Color scheme
set background=dark
colorscheme gruvbox
" Use terminal background color.
highlight Normal ctermfg=NONE ctermbg=NONE
highlight Pmenu ctermfg=NONE ctermbg=238 cterm=NONE
highlight PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE

" Buffer (act like vimium in chrome)
noremap <silent><leader>q :bdelete<cr>
noremap <silent>J :bprev<cr>
noremap <silent>K :bnext<cr>

" Force save
command W w !sudo tee % > /dev/null

" YouCompleteMe
let g:ycm_confirm_extra_conf = 0
let g:ycm_global_ycm_extra_conf = '~/.vim/ycm.py'
let g:ycm_semantic_triggers = {
\ 'c,cpp,python,java,go,cs,javascript,kotlin': ['re!\w{2}'],
\}
let g:ycm_error_symbol = 'E'
let g:ycm_warning_symbol = 'W'
let s:rust_sysroot = substitute(system('rustc --print sysroot'), '\n', '', '')
let g:ycm_rust_src_path = s:rust_sysroot . '/lib/rustlib/src/rust/src'
let s:lsp = $HOME . '/.vim/language-server'
let g:ycm_language_server = [
\ {
\   'name': 'kotlin',
\   'filetypes': ['kotlin'],
\   'cmdline': [s:lsp . '/kotlin/server/build/install/server/bin/kotlin-language-server'],
\ }
\]

" QuickRun
let g:quickrun_config = {
\ '_': {
\   'outputter': 'buffer',
\   'runner': 'job',
\ },
\ 'cpp': {
\   'exec': ['%c -std=c++2a -fcoroutines -lstdc++fs %o %s -o %s:p:r', '%s:p:r %a'],
\ }
\}

" Asynchronous Lint Engine
let g:ale_linters = {
\ 'c': [],
\ 'cpp': [],
\ 'java': [],
\ 'rust': ['cargo'],
\ 'python': ['flake8'],
\ 'vim': ['vint'],
\ 'go': [],
\}
let g:ale_sign_warning = 'W'
let g:ale_sign_error = 'E'
let g:ale_lint_on_text_exchanged = 'always'
let g:ale_lint_on_insert_leave = 1
let g:ale_echo_msg_format = '[%linter%] %code: %%s'

" Airline
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.maxlinenr = ' '
let g:airline_symbols.branch = ''
let g:airline_symbols.paste = 'P'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_symbols.readonly = ''
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_theme = 'violet'

let g:airline#parts#ffenc#skip_expected_string = 'utf-8[unix]'
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#ycm#enabled = 1
let g:airline#extensions#ycm#error_symbol = 'E'
let g:airline#extensions#ycm#warning_symbol = 'W'

" Vim-Polyglot
let g:rustfmt_autosave = 1
