# Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust
# end of zinit's init

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

# plugins

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

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

alias ..="cd .."
alias ...="cd ../.."

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

# ues zinit to process all completions registered by plugins
zinit cdreplay -q
