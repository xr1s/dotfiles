# 代理是头等大事 {{{
if uname -r | grep --ignore-case --quiet microsoft
then
  # 初始化 WSL2 代理
  export HOSTALIASES="$HOME/.local/etc/hosts"
  WINDOWS=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
  git config --global http.proxy $WINDOWS:10809
  git config --global https.proxy $WINDOWS:10809
  # TODO: 使用 sed 的 c 命令
  sed -i "s:^windows.*$:windows $WINDOWS:g" "$HOSTALIASES"
  PROXYHOST=$WINDOWS
else
  PROXYHOST='localhost'
fi
function proxy() {
  if [[ $1 == 'off' ]]
  then
    unset http_proxy https_proxy socks5_proxy
  else
    export http_proxy=http://$PROXYHOST:10809
    export https_proxy=http://$PROXYHOST:10809
    export socks5_proxy=socks5://$PROXYHOST:10808
  fi
}  # }}}

# 路径初始化 {{{
# 映射 : 分隔的字符串格式路径到数组形式，方便后续操作
typeset -TUx PATH               path=("$HOME/.local/bin" $path)
typeset -TUx CPATH              include_path
typeset -TUx LD_LIBRARY_PATH    library_path
typeset -TUx LD_RUN_PATH        library_path
typeset -TUx LIBRARY_PATH       library_path
typeset -TUx MANPATH            manpath=('/usr/share/man' $manpath)
typeset -TUx INFOPATH           infopath
typeset -TUx PKG_CONFIG_PATH    pkg_config_path
typeset -TUx ACLOCAL_PATH       aclocal_path
typeset -TUx TCLLIBPATH         tcllibpath
# CMAKE_PREFIX_PATH 使用 ; 做分隔符
typeset -TUx CMAKE_PREFIX_PATH  prefix_path \;
export OPENSSLDIR="$HOME/.local/ssl"
export SSL_CERT_DIR="$HOME/.local/ssl/certs"
export LC_ALL=en_US.UTF-8
export TERM=xterm-256color

# packages 里保存已安装的包路径名
# 这里用 Gentoo 的分类做整理，后续可能会修改
packages=(
  # dev-db
  sqlite
  # dev-lang
  tcl
  cpython
  go
  # dev-cpp
  fmt
  oneTBB
  range-v3
  # dev-java
  openjdk-19-ea+20
  # dev-libs
  boost
  fmt
  gmp
  isl
  libexpat
  libffi
  libgit2
  libuv
  mpc
  mpfr
  openssl
  pcre2
  protoc-3.20.0
  zlog
  # dev-utils
  ccls
  cmake-3.23.0
  # app-arch
  bzip2
  gzip
  xz
  zstd
  # app-editors
  nvim-0.6.1
  # sci-libs
  lapack
  # sys-devel
  binutils-gdb
  gcc
  llvm-project
  # sys-libs
  gdbm
  ncurses
  readline
  zlib
  # sys-libs
  htop
)

function() {
  # 手动安装的软件，在 $OPT 下分目录隔离安装
  local OPT=$HOME/.local/opt
  local -A VAR_DIRS=(
    path            'bin sbin'
    include_path    'include'
    library_path    'lib lib64'
    manpath         'share/man man'
    infopath        'share/info'
    pkg_config_path 'lib/pkgconfig'
    aclocal_path    'share/aclocal'
    tcllibpath      'share/tcltk'
  )
  local pkg var dirs dir

  for pkg in $packages; do
    if [[ -d $OPT/$pkg ]]; then
      for var dirs in ${(kv)VAR_DIRS}; do
        for dir in $=dirs
          [[ -d $OPT/$pkg/$dir ]] && eval $var+=\($OPT/$pkg/$dir\)
      done
      prefix_path+=($OPT/$pkg)
    else
      print -P "%F{yellow}%B$pkg%b not found%f"
    fi
  done
}  # }}}

# 各应用自定义环境变量 {{{
# Vim
export MYVIMRC='~/.vimrc'
export VIMINIT='set runtimepath^=~/.vim | source $MYVIMRC'
# Rust
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
if (( $+commands[rustup] )); then
  RUSTC_SYSROOT_FPATH="$(rustc --print sysroot)/share/zsh/site-functions"
  if [[ ! -f "$RUSTC_SYSROOT_FPATH/_rustup" ]]
    rustup completions zsh rustup > "$RUSTC_SYSROOT_FPATH/_rustup"
fi
# Haskell
[[ -s "$HOME/.ghcup/env" ]] && source "$HOME/.ghcup/env"
alias ghci='ghci -interactive-print=Text.Pretty.Simple.pPrint'
# Go
if (( $+commands[go] )); then
  export GOPATH="$HOME/.go"
  path+=("$GOPATH/bin")
fi
# Java
if (( $+commands[java] )); then
  export JAVA_HOME="${$(which java)%/bin/java}"
fi
# Perl
path+=("$HOME/.local/lib/site_perl/bin")
manpath+=("$HOME/.local/lib/site_perl/man")
# }}}

# zsh 交互模式配置 {{{
# zshoptions {{{
setopt EXTENDED_HISTORY        # 保存历史命令的开始和执行时间
setopt HIST_EXPIRE_DUPS_FIRST  # 当命令历史超出上限时，首先删除历史中的重复项（而非从头开删）
setopt HIST_FCNTL_LOCK         # 使用 fcntl 系统调用优化性能（Linux >=3.15）
setopt HIST_FIND_NO_DUPS       # 使用历史搜索功能时不显示重复项
setopt HIST_IGNORE_ALL_DUPS    # 新输入的命令已经存在在历史中时删去旧条目
setopt HIST_IGNORE_SPACE       # 不将前缀空格的命令写入历史（方便用来输入一些密码等）
setopt HIST_SAVE_NO_DUPS       # 功能上和 HIST_IGNORE_ALL_DUPS 一样（看了源码），可能和一些初始化顺序有关
setopt INC_APPEND_HISTORY      # 不用等待 zsh 退出，命令开始执行便及时追加到历史
setopt SHARE_HISTORY           # 多终端之间共享历史（该选项会开启 INC_APPEND_HISTORY）
setopt INTERACTIVE_COMMENTS    # 允许在交互模式使用注释（便于复制粘贴大段命令）
# }}}
# zshparams {{{
HISTFILE=~/.zsh_history                               # 历史命令储存文件
HISTORY_IGNORE='(cd|cd *|ls|ls *)'                    # cd ls 等常见命令不追加历史
HISTSIZE=200000                                       # 启动时加载历史数量
SAVEHIST=100000                                       # 文件储存历史数量
WORDCHARS=''                                          # 只有字母数字作为一个单词
(( $+commands[vivid] )) \
  && export LS_COLORS=$(vivid generate gruvbox-dark)  # 直接生成 LS_COLORS（dircolors 无法处理 di 和 *.di 同时存在的情况，可能是缺陷）
export EDITOR='nvim'
# }}}
# zshmisc {{{
# FIXME: 会导致变量赋值和前缀变量赋值的命令被过滤
#function zshaddhistory() {  # 内置钩子函数
#  # 简介：不追加系统中不存在的命令到命令历史中，用于过滤输入错误的命令
#  # 考虑到可能存在忘记安装软件，后续仍然需要记忆该历史的情况，返回 2 先缓存历史于内存中
#  # $1 就是新输入的命令，这里使用 eval 来做简单语法解析（为了处理 arg0 中含有空格这类极端情况）
#  # 为了防止 ; 导致 eval 出两条语句，替换 ; 为 \;，再加上 noglob 防止特殊字符在 eval 中被展开
#  eval noglob set -- ${1//;/\\;}
#  # command -v 可以判断 zsh 内置命令、函数等，$+commands 只支持可执行文件
#  # command -v 也会识别 then done fi esca 等这类出现在开头也是语法错误的关键字，不过应当影响不大
#  command -v $1 > /dev/null && return 0 || return 2
#}
# }}}
# zshmodules {{{
zmodload zsh/complist  # 补全菜单功能和控制
# }}}
# zshzle {{{
bindkey -e                                              # Emacs 键位
bindkey "$key[Up]"   history-beginning-search-backward  # 上键向前搜索命令
bindkey "$key[Down]" history-beginning-search-forward   # 下键向后搜索命令
bindkey '^P' history-beginning-search-backward          # C-P 向前搜索命令
bindkey '^N' history-beginning-search-forward           # C-N 向后搜索命令
bindkey -M menuselect '^[[Z' reverse-menu-complete      # 补全菜单 S-Tab 选择上一条

autoload -z edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line                        # C-X C-E 进入编辑器编辑模式

function expand-dots() {
  # 当光标左侧的内容包含连续三个以上点时候，递归执行替换 ... ->  ../..
  # :f 参考 zshexpn 的 Modifiers 一节，作用是反复执行后面的操作直到结果不再变化
  # s:\.\.\.:../.. 就是一个正则替换
  [[ $LBUFFER =~ '\.\.\.+' ]] && LBUFFER=$LBUFFER:fs:\.\.\.:../..
}

function expand-dots-then-expand-or-complete() {
    zle expand-dots
    zle expand-or-complete
}

function expand-dots-then-accept-line() {
    zle expand-dots
    zle accept-line
}

zle -N expand-dots
zle -N expand-dots-then-expand-or-complete
zle -N expand-dots-then-accept-line
bindkey '^I' expand-dots-then-expand-or-complete
bindkey '^M' expand-dots-then-accept-line
# }}}
# zshcompsys {{{
autoload -U compinit && compinit                           # 初始化补全
zstyle    ':completion:*' list-colors                     `# 补全菜单高亮` \
  "${(s.:.)LS_COLORS}"                                    `# 文件高亮采用 LS_COLORS 配置`
zstyle    ':completion:*' matcher-list                    `# TODO: 拼音匹配中文` \
  ''                                                      `# 1.  优先默认前缀匹配`  \
  '+m:{[:lower:]}={[:upper:]}'                            `#     同时允许输入小写匹配到大写` \
  '+m:{_-}={-_}'                                          `#     同时 _ 和 - 可以互相匹配` \
  '+r:|[._-]=*'                                           `#     同时按 ._- 分段分别匹配` \
  'l:|=* r:|=*'                                           `# 2.  其次子串匹配` \
  '+m:{[:lower:]}={[:upper:]}'                            `#     同时允许输入小写匹配到大写` \
  '+m:{_-}={-_}'                                          `#     同时 _ 和 - 可以互相匹配` \
  '+r:|[._-]=*'                                           `#     同时按照 ._- 分段分别匹配`
zstyle    ':completion:*' format '%F{yellow}%B%U%d%b%u%f' `# 高亮显示每块的补全类型（如目录、选项等）`
zstyle    ':completion:*' menu select                     `# 补全无条件展示选择菜单（没有最少长度要求）`
zstyle -e ':completion:*' special-dirs                    `# 默认情况下特殊路径 .. 不会被补全为 ../` \
  '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)'           `# 仅当前缀全为 ../ 或除前缀外只输入了 . .. 才允许补全为 ../`
zstyle    ':completion:*' use-cache on                    `# 开启缓存，用于优化慢速补全命令（如 gradle）`
zstyle    ':completion:*' cache-path \
  "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
# }}}
# }}}

# zinit 插件 {{{
# Zinit 自安装脚本（zinit 自己生成的，就不删了）
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit && (( ${+_comps} )) && _comps[zinit]=_zinit
# 提示符插件需要阻塞载入
zinit ice src"$HOME/.p10k.zsh"
zinit light romkatv/powerlevel10k
# 只要输入 make 就会试图解析 Makefile 并高亮，遇到复杂文件会直接导致命令行挂死，所以在载入时取消 make 的高亮
zinit wait lucid for \
  atload'unset FAST_HIGHLIGHT\[chroma-make\]' \
  zdharma-continuum/fast-syntax-highlighting \
  pick'bin/rbenv' as'program' atload'eval "$(bin/rbenv init - zsh)"' \
  rbenv/rbenv \
  pick'bin/ruby-build' as'program' \
  rbenv/ruby-build
# 通用补全脚本
zinit wait lucid as'completion' for \
  mv'838a7f1b39e81ee0c06cfa959e6e97f6152019b04e10aab719c6fb118b415253 -> _fossil' \
  https://fossil-scm.org/home/raw/838a7f1b39e81ee0c06cfa959e6e97f6152019b04e10aab719c6fb118b415253 \
  https://github.com/BurntSushi/ripgrep/blob/master/complete/_rg \
  https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker \
  https://github.com/gradle/gradle-completion/blob/master/_gradle \
  https://github.com/mesonbuild/meson/blob/master/data/shell-completions/zsh/_meson \
  mv'zsh-completion -> _ninja' \
  https://github.com/ninja-build/ninja/blob/master/misc/zsh-completion \
  https://github.com/ogham/exa/blob/master/completions/zsh/_exa \
  https://github.com/rust-lang/cargo/blob/master/src/etc/_cargo \
  as'program' atclone'sed "s:{{PROJECT_EXECUTABLE}}:bat:g" bat.zsh.in > _bat' atpull'%atclone' \
  https://github.com/sharkdp/bat/blob/master/assets/completions/bat.zsh.in \
  https://github.com/sharkdp/fd/blob/master/contrib/completion/_fd \
  https://github.com/zsh-users/zsh-completions/blob/master/src/_bundle \
  https://github.com/zsh-users/zsh-completions/blob/master/src/_cmake \
  https://github.com/zsh-users/zsh-completions/blob/master/src/_golang \
  https://github.com/zsh-users/zsh-completions/blob/master/src/_openssl \
  mv'zsh_completion -> _hg' \
  https://www.mercurial-scm.org/repo/hg/raw-file/tip/contrib/zsh_completion \
  OMZP::pip OMZP::pip/_pip \
  OMZP::gem/_gem \
  OMZP::rails/_rails \
  OMZP::nvm/_nvm
# 本地补全脚本
[[ -f "$RUSTC_SYSROOT_FPATH/_rustup" ]] \
  && zinit wait lucid as'completion' for "$RUSTC_SYSROOT_FPATH/_rustup"
# systemd 补全脚本
# 可能是版本问题，systemctl 不支持补全脚本中的 --legend=no，因此手动替换成 --no-legend
(( $+commands[systemctl] )) && zinit wait lucid as'completion' for \
  https://github.com/systemd/systemd/blob/main/shell-completion/zsh/_journalctl \
  as'program' atclone'sed -i"" -e"s:{{ROOTLIBEXECDIR}}/::g" -e"s:--legend=no:--no-legend:g" _systemctl.in' atpull'%atclone' \
  https://github.com/systemd/systemd/blob/main/shell-completion/zsh/_systemctl.in
# }}}

# 自定义脚本 {{{
(( $+commands[exa] )) && alias ls='exa --time-style=long-iso --header --long --binary'
alias hl='bat --style=plain --paging=never'
alias view="vim -R '+set nomodifiable'"
if uname -r | grep --ignore-case --quiet microsoft
then
  alias open='explorer.exe'
fi

# Android 开发用，似乎和 llvm-project 的链接库冲突，所以需要手动开启
function android-dev() {
  export ANDROID_HOME="$HOME/.local/opt/android-sdk"
  path=(${path:#*/llvm-project/*})
  library_path=(${library_path:#*/llvm-project/*})
  incluce_path=(${library_path:#*/llvm-project/*})
  path+=(
    "$ANDROID_HOME/cmdline-tools/latest/bin"
    "$ANDROID_HOME/build-tools/32.0.0"
    "$ANDROID_HOME/platform-tools"
  )
}

function highlight-log() {
  # https://ant.design/docs/spec/colors
  # Fatal  -> red-8
  # Error  -> red-5
  # Warn   -> gold-5
  # Notice -> lime-5
  # Info   -> green-5
  # Debug  -> megenta-5
  # Trace  -> blue-5
  awk -v IGNORECASE=1 \
    '{ gsub(/\033\[[0-9;]*?\w/, "") }
    /^Fatal\>|"level":"fatal"|level=fatal/    { print "\033[38;2;168;7;26m"   $0 "\033[0m"; next }
    /^Error\>|"level":"error"|level=error/    { print "\033[38;2;255;77;79m"  $0 "\033[0m"; next }
    /^Warn\>|"level":"warning"|level=warn/    { print "\033[38;2;255;197;61m" $0 "\033[0m"; next }
    /^Notice\>|"level":"notice"|level=notice/ { print "\033[38;2;186;230;37m" $0 "\033[0m"; next }
    /^Info\>|"level":"info"|level=info/       { print "\033[38;2;115;209;61m" $0 "\033[0m"; next }
    /^Debug\>|"level":"debug"|level=debug/    { print "\033[38;2;247;89;171m" $0 "\033[0m"; next }
    /^Trace\>|"level":"trace"|level=trace/    { print "\033[38;2;64;169;255m" $0 "\033[0m"; next }
    1'
}
# vim: foldmethod=marker
