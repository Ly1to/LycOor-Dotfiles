# Zinit 路径只定义一次，后续脚本和插件都复用它。
typeset -g ZINIT_HOME="${ZINIT_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git}"

# Added by Zinit's installer
if [[ ! -r "$ZINIT_HOME/zinit.zsh" ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    if command mkdir -p "${ZINIT_HOME:h}" &&
        command chmod g-rwX "${ZINIT_HOME:h}" &&
        command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME"; then
        print -P "%F{33} %F{34}Installation successful.%f%b"
    else
        print -u2 -P "%F{160} Zinit installation failed; the remaining zinit plugins will be skipped.%f%b"
    fi
fi

# clone 失败时不要 source 不存在的文件，否则每次启动都会报错。
if [[ -r "$ZINIT_HOME/zinit.zsh" ]]; then
    source "$ZINIT_HOME/zinit.zsh"
else
    print -u2 "Zinit is unavailable; interactive shell will continue without its plugins."
fi

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
if (( $+functions[zinit] )); then
    zinit light-mode for \
        zdharma-continuum/zinit-annex-as-monitor \
        zdharma-continuum/zinit-annex-bin-gem-node \
        zdharma-continuum/zinit-annex-patch-dl \
        zdharma-continuum/zinit-annex-rust
fi
# end of zinit's init

# completion and performance

# zsh-completions 必须先加入 fpath，再执行 compinit；否则额外的补全不会被扫描。
if (( $+functions[zinit] )); then
    zinit light zsh-users/zsh-completions
fi

autoload -Uz compinit

# 使用年月日而不是一年中的第几天，避免跨年后误用一年前的缓存。
zcompdump_file="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ $(date -r "$zcompdump_file" +%Y%m%d 2>/dev/null) != $(date +%Y%m%d) ]]; then
    compinit -d "$zcompdump_file"
else
    compinit -C -d "$zcompdump_file"
fi

# compinit 后注册 zinit 自身的补全。
if (( $+functions[zinit] )); then
    autoload -Uz _zinit
    _comps[zinit]=_zinit
fi

zstyle ':completion:*' completer _complete _ignored
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# 某些环境不会自动设置 LS_COLORS，未设置时不覆盖补全颜色。
if [[ -n $LS_COLORS ]]; then
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

HISTFILE=$HOME/.zsh_history

HISTSIZE=10000
SAVEHIST=10000

KEYTIMEOUT=1

setopt HIST_IGNORE_DUPS
setopt EXTENDED_HISTORY
# SHARE_HISTORY 已包含 INC_APPEND_HISTORY 的行为，无需重复设置。
setopt SHARE_HISTORY

# plugins

if (( $+functions[zinit] )); then
    # 非关键插件延迟到首次提示符后加载，减少 .zshrc 的同步启动时间。
    zinit ice wait lucid
    zinit light zsh-users/zsh-autosuggestions

    # ZVM 管理 keymap，保持同步加载以避免首屏按键初始化竞争。
    ZVM_CURSOR_STYLE_ENABLED=false
    ZVM_LINE_INIT_MODE=i
    zinit light jeffreytse/zsh-vi-mode

    zinit ice wait lucid
    zinit light zsh-users/zsh-history-substring-search
fi

# ZVM 会延迟初始化并重新设置 keymap，因此按键必须通过它提供的钩子绑定。
function zvm_after_lazy_keybindings() {
    zvm_bindkey vicmd 'k' history-substring-search-up
    zvm_bindkey vicmd 'j' history-substring-search-down
}

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=''
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=''

# exports and PATH

# 使用 zsh 的 path 数组去重，重复 source .zshrc 也不会不断累积相同路径。
typeset -U path PATH
path=(
    "$HOME/.npm-global/bin"
    "$HOME/.local/bin"
    $path
)
export PATH
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

alias ff='fastfetch --config arch-extended'

alias pf='poweroff'
alias rb='reboot'

alias ..="cd .."
alias ...="cd ../.."

alias gt='git'
alias grep='grep --color=auto'

function mkcd() {
    # 只接受一个目录参数，并阻止以 "-" 开头的名称被当成选项。
    if (( $# != 1 )); then
        print -u2 '用法: mkcd <目录>'
        return 2
    fi

    command mkdir -p -- "$1" && builtin cd -- "$1"
}

function yz() {
  local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}

# ZVM 初始化会覆盖之前注册的 keymap；fzf 也必须等 ZVM 初始化后再加载。
zvm_after_init_commands+=('command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)')
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[starship] )) && eval "$(starship init zsh)"

# use zinit to process all completions registered by plugins
(( $+functions[zinit] )) && zinit cdreplay -q

# 语法高亮最后加载；Turbo 可避免它阻塞首次提示符。
if (( $+functions[zinit] )); then
    zinit ice wait lucid
    zinit light zsh-users/zsh-syntax-highlighting
fi
