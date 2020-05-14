export TERM=xterm-256color
export ZSH=$HOME/.oh-my-zsh

# Powerlevel9k
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_CUSTOM_EMOJI='prompt_emoji'
POWERLEVEL9K_CUSTOM_EMOJI_BACKGROUND='white'
POWERLEVEL9K_CUSTOM_EMOJI_FOREGROUND='black'
function prompt_emoji() {
  readonly EMOJI=(
    '_(´ཀ`」 ∠)__'
    "~o(〃'▽ '〃)o"
    '( ￣ー￣)人(^▽ ^ )击掌'
    '( *・ω・)✄╰ひ╯'
    'へ(._へ)sᴋʀ'
    '(งᵒ̌皿ᵒ̌)ง⁼³₌₃'
    '｡･ﾟﾟ･(>д<;)･ﾟﾟ･｡'
    '(╯°Д°)╯︵ ┻━┻'
    '๛ ก(ｰ̀ωｰ́ก)'
    'ʕง•ᴥ•ʔง'
  )
  echo "${EMOJI[$$ % ${#EMOJI[@]} + 1]}"
}
# Windows Terminal will transparent 'black' background, use color code
POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND='233'
POWERLEVEL9K_STATUS_OK_BACKGROUND='233'
POWERLEVEL9K_OS_ICON_BACKGROUND='233'

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ssh context dir dir_writable newline custom_emoji vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs command_execution_time time os_icon)
ZSH_THEME="powerlevel9k/powerlevel9k"

plugins=(
  rustup rust cargo pip cabal
  zsh-syntax-highlighting
  go docker z
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

# Initialize windows proxies
if uname -r | grep -iq microsoft
then
  export HOSTALIASES="$HOME/.config/etc/hosts"
  WINDOWS=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
  git config --global http.proxy $WINDOWS:8001
  git config --global https.proxy $WINDOWS:8001
  sed -i "s/^windows.*$/windows $WINDOWS/g" "$HOME/.config/etc/hosts"
  function proxy() {
    if [[ $1 == 'off' ]]
    then
      unset http_proxy https_proxy socks5_proxy
    else
      export http_proxy=http://$WINDOWS:8001
      export https_proxy=http://$WINDOWS:8001
      export socks5_proxy=socks5://$WINDOWS:1081
    fi
  }
fi

# Customize
alias ls='exa --git --grid --long --color-scale'
alias hl='pygmentize -O style=monokai'
alias view="vim -R '+set nomodifiable'"
