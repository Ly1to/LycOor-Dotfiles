# completion and performance

autoload -Uz compinit

typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || echo 0)
if [ $(date +'%j') -ne $updated_at ]; then
    compinit
else
    compinit -C
fi

zstyle ':completion:*' completer _complete _ignored
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

HISTFILE=$HOME/.zsh_history

HISTSIZE=10000
SAVEHIST=10000

bindkey -v

KEYTIMEOUT=1

setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY

source ~/.zsh/plugins/zsh-syntax-highlighting-master/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/zsh-autosuggestions-master/zsh-autosuggestions.zsh

# exports and PATH

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export EDITOR="vim"

# open bufferline in editor

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^E' edit-command-line

# alias and functions

alias cf='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --level=2 --icons'
alias lta='eza --tree --level=3 --icons -a'

alias gt='git'
alias grep='grep --color=auto'

function mkcd() {
  mkdir -p "$1" && cd "$1"
}

function yz() {
  local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}

source <(fzf --zsh)
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
