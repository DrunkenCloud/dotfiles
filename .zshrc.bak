# Enable Oh My Zsh plugins
plugins=(git)

# Load Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"  # or any theme you want
source $ZSH/oh-my-zsh.sh

# === Your Custom Additions ===

# History config
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

# Color support
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias actvenv='source ~/venv/bin/activate'

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Starship prompt
eval "$(starship init zsh)"

# Cloudflare Warp
warp-cli connect > /dev/null 2>&1

# Add Go to PATH
export PATH=$PATH:/usr/local/go/bin

# Optional: Source bash aliases if you use them
[ -f ~/.bash_aliases ] && source ~/.bash_aliases
export FLYCTL_INSTALL="/home/drunkencloud/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="/home/drunkencloud/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/opt/nvim/"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/opt/gradle/gradle-7.14.2/bin"
alias tree="tree -I 'node_modules|dist|.git'"
alias vim="nvim"
export GEMINI_API_KEY="AIzaSyAQNWA354tNzdghvIAJ0i-MQMBhMzeQsCA"
