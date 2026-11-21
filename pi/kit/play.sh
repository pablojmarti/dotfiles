#!/bin/sh
# Usage: sh scripts/play.sh
#
# For you, on the Mac. One command that builds the game in the VM, plays it
# there with scripts/play-check.sh (the same check the tests run), and
# prints only what you need: the FAIL, WARN and ACCEPTED lines, the last
# line, and the folder with the pictures. Open the pictures to see the game.
#
# The play check's settings pass through, for example:
#   PLAY_KEYS='`:60' PLAY_FRAMES=300 sh scripts/play.sh
# The full report is saved to build/play/report.txt.
#
# Exit status: the play check's (0 PASS, 1 FAIL, 2 could not run).
# Inside the VM it runs the check directly. GONDOLIN and GONDOLIN_IMAGE
# point to the VM tools if they are not in the usual place under ~/.pi.

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/.." && pwd)
cd "$root" || exit 2

if [ "$(uname -s)" != "Linux" ]; then
  vm=${GONDOLIN:-$HOME/.pi/gondolin-ext/node_modules/.bin/gondolin}
  image=${GONDOLIN_IMAGE:-$HOME/.pi/gondolin-image}
  if [ ! -x "$vm" ] || [ ! -e "$image" ]; then
    echo "play: could not run: the VM tools are not at $vm and $image."
    exit 2
  fi
  # Hand the PLAY_ settings to the VM, each value in single quotes.
  pass=""
  for name in PLAY_KEYS PLAY_FRAMES PLAY_FPS PLAY_TIMEOUT PLAY_MAX_SPEED PLAY_EXPECT_EXIT PLAY_SHOTS PLAY_ACCEPT; do
    eval "set=\${$name+x} value=\${$name-}"
    # shellcheck disable=SC2154
    [ -n "$set" ] || continue
    quoted=$(printf '%s' "$value" | sed "s/'/'\\\\''/g")
    pass="$pass $name='$quoted'"
  done
  "$vm" exec --image "$image" --mount-hostfs "$root:/workspace" -- \
    sh -c "cd /workspace && env $pass sh scripts/play.sh" </dev/null
  status=$?
  [ $status -le 2 ] || status=2
  echo "Pictures: $root/build/play/"
  exit $status
fi

# ---- in the VM ----
mkdir -p build/play
if [ ! -f build/CMakeCache.txt ]; then
  cmake -B build >build/play/build-output.txt 2>&1 || {
    tail -20 build/play/build-output.txt
    echo "play: FAIL, the build could not be set up (build/play/build-output.txt)."
    exit 1
  }
fi
if ! cmake --build build >>build/play/build-output.txt 2>&1; then
  grep -E 'error|Error' build/play/build-output.txt | head -20
  echo "play: FAIL, the game did not build (build/play/build-output.txt)."
  exit 1
fi

sh scripts/play-check.sh >build/play/report.txt 2>&1
status=$?
grep -E '^(FAIL|WARN|ACCEPTED) ' build/play/report.txt
tail -1 build/play/report.txt
exit $status
