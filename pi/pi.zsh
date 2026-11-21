# Pi + Gondolin. Sourced from .zshrc on every machine.
# Note: the primer warns against aliasing `pi` itself (package commands like
# `pi list` / `pi install` stop working); use `pie` for those.
alias pie='command pi'
alias pi='pi -e ~/.pi/gondolin-ext'

# Rebuild the VM image from build-config.local.json (run pi/install.sh first).
pi-vm-rebuild() {
  (
    cd ~/.pi/gondolin-ext || return 1
    if [[ "$(uname -s)" == Darwin ]]; then
      PATH="$(brew --prefix e2fsprogs)/sbin:$PATH"
    fi
    ./node_modules/.bin/gondolin build --config build-config.local.json --output ~/.pi/gondolin-image
  )
}

export PI_OFFLINE=1
export PI_TELEMETRY=0
export PI_SKIP_VERSION_CHECK=1
export SUPERPOWERS_DISABLE_TELEMETRY=1
