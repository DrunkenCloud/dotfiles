
# --- Zinit install if missing, then load ---
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# --- Zinit plugins (syntax-highlighting must come last) ---
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-syntax-highlighting

# --- History substring search: bind keys and disable highlighting ---
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=''
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=''

bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# --- Shift+Delete = delete previous word (ghostty takes ctrl+w for close-tab) ---
# \E[3;2~ is terminfo kDC; same under xterm-ghostty and xterm-256color
bindkey '^[[3;2~' backward-kill-word

# --- Completions ---
zstyle ':completion:*' use-cache yes
zstyle ':completion::complete:*' cache-path ~/.zsh/cache
autoload -Uz compinit
compinit -C

# --- Shell History Options ---
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=$HISTSIZE
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# --- Locale ---
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# --- PATH ---
# typeset -U keeps PATH free of duplicates, even in nested shells.
# (cargo and foundry are added in ~/.zshenv)
typeset -U path PATH
export PNPM_HOME="$HOME/.local/share/pnpm"
path=(
  $HOME/.local/bin
  $HOME/.opencode/bin
  $PNPM_HOME
  $PNPM_HOME/bin
  $path
  /opt/nvim/bin
  /opt/anki-launcher
)

# --- Node (nvm), lazy-loaded ---
# Sourcing nvm.sh costs ~0.6s per shell. Instead, put the default node's bin dir
# on PATH directly (so node, npm and global tools like codex/pm2 work instantly)
# and only load nvm itself the first time you run `nvm`.
export NVM_DIR="$HOME/.nvm"
_nvm_default=$(command cat "$NVM_DIR/alias/default" 2>/dev/null)
if [[ "$_nvm_default" == node || -z "$_nvm_default" ]]; then
  _nvm_bins=("$NVM_DIR"/versions/node/*/bin(Nn))       # "node" = newest installed
else
  _nvm_bins=("$NVM_DIR"/versions/node/v${_nvm_default#v}*/bin(Nn))
fi
(( ${#_nvm_bins} )) && path=("${_nvm_bins[-1]}" $path)
unset _nvm_default _nvm_bins

nvm() {
  unfunction nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}

# --- Color Support for GNU Tools ---
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# --- Aliases ---
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias actvenv='source ./venv/bin/activate'      # venv in the current project
alias actvenv-home='source ~/venv/bin/activate' # the global ~/venv
alias tree="tree -I 'node_modules|dist|.git|__pycache__'"
alias vim="nvim"
alias ac="ani-cli"
alias wgup="sudo wg-quick up wg0"
alias wgdown="sudo wg-quick down wg0"
alias steam-kill='pkill -9 -f steam'
alias cursor="cursor --no-sandbox"
alias bat="batcat"
alias cat="batcat"
alias wcd="warp-cli disconnect"
alias wcc="warp-cli connect"
alias wcs="warp-cli status"
alias check-tsa='curl -s -o /dev/null -w "TSA status: %{http_code}\n" -X POST -H "Content-Type: application/timestamp-query" --data-binary "x" http://timestamp.digicert.com && echo "(400 = reachable, 000 = blocked)"'

# --- Load custom bash aliases, if present ---
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# --- Tool integrations ---
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
eval "$(zoxide init zsh)"

# --- fzf: Ctrl+R fuzzy history, Ctrl+T insert a file path, Alt+C cd into a folder ---
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border=rounded \
    --color=bg+:#2a2238,fg+:#ffffff,hl:#c084fc,hl+:#d8b4fe,pointer:#c084fc,prompt:#c084fc,border:#a855f7,info:#8b7aa8"
  source <(fzf --zsh)
fi
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
