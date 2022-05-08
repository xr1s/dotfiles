" 前言：
" 1.
" 很少用到 <Esc>，基本都使用 <C-[> 了
" 将 Capslock 映射为 Ctrl、⇪ 映射为 ⌃ 后，按键位置也比 <Esc> 更友好
" 2.
" 选择模式下文中的选择模式都指 visual 模式
" 因此也只会使用 xnoremap 而非 vnoremap、snoremap
" 另一个 select 模式？狗都不用
" 3.
" macOS 远程 SSH 到 Linux 之后
" 原生 vim 不会将 ⌥+* 识别为 <M-*>，只好都 <Esc>* 做一下替补了
" Neovim 不影响，不配置 <Esc>* 也可以正常识别 ⌥+* 为 <M-*>
" TODO: 在 Windows 上测试一下 map <Esc>* 是否可以用 Alt+*

" 设置 Neovim 使用 Vim 的运行时路径 {{{
" 不过注意 Neovim 需要在 Shell 中设置 VIMINIT 环境变量来加载 .vimrc
if has('nvim') && has('vim_starting')
  " 这里重新设置 $MYVIMRC 是为了防止 Shell 中设置了 export MYVIMRC='~/.vimrc'
  " 如果 Shell 中使用 '~/.vimrc' 的话会导致后面的 autocmd 无法匹配本文件而设置自动重新加载失败
  let $MYVIMRC = expand($MYVIMRC)
  set runtimepath^=~/.vim
  set runtimepath-=~/.config/nvim
  set runtimepath-=~/.config/nvim/after
  set packpath^=~/.vim
  set packpath-=~/.config/nvim
  set packpath-=~/.config/nvim/after
endif
" }}}

" Vim-Plug {{{

" Polyglot 要求该变量在载入插件前定义
" 不高亮 c/c++ cpp-modern 是因为 LSP 的语义高亮插件可以更精确地高亮
" 这两个定义了一堆内置类型来做关键字匹配高亮，会把不该高亮的给高亮了
let g:polyglot_disabled = ['c/c++', 'cpp-modern']

call plug#begin('~/.vim/plugged')
Plug 'gruvbox-community/gruvbox'
Plug 'jackguo380/vim-lsp-cxx-highlight', { 'for': ['c', 'cpp'] }
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'preservim/nerdtree', { 'on': 'NERDTree' }
Plug 'ryanoasis/vim-devicons'
Plug 'sheerun/vim-polyglot'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight', { 'on':  'NERDTree' }
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
call plug#end()
" }}}

" 自动重载 vimrc {{{
augroup reload-vimrc
  autocmd!
  autocmd BufWritePost $MYVIMRC source $MYVIMRC
  autocmd BufWritePost $MYVIMRC AirlineRefresh
augroup end
" }}}

" Leader {{{

" 空格平时也没啥用，移动光标根本用不到
" 作为 <Leader> 按起来也很方便
let mapleader = ' '
" }}}

" 折叠 {{{
" <nowait> 阻止 vim 将第二个 <Space> 识别为另一个 <Leader>
nnoremap <Leader><Space> za
" }}}

" 语言编码 {{{
language en_US.UTF8
set encoding=UTF-8
set fileencodings=UTF-8,GB18030
" }}}

" 外观主题 {{{
set background=dark
colorscheme gruvbox
" }}}

" 缩进 {{{

" 已经习惯了两格缩进
set tabstop=2
set softtabstop=2
set shiftwidth=2
set shiftround
set autoindent
set smartindent
set expandtab
set smarttab

" 允许在选择模式下重复使用缩进，默认情况按一次 < > 就会退出选择模式
" gv 的含义是进入选择模式，并自动选中上一次的选择
xnoremap > >gv
xnoremap < <gv
" }}}

" 命令模式 {{{
" 命令模式补全很大程度上在模拟我 zsh 的配置
" 命令模式下如果可以补全，按下 Tab 时开启补全
set wildmenu
" 补全控制
" longest: 按第一次 Tab 先补完最长公共前缀（并列出所有候选）
" full:    再按一次 Tab 再在候选中选择下一条补全
set wildmode=longest:full,full
set wildignore=*/.git,*/.hg,*/.svn

" 模拟 tcsh 的光标控制，参见 "tcsh-style"
cnoremap <C-A> <Home>
cnoremap <C-F> <Right>
cnoremap <C-B> <Left>
cnoremap <Esc>b <S-Left>
cnoremap <Esc>f <S-Right>
" 模拟 Alt+Backspace ⌥+⌫ 删去前一个单词
cnoremap <Esc><BS> <C-W>
" 命令行补全模式下，按下回车的含义变为选中当前项（默认是直接确认并执行命令）
cnoremap <expr> <CR> pumvisible() ? '<Space><BS>' : '<CR>'
" 命令行补全模式下，按下 Ctrl+C 的含义变为撤回当前补全项
cnoremap <expr> <C-C> pumvisible() ? '<C-E>' : '<C-C>'
" }}}

" 光标控制 {{{

" 在开启 wrap 的情况下（默认开启），超过窗口宽度的文字会折行显示
" 这时候使用 j k 移动光标会直接跳转到文件的下一行而不是屏幕的下一行
" 为了更符合习惯，将 j k 默认映射成 gj gk，用于跳转到屏幕的下一行
" 但是如果使用诸如 10j 10k 这种指定行数的多行跳转，则仍然使用默认跳转
noremap <expr> j v:count ? 'j' : 'gj'
noremap <expr> k v:count ? 'k' : 'gk'
" 将 gj gk 映射回 j k 以防需要
noremap gj j
noremap gk k

" 使用 { } 跳转后将光标移动到屏幕中央
nnoremap { {zz
nnoremap } }zz

" 退格键允许删除自动缩进、允许跨行、允许删除之前编辑内容
" 详细介绍：https://vi.stackexchange.com/questions/2162
set backspace=indent,eol,start

" 启用完整鼠标功能（移动、选中、匹配等）
set mouse=a
" 编辑模式下禁用鼠标单击移动，防止手摸到触控版后光标乱窜
inoremap <LeftMouse>  <Nop>
inoremap <RightMouse> <Nop>
" }}}

" 搜索 {{{

" 参见 "/ignorecase"
" 和 smartcase 配合
set ignorecase
" 允许输入小写搜索对应大写，但是输入大写无法匹配到对应小写
set smartcase

" 只有在增量搜索过程中才高亮搜索结果
" 因为高亮平时放着有些瞎眼，所以只在输入过程中高亮
" 不过没有高亮会有忘了之前在搜索什么的问题，待观察
" 对于标识符类的搜索高亮，配置了光标悬浮其上时 coc 自动高亮
set nohlsearch
augroup incsearch-highlight
  autocmd!
  autocmd CmdlineEnter * set hlsearch
  autocmd CmdlineLeave * set nohlsearch
augroup end

" 增量搜索，输入同时更新搜索结果（光标会直接移动）
" 温馨提示：善用 "c_<C-G>" 和 "c_<C-T>"
set incsearch

" 搜索直接进入 very magic 模式，该模式下正则语法十分接近 Perl 的正则，详见 "/magic"
" 注意单词边界不再是默认的 \< \>，而是不转义的 < >，同时匹配 < > 需要转义 \< \>
" 而想要匹配 = 也需要 \=（我是加了这个才知道 \= 有特殊含义的，详见 "/multi"）
noremap / /\v
noremap ? ?\v
" 同上，但是命令模式
" FIXME: 进入命令模式后会在输入 s 后有一段等待时间，体验不好
" 以及可能会出现例如 :%s/\vthis 这种搜索，此时按下 / 会自动加入 \v
" 考虑 autocmd "CmdlineChanged" + "getchar()" + "feedkeys()"？似乎会递归，看看能否解决
cnoremap s/ s/\v
cnoremap g/ g/\v
cnoremap s? s?\v
cnoremap g? g?\v

" 使 n 总是正向搜索，N 总是反向搜索
nnoremap <expr> n 'Nn'[v:searchforward] .. (&foldopen =~? 'search\\|all' ? 'zv' : '')
nnoremap <expr> N 'nN'[v:searchforward] .. (&foldopen =~? 'search\\|all' ? 'zv' : '')

" 使用 * # 的时候要求大小写精确匹配
" 同时保持 n 始终向后搜索，N 始终向前搜索，避免操作上混乱
" normal! wb 是为了移动到单词开头，不然 # 第一次搜索会搜到自己
nnoremap <silent> *  :normal! wb<CR>:let @/ = '\<' .. expand('<cword>') .. '\>'<CR>n
nnoremap <silent> #  :normal! wb<CR>:let @/ = '\<' .. expand('<cword>') .. '\>'<CR>N
nnoremap <silent> g* :normal! wb<CR>:let @/ = ''   .. expand('<cword>')        <CR>n
nnoremap <silent> g# :normal! wb<CR>:let @/ = ''   .. expand('<cword>')        <CR>N
" }}}

" 缓冲 窗口 标签 {{{
" 其实我平常不用标签，缓冲为主

" <C-J> <C-K> 切换缓冲前进后退
noremap <silent> <C-J> :bprev<CR>
noremap <silent> <C-K> :bnext<CR>

" 新窗口默认打开在右侧、下方
set splitbelow
set splitright
" 使用 Alt+HJKL 切换窗口
nnoremap <Esc>h <C-W>h
nnoremap <Esc>j <C-W>j
nnoremap <Esc>k <C-W>k
nnoremap <Esc>l <C-W>l

" 删除当前缓冲并打开前一个缓冲
noremap <silent> <Leader>q :call DeleteCurrentBuffer()<CR>

" 删除当前缓冲并打开前一个缓冲（或跳转如果已经在另一个窗口打开）
" 如果当前缓冲未在缓冲列表中，一般是插件打开的临时窗口，直接关闭窗口
" TODO: 考虑缓冲在多个标签中打开的影响
function! DeleteCurrentBuffer()
  let bcurr = getbufinfo('%')[0]
  " 如果当前缓冲有未保存的修改则阻止删除
  if bcurr.changed
    let fname = fnameescape(bufname(bcurr.bufnr))
    throw 'No write since last change for buffer "' .. fname .. '"'
  endif
  " 如果没有在列表里，一般是插件打开的窗口，直接关掉
  if !bcurr.loaded || !bcurr.listed || empty(bcurr.name)
    bdelete | return
  endif

  " 如果缓冲在多个窗口中打开
  " 关闭当前窗口并跳转到同缓冲的前一个窗口中
  if len(bcurr.windows) != 1
    let winid = win_getid()
    for index in range(len(bcurr.windows))
      if bcurr.windows[index] == winid | break | endif
    endfor
    let wcurr = win_id2win(winid)
    let wprev = win_id2win(bcurr.windows[index - 1])
    execute wprev .. 'wincmd w'
    execute wcurr .. 'close'
    return
  endif

  " 获取列表（列表中的都是可见的）
  let blist = getbufinfo({'buflisted': 1, 'bufloaded': 1})
  " 如果列表中只有自己，直接退出 vim
  if len(blist) == 1 | quit | return | endif

  " 这里的循环是为了找到列表中的前一项并切换当前窗口到该缓冲
  " index 结果为 0 也无妨，下标为 -1 会选中最后一项
  for index in range(len(blist))
    if blist[index].bufnr == bcurr.bufnr | break | endif
  endfor
  " 若前一项已经在另一个窗口打开，则直接跳转到该窗口
  let bprev = blist[index - 1]
  if len(bprev.windows) | close | endif
  execute 'buffer ' .. bprev.bufnr | bdelete #
endfunction
" }}}

" 保存 {{{
noremap <silent> <Leader>w :update<CR>

" 没啥用的废物
set backupdir=/tmp/vim/bkup//
set directory=/tmp/vim/swap//

" 使用 root 权限强制覆写文件（需要输入密码）
" FIXME: Neovim 不支持，会直接失败
" https://github.com/neovim/neovim/issues/12103
command W w !sudo tee % > /dev/null
" }}}

" 插件配置

" Airline {{{
let g:airline_powerline_fonts = 1
let g:airline_theme = 'gruvbox'

let g:airline#parts#ffenc#skip_expected_string = 'utf-8[unix]'

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

let g:airline#extensions#coc#enabled = 1
" }}}

" Conquer of Completion {{{
let g:coc_config_home = '~/.vim'

set cmdheight=2
set updatetime=500

" 补全
" 按下 tab 时，若补全列表已经打开 pumvisible() 则候选项跳到下一条
" 若未打开，当光标左侧字符不是空白字符则弹出新的补全窗口，否则正常缩进
inoremap <silent><expr> <Tab>   pumvisible() ? '<C-N>' : <SID>CheckBackSpace() ? '<Tab>' : coc#refresh()
" shift+tab 在补全中候选项往上移动
inoremap <silent><expr> <S-Tab> pumvisible() ? '<C-P>' : '<S-Tab>'
function! <SID>CheckBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <CR> pumvisible() ? coc#_select_confirm() : '<C-G>u<CR><C-R>=coc#on_enter()<CR>'

" 使用 <Leader>, <Leader>. 在错误提示间跳转
nmap <silent> <Leader>, <Plug>(coc-diagnostic-prev)
nmap <silent> <Leader>. <Plug>(coc-diagnostic-next)
" K 展示代码文档
" vim 原来的 K 映射到了打开 man 手册上，现在含义不变，由 LSP 接管
nnoremap <silent> K :call <SID>ShowDocumentation()<CR>
function! <SID>ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" 光标静止在标识符上的时候自动高亮文档内同名标识符
autocmd CursorHold * silent! call CocActionAsync('highlight')

" 格式化，不过我开了保存时自动格式化，这个基本用不着
nnoremap <silent> <Leader>= <Plug>(coc-format)
" 跳转定义
nnoremap <silent> <Leader>d <Plug>(coc-definition)
" 跳转类型
nnoremap <silent> <Leader>y <Plug>(coc-type-definition)
" 跳转实现
nnoremap <silent> <Leader>i <Plug>(coc-implementation)
" 跳转引用
nnoremap <silent> <Leader>r <Plug>(coc-references)
" 快速修复
nnoremap <silent> <Leader>f <Plug>(coc-fix-current)
" code actions
nnoremap <silent> <Leader>a <Plug>(coc-codeaction-line)
" code lens
nnoremap <silent> <Leader>l <Plug>(coc-codelens-action)
" 重构
" nnoremap <silent> <Leader>rn <plug>(coc-rename)
nnoremap <silent> <Leader>rn <Plug>(coc-refactor)
" }}}

" Vim-Devicons {{{
" 重新加载会导致 NERDTree 失去高亮，而且图标周围出现不明 [] 
" 需要刷新一下
if exists("g:loaded_webdevicons")
  call webdevicons#refresh()
endif
" }}}

" NERDTree {{{
noremap <silent> <leader>t :NERDTree<cr>
" }}}

" Fugitive {{{
noremap <silent> <leader>ga :Git add % <bar> qa<cr>
noremap <silent> <leader>gb :Git blame<cr>
" }}}

" vim: foldmethod=marker
