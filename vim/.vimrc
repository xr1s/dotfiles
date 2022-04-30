let g:polyglot_disabled = ['c/c++', 'cpp-modern']

" Vim-Plug
call plug#begin('~/.vim/plugged')
Plug 'flazz/vim-colorschemes'
Plug 'kevinoid/vim-jsonc'
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

" Reload after vimrc changed
augroup reload-vimrc
  autocmd! BufWritePost .vim source $MYVIMRC
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
set mouse=a
inoremap <LeftMouse> <NOP>

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
noremap <silent>J :bprev<cr>
noremap <silent>K :bnext<cr>
noremap <silent><leader>q :bprev \| bdelete #<cr>
noremap <silent><leader>u :update<cr>

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

" Vim-Polyglot
let g:rustfmt_autosave = 1

" Conquer of Completion
set cmdheight=2
set updatetime=500
let g:coc_config_home = '~/.vim'

inoremap <expr><tab>   pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
inoremap <silent><expr><cr> pumvisible() ? coc#_select_confirm()
                              \: "\<c-g>u\<cr>\<c-r>=coc#on_enter()\<cr>"
nmap <silent> <leader>, <plug>(coc-diagnostic-prev)
nmap <silent> <leader>. <plug>(coc-diagnostic-next)
noremap <silent> <leader>cd :call CocActionAsync('jumpDefinition')<cr>
noremap <silent> <leader>cf :call CocActionAsync('format')<cr>
noremap <silent> <leader>cr :call CocActionAsync('jumpReferences')<cr>
noremap <silent> <leader>ca :CocAction<cr>
noremap <silent> <leader>crs :CocRestart<cr>

" NERDTree
noremap <silent> <leader>nt :NERDTree<cr>

" Fugitive
noremap <silent> <leader>ga :Git add % \| qa<cr>
noremap <silent> <leader>gb :Git blame<cr>
noremap <silent> <leader>w <c-w><c-w>
