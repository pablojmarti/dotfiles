# Path to your oh-my-zsh installation.
export ZSH="/Users/pablo/.oh-my-zsh"
export EDITOR=nvim

# THEME
ZSH_THEME="jonathan"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# Plugins are loaded in order (zsh-syntax-highlighting must stay last)
plugins=(
  git
  vi-mode
  macos
  history-substring-search
  zlong_alert
  zinsults
  zsh-syntax-highlighting
)

# Automatically updates Oh My ZSH
zstyle ':omz:update' mode auto

# Check for updates every 7 days
zstyle ':omz:update' frequency 7

# automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

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

# pyenv setup
export PYTHON_CONFIGURE_OPTS="--enable-framework"

# Tfswitch
export PATH="/Users/pablo/bin:$PATH"

# JAVA CONFIG
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export JAVA_HOME=/opt/homebrew/opt/openjdk

# MCP Testing
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin/scripts:$PATH"


# =========================================== ALIASES ===========================================
alias gfp="git fetch && git pull"
# Removes stale local branches
alias gdg='git branch -vv | grep '\''\[origin/.*: gone]'\'' | awk '\''{print $1}'\'' | xargs git branch -d'

alias vim="nvim"

alias nv="nvim"

alias py="python3"

alias so="source ~/.zshrc"

# SSH Alias that will add 'bash -o vi' to all ssh commands via the vissh function
# TODO: add options to fall back to sh
vissh() {
  ssh -t bash -o vi $@
}

# pi (aliases, env, pi-vm-rebuild)
source ~/workspace/projects/dotfiles/pi/pi.zsh

# claude
personal-claude() { CLAUDE_CONFIG_DIR="$HOME/.personal-claude" claude "$@"; }
claudevil() { CLAUDE_CONFIG_DIR="$HOME/.claudevil" claude "$@"; }

# =========================================== CUSTOM VARS ===========================================
export obsidian_path=/Users/pablo/Library/Mobile\ Documents/iCloud\~md\~obsidian/Documents/Pablo\ Javier\'s\ Locker


# =========================================== MISC ===========================================

## kube autocomplete (cached; regenerated when the kubectl binary is newer)
_kc="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/kubectl_completion.zsh"
if [[ ! -s $_kc || $commands[kubectl] -nt $_kc ]]; then
  mkdir -p ${_kc:h} && kubectl completion zsh >| $_kc
fi
source $_kc; unset _kc

#vi stuff
bindkey -v
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# config for YCM Vim
export MONO_GAC_PREFIX="/opt/homebrew"

# ycm set up
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use  # This loads nvm (without the slow `nvm use default`)
# default alias is "24" -> newest matching installed version
_nvm_default=()
[[ -r $NVM_DIR/alias/default ]] && _nvm_default=($NVM_DIR/versions/node/v$(<$NVM_DIR/alias/default)*(N/nOn))
if (( $#_nvm_default )); then PATH="$_nvm_default[1]/bin:$PATH"; else nvm use default >/dev/null; fi
unset _nvm_default
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias gam="/Users/pablo/bin/gam7/gam"

export MallocNanoZone=0


export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - --no-rehash zsh)"

. "$HOME/.local/bin/env"
export DOCKER_HOST="unix:///Users/pablo/.colima/default/docker.sock"

export NANOCODER_NO_UPDATE_CHECK=1
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
