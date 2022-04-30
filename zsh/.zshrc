# 代理是头等大事
if uname -r | grep --ignore-case --quiet microsoft
then
  # Initialize wsl2 proxies
  export HOSTALIASES="$HOME/.local/etc/hosts"
  WINDOWS=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
  git config --global http.proxy $WINDOWS:10809
  git config --global https.proxy $WINDOWS:10809
  sed -i "s/^windows.*$/windows $WINDOWS/g" "$HOSTALIASES"
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
}

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
# zinit 插件
zinit light romkatv/powerlevel10k
zinit wait lucid for \
  atload'unset FAST_HIGHLIGHT\[chroma-make\]' zdharma-continuum/fast-syntax-highlighting \
  pick'bin/rbenv' as'program' atload'eval "$(bin/rbenv init - zsh)"' rbenv/rbenv \
  pick'bin/ruby-build' as'program' rbenv/ruby-build
# 通用补全脚本
zinit wait lucid as'completion' for \
  mv'838a7f1b39e81ee0c06cfa959e6e97f6152019b04e10aab719c6fb118b415253 -> _fossil' \
  https://fossil-scm.org/home/raw/838a7f1b39e81ee0c06cfa959e6e97f6152019b04e10aab719c6fb118b415253 \
  https://github.com/BurntSushi/ripgrep/blob/master/complete/_rg \
  https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker \
  https://github.com/mesonbuild/meson/blob/master/data/shell-completions/zsh/_meson \
  mv'zsh-completion -> _ninja' \
  https://github.com/ninja-build/ninja/blob/master/misc/zsh-completion \
  https://github.com/ogham/exa/blob/master/completions/zsh/_exa \
  https://github.com/rust-lang/cargo/blob/master/src/etc/_cargo \
  as'program' atclone'sed "s/{{PROJECT_EXECUTABLE}}/bat/g" bat.zsh.in > _bat' atpull'%atclone' \
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

# systemd 补全脚本
(( $+commands[systemctl] )) && zinit wait lucid as'completion' for \
  https://github.com/systemd/systemd/blob/main/shell-completion/zsh/_journalctl \
  as'program' atclone'sed -i"" -e"s:{{ROOTLIBEXECDIR}}/::g" -e"s:--legend=no:--no-legend:g" _systemctl.in' atpull'%atclone' \
  https://github.com/systemd/systemd/blob/main/shell-completion/zsh/_systemctl.in

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Zsh
setopt interactive_comments  # 允许在交互模式使用注释
bindkey -e  # Emacs 键位
HISTSIZE=100000          # 启动时加载历史数量
SAVEHIST=100000          # 文件储存历史数量
HISTFILE=~/.zsh_history  # 历史命令储存文件
HISTORY_IGNORE='(cd*|ls*)'
setopt share_history     # 多终端之间共享历史
setopt incappendhistory  # 及时追加命令历史
bindkey "$key[Up]"   history-beginning-search-backward  # 上键向前搜索命令
bindkey "$key[Down]" history-beginning-search-forward   # 下键向后搜索命令
bindkey '^P' history-beginning-search-backward          # C-P 向前搜索命令
bindkey '^N' history-beginning-search-forward           # C-N 向后搜索命令
export WORDCHARS=''                                     # 只有字母数字作为一个单词
autoload -U compinit && compinit                        # 初始化补全
zstyle ':completion:*' matcher-list \
  '' \
  'm:{[:lower:]}={[:upper:]}' \
  'l:|=* r:|=*'
zstyle ':completion:*' menu select                       # 补全展示选择菜单
zstyle ':completion:*:*:make:*' tag-order 'targets'      # Makefile 仅补全 targets
zmodload zsh/complist                                    # 提供 menuselect keymap
bindkey -M menuselect '^[[Z' reverse-menu-complete       # 补全菜单 S-Tab 选择上一条
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # 补全菜单高亮
autoload -z edit-command-line && zle -N edit-command-line
bindkey '^X^E' edit-command-line  # C-X C-E 进入编辑器编辑模式

function expand-dots() {
  [[ $LBUFFER =~ '\.\.\.+' ]] && LBUFFER=$LBUFFER:fs%\.\.\.%../..%
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

# 手动安装的软件，在 $HOME/.local/opt 下分目录隔离安装
export CMAKE_PREFIX_PATH=''
export PATH="$HOME/.local/bin:/usr/bin:/bin"
export CPATH=''
export LD_LIBRARY_PATH="$HOME/.local/lib"
export LD_RUN_PATH="$HOME/.local/lib"
export LIBRARY_PATH="$HOME/.local/lib"
export MANPATH='/usr/local/share/man:/usr/share/man'
export INFOPATH='/usr/local/share/info:/usr/share/info'
export PKG_CONFIG_PATH='/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig'
export ACLOCAL_PATH='/usr/share/aclocal'
export OPENSSLDIR="$HOME/.local/ssl"
export SSL_CERT_DIR="$HOME/.local/ssl/certs"
export TCLLIBPATH=''
export LC_ALL=en_US.UTF-8
export TERM=xterm-256color
packages=(
  # dev-db
  sqlite
  # dev-lang
  tcl
  cpython
  go
  # dev-cpp
  oneTBB
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
  local OPT="$HOME/.local/opt"
  local -A VAR_DIRS=(
    PATH            'bin:sbin'
    CPATH           'include'
    LIBRARY_PATH    'lib:lib64:lib/x86_64-unknown-linux-gnu:lib/x86_64-linux-gnu:lib64/x86_64-linux-gnu'
    LD_LIBRARY_PATH 'lib:lib64:lib/x86_64-unknown-linux-gnu:lib/x86_64-linux-gnu:lib64/x86_64-linux-gnu'
    LD_RUN_PATH     'lib:lib64:lib/x86_64-unknown-linux-gnu:lib/x86_64-linux-gnu:lib64/x86_64-linux-gnu'
    MANPATH         'share/man:man'
    INFOPATH        'share/info'
    PKG_CONFIG_PATH 'lib/pkgconfig:lib64/pkgconfig:lib/x86_64-linux-gnu/pkgconfig:lib64/x86_64-linux-gnu/pkgconfig'
    ACLOCAL_PATH    'share/aclocal'
    TCLLIBPATH      'share/tcltk'
  )
  local pkg var dirs dir

  for pkg in $packages; do
    if [[ -d "$OPT/$pkg" ]]; then
      for var dirs in ${(kv)VAR_DIRS}; do
        for dir in ${(@s/:/)dirs}
          [[ -d "$OPT/$pkg/$dir" ]] && export $var="$OPT/$pkg/$dir${(P)var:+:${(P)var}}"
      done
      export CMAKE_PREFIX_PATH="$OPT/$pkg${CMAKE_PREFIX_PATH:+;$CMAKE_PREFIX_PATH}"
    else
      print -P "%F{yellow}%B$pkg%b not found%f"
    fi
  done
}

# Vim
export MYVIMRC='~/.vimrc'
export VIMINIT='set runtimepath^=~/.vim | source $MYVIMRC'
# Rust
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
(( $+commands[rustup] )) && eval "$(rustup completions zsh | sed '$ d'); compdef _rustup rustup"
# Haskell
[[ -s "$HOME/.ghcup/env" ]] && source "$HOME/.ghcup/env"
alias ghci='ghci -interactive-print=Text.Pretty.Simple.pPrint'
# Go
if (( $+commands[go] )); then
  export GOPATH="$HOME/.go"
  export PATH="$GOPATH/bin${PATH:+:$PATH}"
fi
# Java
if (( $+commands[java] )); then
  export JAVA_HOME="${$(which java)%/bin/java}"
fi
# Perl
export PATH="$HOME/.local/lib/site_perl/bin${PATH:+:$PATH}"
export MANPATH="$HOME/.local/lib/site_perl/man:${MANPATH:+:$MANPATH}"

# Customize
export EDITOR='nvim'
(( $+commands[exa] )) && alias ls='exa --time-style=long-iso --header --long'
alias hl='bat --style=plain --paging=never'
alias view="vim -R '+set nomodifiable'"
if uname -r | grep --ignore-case --quiet microsoft
then
  alias open='explorer.exe'
fi

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
