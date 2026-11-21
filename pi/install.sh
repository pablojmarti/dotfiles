#!/usr/bin/env bash
# Links the Pi config in this repo into ~/.pi. Safe to run more than once.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() { # link <repo path> <home path>
  local from="$1" to="$2"
  if [[ -L "$to" && "$(readlink "$to")" == "$from" ]]; then
    echo "ok      $to"
    return
  fi
  if [[ -e "$to" || -L "$to" ]]; then
    mv "$to" "$to.pre-dotfiles-$STAMP"
    echo "backup  $to -> $to.pre-dotfiles-$STAMP"
  fi
  ln -s "$from" "$to"
  echo "link    $to -> $from"
}

mkdir -p "$HOME/.pi/agent"
link "$SRC/agent/settings.json"        "$HOME/.pi/agent/settings.json"
link "$SRC/agent/.i-have-adhd-always"  "$HOME/.pi/agent/.i-have-adhd-always"
link "$SRC/agent/prompts"              "$HOME/.pi/agent/prompts"
link "$SRC/gondolin-ext"               "$HOME/.pi/gondolin-ext"

if [[ ! -e "$HOME/.pi/agent/models.json" ]]; then
  cp "$SRC/agent/models.json.example" "$HOME/.pi/agent/models.json"
  chmod 600 "$HOME/.pi/agent/models.json"
  echo "TODO    edit the apiKey in ~/.pi/agent/models.json"
fi

node_ok=$(node -e 'const [a,b]=process.versions.node.split(".").map(Number);console.log(a>23||(a===23&&b>=6)?1:0)' 2>/dev/null || echo 0)
[[ "$node_ok" == 1 ]] || echo "WARN    Gondolin needs Node >= 23.6.0 (found: $(node --version 2>/dev/null || echo none))"

(cd "$SRC/gondolin-ext" && npm install --ignore-scripts --no-audit --no-fund)
node "$SRC/gondolin-ext/make-build-config.mjs"

echo
echo "Next:"
[[ -d "$HOME/.pi/agent/git/github.com/obra/superpowers" ]] || echo "  command pi install git:github.com/obra/superpowers"
[[ -e "$HOME/.pi/gondolin-image/manifest.json" ]] || echo "  pi-vm-rebuild            # builds ~/.pi/gondolin-image (several minutes)"
echo "  source pi/pi.zsh from your .zshrc if it isn't already"
echo "  herdr users: reinstall the herdr pi integration (it writes ~/.pi/agent/extensions/)"
