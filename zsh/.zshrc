[[ ${+TMUX} ]] && cd ${PWD##/data00}
# customize installation here

unset PATH CPATH LD_LIBRARY_PATH LD_RUN_PATH LIBRARY_PATH
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/opt/tiger/yarn_deploy/hadoop/bin"
export LD_LIBRARY_PATH="$HOME/.local/opt/lib"
export LD_RUN_PATH="$HOME/.local/opt/lib"
export LIBRARY_PATH="$HOME/.local/opt/lib"
export MANPATH='/usr/local/share/man:/usr/share/man'
export INFOPATH='/usr/local/share/info:/usr/share/info'
export LC_ALL=en_US.UTF-8
export TERM=xterm-256color
export ZSH="$HOME/.oh-my-zsh"

packages=(
  'llvm-project'  # 靠前的优先级较低，这里有不少头文件
  'gmp' 'mpfr' 'mpc' 'isl' 'zstd' 'gcc' 'binutils-gdb'
  'fossil' 'tcl' 'sqlite'
  'zlib' 'openssl' 'gpm' 'ncurses' 'gdbm' 'gzip' 'bzip2' 'xz' 'readline' 'libffi' 'libexpat' 'pcre2' 'cpython' 'cpython-v3.9.0'
  'file'
  'vim'
  'libevent' 'libutempter/usr' 'utf8proc' 'tmux'
  'go1.15.2.linux-amd64' # 'go'
  'icu'
  'boost'
  # 'git'
  # 'c-ares' 'brotli' 'zstd' 'git' # 'curl'
  # downloaded
  'cmake-3.18.4-Linux-x86_64'
  'dmd.2.094.0.linux'
  'jdk-11.0.8' #'jdk1.8.0_261'
  'apache-maven-3.6.3' 'gradle-6.5'
  'scala-2.13.3' 'sbt-1.3.13' # 'dotty-0.26.0-RC1'
  'node-v15.0.1-linux-x64'
  'protoc-4.0.0-rc-2'
  'elasticsearch-7.8.0' 'kibana-7.8.0-linux-x86_64'
)
plugins=(
  rustup svn
  zsh-syntax-highlighting
  z
)

ZSH_THEME="powerlevel10k/powerlevel10k"

source $ZSH/oh-my-zsh.sh

# Zsh Syntax Highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
if (( ${+ZSH_HIGHLIGHT_STYLES} )); then
  ZSH_HIGHLIGHT_STYLES[unknown-token]='bg=052'
  ZSH_HIGHLIGHT_STYLES[arg0]='fg=148'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=148'
  ZSH_HIGHLIGHT_STYLES[function]='fg=148'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=081'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=197'
  ZSH_HIGHLIGHT_STYLES[globbing]='fg=012'

  ZSH_HIGHLIGHT_STYLES[path]='underline'
  ZSH_HIGHLIGHT_STYLES[comment]='fg=240'

  ZSH_HIGHLIGHT_STYLES[bracket-level-1]='none'
  ZSH_HIGHLIGHT_STYLES[bracket-level-2]='none'
  ZSH_HIGHLIGHT_STYLES[bracket-level-3]='none'
  ZSH_HIGHLIGHT_STYLES[bracket-level-4]='none'
  ZSH_HIGHLIGHT_STYLES[bracket-level-5]='none'
  ZSH_HIGHLIGHT_STYLES[bracket-error]='bg=052'

  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=186'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=186'
  ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=197'
  ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=197'
  ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=148'

  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=208'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=208'
fi

function init_paths() {
  local BASE="$HOME/.local/opt"
  local -A DIR_VARS=(
    'bin'           'PATH'
    'sbin'          'PATH'
    'include'       'CPATH'
    'lib'           'LD_LIBRARY_PATH LD_RUN_PATH LIBRARY_PATH'
    'lib64'         'LD_LIBRARY_PATH LD_RUN_PATH LIBRARY_PATH'
    'share/man'     'MANPATH'
    'man'           'MANPATH'
    'share/info'    'INFOPATH'
    'lib/pkgconfig' 'PKG_CONFIG_PATH'
    'ssl'           'OPENSSLDIR'
  )

  function add_paths() {
    local package=$1
    local vardir=$2
    shift 2
    for var in "$@"
    do
      export $var="$BASE/$package/$vardir${(P)var:+:${(P)var}}"
    done
  }
  for package in ${packages[@]}
  do
    if [[ ! -d $BASE/$package ]]
    then
      echo -e "\033[1;33mwarn:\033[m \033[1m$package\033[m not exist, skip"
      continue
    fi

    for dir vars in ${(kv)DIR_VARS}
    do
      [[ -d $BASE/$package/$dir ]] && add_paths $package $dir ${=vars}
    done
  done
}
init_paths

# Rust
source $HOME/.cargo/env
# Go
export GOROOT="${$(which go)%/bin/go}"
export GOPATH="$HOME/Workspace/go"
export PATH="$GOPATH/bin${PATH:+:$PATH}"
# Java
export JAVA_HOME="${$(which java)%/bin/java}"
export M2_HOME="$HOME/.local/opt/apache-maven-3.6.3"
# CPython
export PYTHONPATH="$HOME/.local/lib/site-packages${PYTHONPATH:+:$PYTHONPATH}"
export PATH="$HOME/.local/lib/site-packages/bin${PATH:+:$PATH}"

# Customize
if uname -r | grep -iq microsoft
then
  # Initialize wsl2 proxies
  export HOSTALIASES="$HOME/.config/etc/hosts"
  WINDOWS=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
  git config --global http.proxy $WINDOWS:8001
  git config --global https.proxy $WINDOWS:8001
  sed -i "s/^windows.*$/windows $WINDOWS/g" "$HOME/.config/etc/hosts"
  PROXYHOST=$WINDOWS
else
  PROXYHOST=127.0.0.1
fi
function proxy() {
  if [[ $1 == 'off' ]]
  then
    unset http_proxy https_proxy socks5_proxy
  else
    export http_proxy=http://$PROXYHOST:8001
    export https_proxy=http://$PROXYHOST:8001
    export socks5_proxy=socks5://$PROXYHOST:1081
  fi
}

export EDITOR='vim'
alias ls='exa --long'
alias hl='pygmentize -O style=monokai'
alias view="vim -R '+set nomodifiable'"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
