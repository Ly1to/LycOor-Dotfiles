# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored
zstyle :compinstall filename '/home/lycor/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Lines configured by zsh-newuser-install

# End of lines configured by zsh-newuser-install

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
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export EDITOR="vim"

source <(fzf --zsh)
eval "$(zoxide init zsh)"

# open bufferline in editor

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^E' edit-command-line

alias cf='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

alias ls='ls --color=auto'
alias grep='grep --color=auto'

function yz() {
  local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}
