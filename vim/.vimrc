" Vim-Plug
call plug#begin('~/.vim/plugged')
Plug 'Valloric/YouCompleteMe', {
  \'do': './install.py --clang-completer --rust-completer --go-completer --java-completer',
  \'for': ['c', 'cpp', 'python', 'rust', 'go', 'java'],
  \}
Plug 'w0rp/ale'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Reewr/vim-monokai-phoenix'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'rust-lang/rust.vim'
Plug 'solarnz/thrift.vim'
call plug#end()

filetype off
filetype plugin indent on
syntax on

set nocompatible
set modeline
set ruler
set encoding=UTF-8
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set noshiftround
set hlsearch
set colorcolumn=81
set splitright
set splitbelow
set number
set cursorline
set cursorcolumn
set backspace=indent,eol,start
colorscheme monokai-phoenix
set rtp+=/usr/local/opt/fzf

" YouCompleteMe
let g:ycm_confirm_extra_conf = 0
let g:ycm_global_ycm_extra_conf = $HOME . '/.vim/ycm.py'
let g:ycm_semantic_triggers = {
  \'c,cpp,python,java,go,cs,javascript': ['re!\w{2}'],
  \}
let g:ycm_error_symbol = '●'
let g:ycm_warning_symbol = '●'
let g:rust_src_path = substitute(system('rustc --print sysroot'), '\n$', '', '') . '/rustlib/src/rust/src'

" Asynchronous Lint Engine
let g:ale_linters = {
  \'c': [],
  \'cpp': [],
  \'rust': ['rustc', 'cargo'],
  \'go': ['go vet'],
  \'python': ['flake8'],
  \}
let g:ale_sign_warning = '●'
let g:ale_sign_error = '●'
let g:ale_lint_on_text_exchanged = 'always'
let g:ale_lint_on_insert_leave = 1
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:airline#extension#ale#enabled = 1

" Airline
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.maxlinenr = ' '
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'P'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline#parts#ffenc#skip_expected_string = 'utf-8[unix]'
let g:airline_theme = 'violet'

hi Normal ctermfg=NONE ctermbg=NONE
hi Pmenu ctermfg=NONE ctermbg=236 cterm=NONE
hi PmenuSel ctermfg=NONE ctermbg=24 cterm=NONE
