set noexpandtab
set tabstop=4
set shiftwidth=4
set softtabstop=-1

" TODO: 使用 "foldexpr" 重构
if has('folding') && !&diff
  " 折叠所有 err != nil 形式的代码块
  augroup error-not-nil
    autocmd!
    " 找到 err != nil 所在的行
    " $ 移动光标到左大括号
    " va{ 选中整个大括号对（语句块）内容
    " zf 折叠这几行
    " 因为 normal! 后面的指令包含 { 会破坏 vim 高亮，所以用 execute
    autocmd BufWinEnter *.go silent execute 'normal! zR'
    autocmd BufWinEnter *.go silent execute 'g/if err != nil /normal! $va{zf'
    autocmd BufWinEnter *.go silent execute 'g/; err != nil /normal! $va{zf'
    autocmd BufWinEnter *.go silent normal! gg0
  augroup end

  setlocal fillchars+=fold:\ 
  setlocal foldtext=FoldText()

  " 获取返回列表的最后一项目，按逗号分隔列表
  " 主要处理逻辑是排除引号、括号中的逗号
  function! ParseLastReturnElement(returnline)
    let pair = {')': '(', ']': '[', '}': '{'}
    let stack = [ ]  " 括号栈，用来判断下一个逗号是否是 return 的参数
    let chars = split(a:returnline, '\zs')
    let inside = 0  " 当前指针在字符串字面量里面
    let escape = 0  " 当前指针在字符串字面量中且为转义字符
    let result = []
    for index in range(len(chars))
      let char = chars[index]
      " 逗号本身处理
      if char ==# ','
        " 如果栈非空，说明目前的逗号在引号、括号里，跳过
        " 否则碰到逗号说明接下来是新的返回参数列表
        " 因为这里只取最后一项，所以清空前面的结果
        if empty(stack) | let result = [] | endif
      " 引号
      elseif !escape && stridx("'\"", char) != -1 " 字符串
        if len(stack) && stack[-1] ==# char
          " 上一个字符也是引号，退出引号范围，inside 置 false
          let inside = 0 | let stack = stack[:-2]
        else
          let inside = 1 | call add(stack, char)
        endif
      " 转义字符
      elseif inside && char ==# '\'
        let escape = 1
      " 左括号
      elseif !inside && stridx('([{', char) != -1
        call add(stack, char)
      " 右括号
      elseif !inside && stridx(')]}', char) != -1
        if pair[stack[-1]] != char
          return ''   " 这里括号不匹配，就不勉强解析了
        endif
        let stack = stack[:-2]  " 弹出匹配的左括号
      endif
      " 把结果暂存起来
      if len(stack) || char !=# ',' | call add(result, char) | endif
      " 经过一个字符就可以退出转义，即使是 \xhh \uXXXX 也不影响后续逻辑
      if char !=# '\' | let escape = 0 | endif
    endfor
    return substitute(join(result, ''), '^return ', '', '')
  endfunction

  function! ReacheableWindowWidth()
    let width = winwidth(0)             " 窗口长度
    let width = width - &foldcolumn     " foldcolumn
    if &number || &relativenumber
      let width = width - &numberwidth  " 行号数字长度
    endif
    " 计算 signcolumn 占据的宽度，即错误提示符占据的宽度
    redir => signlist
      execute 'silent! sign place buffer=' . bufnr('')
    redir end
    if len(split(signlist, '\n')) > 1
      let width = width - 2             " 目前看起来 signcol 的长度都是 2
    endif
    return width
  endfunction

  " FIXME: 没法忽略掉注释中的 if err != nil 
  " 折叠信息显示错误原因和返回值，如果还放得下则在最右侧显示行号
  function! FoldText()
    let indent = repeat(' ', indent(v:foldstart))
    let iferrline = getline(v:foldstart)
    let reason = matchstr(iferrline, 'if [^{]*')
    if empty(reason)  " 有可能是多行 if
      let reason = matchstr(iferrline, '.*[^{]')
    endif
    let reason = trim(reason)
    let handle = filter(getline(v:foldstart, v:foldend), 'v:val =~# "^\\s*return"')
    if len(handle)
      # FIXME: 没考虑 return 占据多行的情况
      let handle = trim(handle[-1])
    else
      let handle = ''
    endif
    " ljust 会被放置在屏幕左侧，嵌入到代码中
    let ljust = indent . reason . ': ⤴ ' . ParseLastReturnElement(handle)
    " 计算折叠行数，放置到屏幕右侧（如果能放得下）
    let lines = v:foldend - v:foldstart + 1
    let rjust = printf(' -- %d lines -- ', lines)
    let remain = ReacheableWindowWidth()
    let remain = remain - strlen(ljust) + 2        " ljust 长度（+2 是因为有个特殊符号⤴ ，FIXME: vim 和 nvim 在这里表现不同）
    let remain = remain - strlen(rjust)            " rjust 长度
    if remain >= 0
      return ljust . repeat(' ', remain) . rjust
    endif
    return ljust
  endfunction
endif
