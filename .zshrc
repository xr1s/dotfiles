# 代理是头等大事 {{{
function proxy() {
  if [[ $1 == 'off' ]]
  then
    unset http_proxy https_proxy socks_proxy no_proxy
    unset HTTP_PROXY HTTPS_PROXY SOCKS_PROXY NO_PROXY
  else
    export http_proxy="http://localhost:7897"
    export https_proxy="http://localhost:7897"
    export socks_proxy="socks5://localhost:7897"
  fi
}  # }}}

# 路径初始化 {{{
# 映射 : 分隔的字符串格式路径到数组形式，方便后续操作
export -U  PATH               path=("$HOME/.local/bin" $path)
export -UT CPATH              include_path
export -UT LIBRARY_PATH       library_path
export -UT LD_LIBRARY_PATH    ld_library_path
export -U  MANPATH            manpath=('/usr/share/man' $manpath)
export -UT INFOPATH           infopath
export -UT PKG_CONFIG_PATH    pkg_config_path
export -UT ACLOCAL_PATH       aclocal_path
export -UT TCLLIBPATH         tcllibpath
export -UT CMAKE_PREFIX_PATH  prefix_path \;  # CMAKE_PREFIX_PATH 使用 ; 做分隔符

# packages 里保存手动安装的包路径名
packages=()

function() {
  # 手动安装的软件，在 $OPT 下分目录隔离安装
  local OPT="$HOME/.local/opt"
  # TODO: 自动探测目标三元组
  local -A VAR_DIRS=(
    path            'bin sbin'
    include_path    'include'
    library_path    'lib lib64 lib/x86_64-unknown-linux-gnu'
    ld_library_path 'lib lib64 lib/x86_64-unknown-linux-gnu'
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
          [[ -d $OPT/$pkg/$dir ]] && eval $var="($OPT/$pkg/$dir \$$var)"
      done
      prefix_path+=($OPT/$pkg)
    else
      print -P "%F{yellow}%B$pkg%b not found%f"
    fi
  done
}  # }}}

# 各应用环境变量 {{{
function create-completion-placeholders() {
  # 对于一些需要动态生成补全脚本的命令，这里只生成占位符，放到后面在 zinit「本地补全脚本」部分初始化
  # 不直接在此 source 补全脚本的原因是因为此时还没 autoload compinit && compinit，我不想打乱 zshrc 顺序
  # 而之所以留空不直接生成补全内容，是为了在二进制更新补全脚本后能及时生效，否则只是判断文件存在就不会更新了
  # 不每次都在这儿生成一遍补全是因为生成补全默认是阻塞的，想利用 zinit 的 turbo 模式异步初始化
  # 不过老实说我不清楚 turbo 模式在执行生成补全命令的时候能不能起作用，如果可以最好（感觉不行，那就算了）
  local ZSH_LOCAL_FPATH="$HOME/.local/share/zsh/functions/Completion"
  [[ ! -d $ZSH_LOCAL_FPATH ]] && rm -f $ZSH_LOCAL_FPATH && mkdir -p $ZSH_LOCAL_FPATH
  for bin in "$@"; do
    if (( $+commands[$bin] )) && [[ ! -f "$ZSH_LOCAL_FPATH/_$bin" ]]; then
      rm -rf "$ZSH_LOCAL_FPATH/_$bin" && : > "$ZSH_LOCAL_FPATH/_$bin"
    fi
  done
}
# Android {{{
if [[ -d "$HOME/.local/opt/android-sdk" ]]; then
  export ANDROID_HOME="$HOME/.local/opt/android-sdk"
  [[ -d "$ANDROID_HOME/cmdline-tools/latest/bin" ]] && path+=($ANDROID_HOME/cmdline-tools/latest/bin)
  [[ -d "$ANDROID_HOME/build-tools" ]] && path+=($ANDROID_HOME/build-tools/*)
  [[ -d "$ANDROID_HOME/emulator" ]] && path+=($ANDROID_HOME/emulator)
  [[ -d "$ANDROID_HOME/platform-tools" ]] && path+=($ANDROID_HOME/platform-tools)
fi
# }}}
# Autotools {{{
(( $+commands[m4] )) && export M4="$commands[m4]"
# }}}
# Go {{{
if (( $+commands[go] )); then
  export GOPATH="$HOME/.go"
  path=("$GOPATH/bin" $path)
fi
# }}}
# Haskell {{{
[[ -s "$HOME/.ghcup/env" ]] && source "$HOME/.ghcup/env"
# }}}
# Homebrew {{{
if [[ $(uname) == 'Darwin' ]]; then
  export HOMEBREW_NO_AUTO_UPDATE=1
  export HOMEBREW_NO_ANALYTICS=1
  case $(uname -m) in
    x86_64) HOMEBREW=/usr/local/homebrew;;
    arm64)  HOMEBREW=/opt/homebrew;;
  esac
  export HOMEBREW_PREFIX=$HOMEBREW
  export HOMEBREW_CELLAR=$HOMEBREW/Cellar
  export HOMEBREW_REPOSITORY=$HOMEBREW
  path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" $path)
  manpath+=("$HOMEBREW_PREFIX/share/man")
  infopath+=("$HOMEBREW_PREFIX/share/info")
  unset HOMEBREW
fi
# }}}
# Kubernetes {{{
create-completion-placeholders kubectl kubeadm minikube helm
# }}}
# OpenSSL {{{
export OPENSSLDIR="$HOME/.local/opt/openssl"
export SSL_CERT_DIR='/etc/ssl/certs'
# }}}
# Perl {{{
path+=("$HOME/.local/lib/site_perl/bin")
manpath+=("$HOME/.local/lib/site_perl/man")
# }}}
# Python {{{
create-completion-placeholders pdm
# }}}
# Rust {{{
[[ -d "$HOME/.cargo/bin" ]] && path=("$HOME/.cargo/bin" $path)
create-completion-placeholders rustup rg
# }}}
# SDKMAN {{{
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && : > "$HOME/.local/share/zsh/functions/Completion/_sdk"
# }}}
# Vim {{{
export MYVIMRC="$HOME/.vimrc"
export VIMINIT="source $MYVIMRC"
# }}}
# Zinit {{{
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit && (( ${+_comps} )) && _comps[zinit]=_zinit
# }}}
unfunction create-completion-placeholders
# }}}

# zsh 交互模式配置 {{{
# 按照 zsh 的 man 手册分类放置内容
# 举个例子
# 想了解 EXTENDED_HISTORY 可以直接 man zshoptions
# 想了解 zshaddhistory 可以直接 man zshparams
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
HISTORY_IGNORE='(cd|cd *|ls|ls *|:q|q)'               # cd ls 等常见命令不追加历史
HISTSIZE=20000                                        # 启动时加载历史数量
SAVEHIST=10000                                        # 文件储存历史数量
WORDCHARS=''                                          # 只有字母数字作为一个单词
(( $+commands[vivid] )) \
  && export LS_COLORS=$(vivid generate gruvbox-dark)  # 直接生成 LS_COLORS（dircolors 无法处理 di 和 *.di 同时存在的情况，可能是缺陷）
export EDITOR='nvim'
# }}}
# zshmisc {{{
function _zshaddhistory() {
  # 简介：不追加系统中不存在的命令到命令历史中，用于过滤输入错误的命令
  # 考虑到可能存在忘记安装软件，后续仍然需要记忆该历史的情况，返回 2 先缓存历史于内存中
  # $1 就是新输入的命令，这里使用 eval 来做简单语法解析（为了处理 arg0 中含有空格这类极端情况）
  # 为了防止一些关键字导致 eval 出两条语句，替换 ; 为 \; 等，noglob 防止特殊字符在 eval 中被展开
  eval noglob set -- $(sed -E 's:[;&|<>{}\\]:\\\0:g' <<< ${1//function/})
  # 过滤前缀的变量定义，shift 直到拿到第一个不带等号的作为 arg0
  # FIXME: 考虑 arg0 中带有等号的情况
  # 不过这情况不好处理，目前看起来是把写出 arg0 中带等号的代码的人揍一顿效率比改代码更高
  # 虽然至今没有碰到过，但是 arg0 中带等号也是合法的，两边加上引号可以像正常命令一样调用
  # 只是由于前面 eval 之后引号都丢失了，所以变量定义和 arg0 中带引号混在一起就识别不了了
  while (( $#@ )) && [[ $1 =~ '^[_a-zA-Z]\w*=' ]] { shift }
  # command -v 可以判断 zsh 内置命令、函数等，$+commands 只支持可执行文件
  # command -v 也会识别 then done fi esca 等这类出现在开头也是语法错误的关键字，不过应当影响不大
  { (( $#@ == 0 )) || command -v $1 } > /dev/null && return 0 || return 2
}
# }}}
# zshmodules {{{
zmodload zsh/complist  # 补全菜单功能和控制
# }}}
# zshbuiltin {{{
autoload compinit
autoload edit-command-line
# }}}
# zshzle {{{
zle -N edit-command-line

bindkey -e                                              # Emacs 键位
bindkey -- "$key[Up]"   history-beginning-search-backward  # 上键向前搜索命令
bindkey -- "$key[Down]" history-beginning-search-forward   # 下键向后搜索命令
bindkey -- '^P' history-beginning-search-backward          # C-P 向前搜索命令
bindkey -- '^N' history-beginning-search-forward           # C-N 向后搜索命令
bindkey -- '^H' backward-kill-word                         # C-Backspace 删除上一个单词
bindkey -M menuselect '^[[Z' reverse-menu-complete         # 补全菜单 S-Tab 选择上一条
bindkey '^X^E' edit-command-line                           # C-X C-E 进入编辑器编辑模式

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
compinit                                                   # 初始化补全
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
# 提示符插件需要阻塞载入
zinit lucid for \
  src"$HOME/.p10k.zsh" \
  romkatv/powerlevel10k
# 只要输入 make 就会试图解析 Makefile 并高亮，遇到复杂文件会直接导致命令行挂死，所以在载入时取消 make 的高亮
zinit wait lucid for \
  OMZP::pip \
  pick'bin/rbenv' as'program' wait'[[ -f Gemfile ]]' atload'eval "$(bin/rbenv init - zsh)"' \
  rbenv/rbenv \
  pick'bin/ruby-build' as'program' \
  rbenv/ruby-build \
  atload'unset FAST_HIGHLIGHT\[chroma-make\]
    FAST_HIGHLIGHT_STYLES[defaulthere-string-text]=fg=blue' \
  zdharma-continuum/fast-syntax-highlighting
# 通用补全脚本
zinit wait lucid as'completion' for \
  mv'838a7f1b39e81ee0c06cfa959e6e97f6152019b04e10aab719c6fb118b415253 -> _fossil' \
  https://fossil-scm.org/home/raw/838a7f1b39e81ee0c06cfa959e6e97f6152019b04e10aab719c6fb118b415253 \
  https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker \
  as'program' atclone'compdef _gradle gradle gradlew' atpull'%atclone' \
  https://github.com/gradle/gradle-completion/blob/master/_gradle \
  https://github.com/mesonbuild/meson/blob/master/data/shell-completions/zsh/_meson \
  mv'zsh-completion -> _ninja' \
  https://github.com/ninja-build/ninja/blob/master/misc/zsh-completion \
  https://github.com/eza-community/eza/blob/main/completions/zsh/_eza \
  https://github.com/rust-lang/cargo/blob/master/src/etc/_cargo \
  as'program' atclone'sed "s:{{PROJECT_EXECUTABLE}}:bat:g" bat.zsh.in > _bat' atpull'%atclone' \
  https://github.com/sharkdp/bat/blob/master/assets/completions/bat.zsh.in \
  https://github.com/sharkdp/fd/blob/master/contrib/completion/_fd \
  atload'source register-completions.zsh' \
  https://github.com/xmake-io/xmake/blob/master/xmake/scripts/completions/register-completions.zsh \
  https://github.com/zsh-users/zsh-completions/blob/master/src/_bundle \
  https://github.com/zsh-users/zsh-completions/blob/master/src/_cmake \
  https://github.com/zsh-users/zsh-completions/blob/master/src/_golang \
  https://github.com/zsh-users/zsh-completions/blob/master/src/_openssl
# 本地补全脚本
function() {
  local ZSH_LOCAL_FPATH="$HOME/.local/share/zsh/functions/Completion"
  [[ -f "$ZSH_LOCAL_FPATH/_pdm" ]] \
    && zinit wait lucid is-snippet wait'[[ -f .pdm.toml ]]' atload'source <(pdm completion zsh | head -n -3); compdef _pdm pdm' for "$ZSH_LOCAL_FPATH/_pdm"
  [[ -f "$ZSH_LOCAL_FPATH/_rustup" ]] \
    && zinit wait lucid is-snippet has'rg' atload'source <(rustup completions zsh rustup); compdef _rustup rustup' for "$ZSH_LOCAL_FPATH/_rustup"
  [[ -f "$ZSH_LOCAL_FPATH/_rg" ]] \
    && zinit wait lucid is-snippet atload'source <(rg --generate=complete-zsh | rg --invert-match "^_rg\s"); compdef _rg rg' for "$ZSH_LOCAL_FPATH/_rg"
  [[ -f "$ZSH_LOCAL_FPATH/_kubectl" ]] \
    && zinit wait lucid is-snippet atload'source <(kubectl completion zsh)' for "$ZSH_LOCAL_FPATH/_kubectl"
  [[ -f "$ZSH_LOCAL_FPATH/_kubeadm" ]] \
    && zinit wait lucid is-snippet atload'source <(kubeadm completion zsh)' for "$ZSH_LOCAL_FPATH/_kubeadm"
  [[ -f "$ZSH_LOCAL_FPATH/_minikube" ]] \
    && zinit wait lucid is-snippet atload'source <(minikube completion zsh)' for "$ZSH_LOCAL_FPATH/_minikube"
  [[ -f "$ZSH_LOCAL_FPATH/_helm" ]] \
    && zinit wait lucid is-snippet atload'source <(helm completion zsh)' for "$ZSH_LOCAL_FPATH/_helm" 
  [[ -f "$ZSH_LOCAL_FPATH/_sdk" ]] \
    && zinit wait lucid is-snippet \
      atload'source $SDKMAN_DIR/bin/sdkman-init.sh' \
      atload'include_path=($JAVA_HOME/include $JAVA_HOME/include/linux $include_path)' \
      atload'ld_library_path=($JAVA_HOME/lib $JAVA_HOME/lib/server $ld_library_path)' \
      for "$ZSH_LOCAL_FPATH/_sdk" 
}
# systemd 补全脚本
# 可能是版本问题，systemctl 不支持补全脚本中的 --legend=no，因此手动替换成 --no-legend
(( $+commands[systemctl] )) && zinit wait lucid as'completion' for \
  https://github.com/systemd/systemd/blob/main/shell-completion/zsh/_journalctl \
  as'program' atclone'sed -e"s:{{LIBEXECDIR}}:/usr/lib:g" _systemctl.in > _systemctl' atpull'%atclone' \
  https://github.com/systemd/systemd/blob/main/shell-completion/zsh/_systemctl.in
# }}}

# 自定义脚本 {{{
(( $+commands[eza] )) && alias ls='eza --long --binary --header --time-style=long-iso'
(( $+commands[bat] )) && alias hl='bat --paging=never --style=plain'
(( $+commands[vim] )) && alias view="vim -R '+set nomodifiable'"
(( $+commands[rsync] )) && alias rsync='rsync --partial --info=PROGRESS2 --protect-args'
if uname -r | grep --ignore-case --quiet microsoft; then
  function open() {
    explorer.exe "$(wslpath -w "$@")" || true
  }
fi

function highlight-log() {
  awk -v IGNORECASE=1 \
    '{ gsub(/\033\[[0-9;]*?\w/, "") }
    /^Fatal\>|"level":"fatal"|level=fatal/    { print "\033[31m" $0 "\033[m"; next }
    /^Error\>|"level":"error"|level=error/    { print "\033[1;31m"   $0 "\033[m"; next }
    /^Warn\>|"level":"warning"|level=warn/    { print "\033[1;33m"   $0 "\033[m"; next }
    /^Notice\>|"level":"notice"|level=notice/ { print "\033[1;34m"   $0 "\033[m"; next }
    /^Info\>|"level":"info"|level=info/       { print "\033[1;32m"   $0 "\033[m"; next }
    /^Debug\>|"level":"debug"|level=debug/    { print "\033[1;35m"   $0 "\033[m"; next }
    /^Trace\>|"level":"trace"|level=trace/    { print "\033[1;36m"   $0 "\033[m"; next }
    1'
}
# }}}

# vim: foldmethod=marker
