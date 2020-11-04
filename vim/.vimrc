" Vim-Plug
call plug#begin('~/.vim/plugged')
Plug 'flazz/vim-colorschemes'
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
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
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#ycm#enabled = 1
let g:airline#extensions#ycm#error_symbol = 'E'
let g:airline#extensions#ycm#warning_symbol = 'W'

" Vim-Polyglot
let g:rustfmt_autosave = 1
" Conquer of Completion
set cmdheight=2
set updatetime=500
inoremap <expr><tab>   pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
inoremap <silent><expr><cr> pumvisible() ? coc#_select_confirm()
                              \: "\<c-g>u\<cr>\<c-r>=coc#on_enter()\<cr>"
nmap <silent> <leader>[ <plug>(coc-diagnostic-prev)
nmap <silent> <leader>] <plug>(coc-diagnostic-next)
noremap <silent><leader>d :call CocActionAsync('jumpDefinition')<cr>
noremap <silent><leader>f :call CocActionAsync('format')<cr>
noremap <silent><leader>r :call CocActionAsync('jumpReferences')<cr>
