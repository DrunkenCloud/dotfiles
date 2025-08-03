# --- Zinit install if missing, then load ---
ZINIT_HOME="${XDG_DATA_HOME}:-${HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# --- Zinit plugins ---
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search

# --- History substring search: bind keys and disable highlighting ---
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=''
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=''

bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# --- Completions ---
zstyle ':completion:*' use-cache yes
zstyle ':completion::complete:*' cache-path ~/.zsh/cache
autoload -Uz compinit
compinit -C

# --- Shell History Options ---
HISTFILE=~/.zsh_history
HISTSIZE=5000
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
alias actvenv='source ~/venv/bin/activate'
alias tree="tree -I 'node_modules|dist|.git|__pycache__'"
alias vim="nvim"
alias actvenv="source ./venv/bin/activate"
alias ac="ani-cli"
alias wgup="sudo wg-quick up wg0"
alias wgdown="sudo wg-quick down wg0"

# --- Load custom bash aliases, if present ---
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

# --- Lazy-load nvm when needed ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# --- Starship prompt ---
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# --- PATH modifications ---
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin"
export FLYCTL_INSTALL="/home/drunkencloud/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
export PNPM_HOME="/home/drunkencloud/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;; # already in PATH
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
export PATH="$PATH:/opt/nvim"
export PATH="$PATH:/opt/gradle/gradle-7.14.2/bin"

# --- End of .zshrc ---
