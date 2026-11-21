# Path to your oh-my-zsh installation.
export ZSH="/home/pablo/.oh-my-zsh"

# ENV VARS
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia

# THEME
ZSH_THEME="jonathan"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# Plugins are loaded in order
plugins=(
  git
  vi-mode
  macos
  history-substring-search
  zsh-syntax-highlighting
)

# Automatically updates Oh My ZSH
zstyle ':omz:update' mode auto

# Check for updates every 7 days
zstyle ':omz:update' frequency 7

# automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# use vim commands in cli
set editing-mode vi

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# enable command auto-correction.
ENABLE_CORRECTION="false"

# display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
COMPLETION_WAITING_DOTS="true"

HIST_STAMPS="yyyy-mm-dd"

## Zlong Alert Configuration
# Commented out the defaults for documentation
# zlong_duration=15
# zlong_ignore_cmds="vim ssh"
# zlong_ignore_pfxs="sudo time"
# zlong_send_notifications=true
# zlong_terminal_bell=true
# zlong_ignorespace=false
# zlong_message='"Done: $cmd Time: $ftime"'

source $ZSH/oh-my-zsh.sh

# =========================================== PATHS ===========================================
# =========================================== ALIASES ===========================================
alias gfp="git fetch && git pull"
# Removes stale local branches
alias gdg="git branch -vv | grep '\[origin/.*: gone]' | awk '{print $1}' | xargs git branch -d"

alias vim="nvim"

alias nv="nvim"

alias py="python3"

alias so="source ~/.zshrc"

alias copy="xclip -selection clipboard"

# SSH Alias that will add 'bash -o vi' to all ssh commands via the vissh function
# TODO: add options to fall back to sh
vissh() {
  ssh -t bash -o vi $@ 
}

alias pie='command pi'
# run pi with Vm
alias pi='pi -e ~/.pi/gondolin-ext'
# rebuild pi vm
alias build-pi-vm='export GONDOLIN_GUEST_DIR=~/.pi/gondolin-image/ && npx @earendil-works/gondolin build --config ~/.pi/gondolin-ext/build-config.json --output "$GONDOLIN_GUEST_DIR" || unset GONDOLIN_GUEST_DIR'

# =========================================== CUSTOM VARS ===========================================


# =========================================== MISC ===========================================

#vi stuff
bindkey -v
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down]]']]'

export MallocNanoZone=0

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.local/bin/env"

# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"

. "$HOME/.hermes/.env"

# Pi
export PATH="/home/pablo/.pi/agent/bin:$PATH"
export PI_OFFLINE=1
export PI_TELEMTRY=0
export PI_SKIP_VERSION_CHECK=1
export SUPERPOWERS_DISABLE_TELEMTRY=1






