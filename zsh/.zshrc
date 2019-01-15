export TERM=xterm-256color
export ZSH=$HOME/.oh-my-zsh

# Powerlevel9k
POWERLEVEL9K_LEFT_PROMPT_ELEMEMTS=(ssh context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs time os_icon)
POWERLEVEL9K_MODE=nerdfont-complete
ZSH_THEME="powerlevel9k/powerlevel9k"
plugins=(
  osx rustup rust cargo pip docker
  zsh-syntax-highlighting
  go z
)
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

  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=007'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=007'
fi

# Fuzzy Finder
export FZF_DEFAULT_OPTS="--preview 'pygmentize -O style=monokai {}'"

# Go
export GOPATH=$HOME/go-workspace
export GIT_TERMINAL_PROMPT=1
export PATH=$GOPATH/bin:$PATH

# Haskell
export PATH=$HOME/.cabal/bin:$PATH

# Rust
export PATH=$HOME/.cargo/bin:$PATH

# Homebrew
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles

# Customize
alias ls='exa --git --grid --long --color-scale'
alias hl='pygmentize -O style=monokai'
