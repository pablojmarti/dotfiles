# Path to your oh-my-zsh installation.
export ZSH="/Users/pablo/.oh-my-zsh"

# THEME
ZSH_THEME="minimal"

# use vim commands in cli
set editing-mode vi

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"


# automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# enable command auto-correction.
ENABLE_CORRECTION="true"

# display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  vi-mode
  macos
  history-substring-search
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# =========================================== PATHS ===========================================
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

#composer
export PATH=~/.composer/vendor/bin:$PATH

#pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# Load pyenv into the shell by adding
# the following to ~/.zshrc:
eval "$(pyenv init -)"

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
