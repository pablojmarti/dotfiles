#!/bin/sh
# Usage: sh scripts/mutate-check.sh            (every changed comparison in src/)
#        sh scripts/mutate-check.sh FILE:LINE  (one line)
# Do the tests check these lines? Run it from the project root.
#
# With no arguments it finds every comparison that git diff shows as added
# or changed in src/ (new untracked files in src/ count too), so you do not
# have to pick the lines.
#
# 1. Builds and runs the tests as they are. They must pass.
# 2. For each line, flips its first comparison: < becomes >=, > becomes <=,
#    <= becomes >, >= becomes <, == becomes !=, != becomes ==, && becomes ||.
#    Then builds and runs the tests, and puts the file back exactly as it was.
# 3. Rebuilds once at the end.
#
# CAUGHT      the tests fail with the line flipped: they check it.
# NOT CAUGHT  the tests still pass: no test checks that line.
# Exit 0 if every line is CAUGHT, 1 if any is NOT CAUGHT, 2 for anything
# else (not a git repo, tests already failing, no comparison found).
#
# BUILD and TEST default to the VM commands in AGENTS.md. To use others:
#   BUILD="cmake --build build-mac" TEST="ctest --test-dir build-mac" sh scripts/mutate-check.sh

BUILD=${BUILD:-"cmake --build build"}
# The time limit matters: a flipped comparison can turn a loop into one that
# never ends, and a hung test must count as a failed test, not a hung check.
TEST=${TEST:-"ctest --test-dir build --timeout 60"}
OPS="<=:>,>=:<,==:!=,!=:==,&&:||,<:>=,>:<="

# Pi's VM can set TMPDIR to an empty string, or to a folder that only exists
# on the Mac; fall back to /tmp.
tmp=${TMPDIR:-/tmp}
[ -d "$tmp" ] && [ -w "$tmp" ] || tmp=/tmp
log=$(mktemp "$tmp/mutate-log.XXXXXX") || exit 2
backup=$(mktemp "$tmp/mutate-orig.XXXXXX") || exit 2
current=""

run() {  # build, then test; output goes to $log. Returns 3 if the build fails.
  sh -c "$BUILD" >"$log" 2>&1 || return 3
  sh -c "$TEST" >>"$log" 2>&1
}

flip() {  # print the line with its first comparison flipped (unchanged if none)
  printf '%s\n' "$1" | awk -v ops="$OPS" '{
    n = split(ops, pairs, ",")
    for (i = 1; i <= n; i++) {
      split(pairs[i], ab, ":")
      pos = index($0, " " ab[1] " ")
      if (pos > 0 && (best == 0 || pos < best)) { best = pos; from = ab[1]; to = ab[2] }
    }
    if (best == 0) { print; exit }
    print substr($0, 1, best) to substr($0, best + 1 + length(from))
  }'
}

restore() {  # put $current back from $backup
  [ -n "$current" ] || return 0
  # cat (not cp -p) so the file gets a new time and make rebuilds it.
  cat "$backup" > "$current"
  if ! cmp -s "$backup" "$current"; then
    echo "WARNING: $current differs from the original. The original is in $backup." >&2
    exit 2
  fi
  current=""
}

finish() {
  restore
  sh -c "$BUILD" >/dev/null 2>&1 || echo "WARNING: rebuild failed; run: $BUILD" >&2
  rm -f "$backup" "$log"
}
trap 'finish; exit 2' INT TERM

# Lines to check, one "file:line" per line.
if [ $# -gt 0 ]; then
  targets=$*
else
  # The VM runs as root on a folder the Mac user owns; git refuses that
  # unless told the folder is safe. These git calls only read.
  git() { command git -c safe.directory='*' "$@"; }
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repository" >&2; exit 2; }
  targets=$(
    git diff -U0 HEAD -- src/ | awk '
      /^\+\+\+ b\// { file = substr($0, 7) }
      /^@@/ { split($3, a, ","); line = substr(a[1], 2) + 0; next }
      /^\+/ && !/^\+\+\+/ { print file ":" line; line++ }'
    git ls-files --others --exclude-standard -- src/ | while read -r f; do
      awk -v f="$f" '{ print f ":" NR }' "$f"
    done
  )
fi

# Keep only lines with a comparison to flip.
checks=""
for t in $targets; do
  f=${t%:*}; n=${t##*:}
  case $n in ''|*[!0-9]*) echo "usage: sh $0 [FILE:LINE ...]" >&2; exit 2 ;; esac
  [ -f "$f" ] || { echo "no such file: $f" >&2; exit 2; }
  text=$(sed -n "${n}p" "$f")
  if [ "$(flip "$text")" != "$text" ]; then
    checks="$checks $t"
  elif [ $# -gt 0 ]; then
    echo "No comparison (like a < b, with spaces) on $t:"; echo "  $text"
    exit 2
  fi
done
if [ -z "$checks" ]; then
  echo "No changed comparisons in src/ to check."
  rm -f "$backup" "$log"; exit 2
fi

echo "Running the tests as they are..."
if ! run; then
  echo "The tests must pass before this check. Last lines:"
  tail -n 5 "$log"
  rm -f "$backup" "$log"; exit 2
fi

caught=0; missed=0
for t in $checks; do
  f=${t%:*}; n=${t##*:}
  text=$(sed -n "${n}p" "$f")
  new=$(flip "$text")
  cp "$f" "$backup"; current=$f
  awk -v n="$n" -v new="$new" 'NR == n { print new; next } { print }' "$backup" > "$f"
  run; rc=$?
  restore
  echo
  echo "$t"
  echo "  was: $(echo "$text" | sed 's/^ *//')"
  echo "  now: $(echo "$new" | sed 's/^ *//')"
  if [ $rc -eq 3 ]; then
    echo "  RESULT: did not build when flipped; not checked."
  elif [ $rc -ne 0 ]; then
    echo "  RESULT: CAUGHT. The tests fail when this line is flipped."
    caught=$((caught + 1))
  else
    echo "  RESULT: NOT CAUGHT. The tests still pass with this line flipped. No test checks it."
    missed=$((missed + 1))
  fi
done

finish
echo
echo "mutate-check: $caught caught, $missed not caught. Every file is back as it was."
[ "$missed" -eq 0 ]
