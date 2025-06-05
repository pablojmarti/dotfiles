# Path to your oh-my-zsh installation.
export ZSH="/Users/pablo/.oh-my-zsh"

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
  zlong_alert
  zinsults
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
# export PATH="/usr/local/opt/python/libexec/bin:$PATH"

#composer
export PATH=~/.composer/vendor/bin:$PATH


# pyenv setup 
export PYTHON_CONFIGURE_OPTS="--enable-framework"


# Ansible 2.9 Support
export PATH="/opt/homebrew/opt/ansible@2.9/bin:$PATH"

# ECR
export PATH="/usr/local/bin/docker-credential-ecr-login:$PATH"
export PATH="/opt/homebrew/opt/php@7.4/bin:$PATH"
export PATH="/opt/homebrew/opt/php@7.4/sbin:$PATH"

# Tfswitch
export PATH="/Users/pablo/bin:$PATH"

# JAVA CONFIG
export PATH="/opt/homebrew/opt/bison/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export JAVA_HOME=/opt/homebrew/opt/openjdk

# Core Utils
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

# =========================================== ALIASES ===========================================
alias jmeter="bash /Applications/apache-jmeter-5.4.3/bin/jmeter"
alias gfp="git fetch && git pull"
# Removes stale local branches
alias gdg="git branch -vv | grep '\[origin/.*: gone]' | awk '{print $1}' | xargs git branch -d"

# SSH Alias that will add 'bash -o vi' to all ssh commands via the vissh function
# TODO: add options to fall back to sh
vissh() {
  ssh -t bash -o vi $@ 
}

# =========================================== CUSTOM VARS ===========================================
export obsidian_path=/Users/pablo/Library/Mobile\ Documents/iCloud\~md\~obsidian/Documents/Pablo\ Javier\'s\ Locker


# =========================================== MISC ===========================================

## kube autocomplete
source <(kubectl completion zsh)

#vi stuff
bindkey -v
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down]]']]'

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# config for YCM Vim
export MONO_GAC_PREFIX="/opt/homebrew"

# ycm set up
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#eval "$(gh copilot alias -- zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/pablo/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/pablo/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/pablo/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/pablo/google-cloud-sdk/completion.zsh.inc'; fi

alias gam="/Users/pablo/bin/gam7/gam"

if [ "$(arch)" = "arm64" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
          eval "$(/usr/local/bin/brew shellenv)"
fi

export MallocNanoZone=0
#alias python="python3"


export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# Restart your shell for the changes to take effect.
