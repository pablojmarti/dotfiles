#!/bin/sh
# Usage: sh scripts/check-bug.sh [--again | --fixed] docs/bugs/YYYY-MM-DD-name.md
# Reruns a bug file's Reproduce command and looks for its failing line.
# Run it from the project root, where the command runs. The play check runs
# only in the VM, so use this script there.
#
# The Reproduce section must open with two lines, each in backticks:
#   ## Reproduce
#   `sh scripts/play-check.sh`
#   `FAIL  object C (rectangle 10x10) jumped 740 pixels in one frame, ...`
# The first is the command; the second is a piece of the line it prints
# (spaces are squeezed before matching; the rest of the line may differ).
#
# Modes:
#   (none)    used by /bug: the line must be in the output (else NOT
#             REPRODUCED), and the date in the file name must be today's
#             (else WRONG DATE).
#   --again   used by /fix step 1: the line must still be in the output.
#             No date check, so a fix on another day works.
#   --fixed   used by /fix step 4: the line must be gone (else STILL FAILS),
#             and no new failure line may appear (else NEW FAIL).
#
# The first two modes save the command's output to
# build/check-bug/<bug file name>.before.txt. --fixed needs that file:
#   - STILL FAILS also when the quoted line is there with other numbers
#     (the jump moved from frame 74 to frame 80 is still the jump).
#   - NEW FAIL: a line that starts with the quoted line's first word (FAIL)
#     and was not in the saved output. Numbers are ignored in this
#     comparison, so "from frame 1037" and "from frame 811" are the same
#     line, but "the game ended before it showed a frame" is new.
#     This only works when the quoted line starts with a word in capitals,
#     like FAIL or ERROR; otherwise the script says the check was skipped.
#
# Exit 0: passed. Exit 1: NOT REPRODUCED, STILL FAILS, NEW FAIL or WRONG DATE.
# Exit 2: blocked, not a pass: bad usage, no command in the right form, no
# saved output for --fixed, or the command could not run (exit 2, 124, 126
# or 127 without the line).
# CHECK_BUG_LIMIT sets the time limit for the command (default 900 s).

LIMIT=${CHECK_BUG_LIMIT:-900}

mode=new
case $1 in
  --again) mode=again; shift ;;
  --fixed) mode=fixed; shift ;;
  -*) echo "check-bug: unknown option $1" >&2; exit 2 ;;
esac
if [ $# -ne 1 ]; then
  echo "usage: sh $0 [--again | --fixed] BUG_FILE" >&2
  exit 2
fi
file=$1
[ -f "$file" ] || { echo "check-bug: could not run: no file $file"; exit 2; }

# The first two non-blank lines after the Reproduce heading, backticks
# removed. Prints nothing for a line that is not wholly in backticks.
form() {
  awk -v want="$1" '
    /^#+[ \t]*Reproduce/ { inside = 1; n = 0; next }
    inside && /^#/ { exit }
    inside && /[^ \t]/ {
      n++
      if (n == want) {
        line = $0
        sub(/^[ \t]+/, "", line); sub(/[ \t]+$/, "", line)
        if (line ~ /^`[^`]+`$/) print substr(line, 2, length(line) - 2)
        exit
      }
    }
  ' "$file"
}
cmd=$(form 1)
want=$(form 2)
if [ -z "$cmd" ] || [ -z "$want" ]; then
  echo "check-bug: could not run: the Reproduce section must open with the command in backticks, then the failing line in backticks, each on its own line"
  exit 2
fi

saved="build/check-bug/$(basename "$file").before.txt"
if [ "$mode" = fixed ] && [ ! -f "$saved" ]; then
  echo "check-bug: could not run: no saved output $saved. Run sh $0 --again $file on the code before the fix first."
  exit 2
fi

problems=0
if [ "$mode" = new ]; then
  today=$(date +%F)
  name=$(basename "$file")
  case $name in
    "$today"-*) ;;
    *) echo "WRONG DATE $name: the name must start with today's date, $today"
       problems=$((problems + 1)) ;;
  esac
fi

out=$(mktemp "${TMPDIR:-/tmp}/check-bug.XXXXXX") || { echo "check-bug: could not run: no temp file"; exit 2; }
trap 'rm -f "$out"' EXIT
echo "check-bug: running: $cmd"
if command -v timeout >/dev/null 2>&1; then
  timeout "$LIMIT" sh -c "$cmd" </dev/null >"$out" 2>&1
else
  sh -c "$cmd" </dev/null >"$out" 2>&1
fi
rc=$?

# match_line [nonum]: print the first output line that holds the quoted line.
# With nonum, every run of digits counts as the same number.
match_line() {
  awk -v want="$want" -v nonum="$1" '
    function norm(s) {
      gsub(/[ \t]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s)
      if (nonum) gsub(/[0-9]+/, "#", s)
      return s
    }
    BEGIN { w = norm(want) }
    index(norm($0), w) > 0 { print; exit }
  ' "$out"
}
found=$(match_line "")
[ "$mode" = fixed ] && [ -z "$found" ] && found=$(match_line 1)

if [ -z "$found" ]; then
  case $rc in
    2|124|126|127)
      echo "check-bug: could not run: the command exited $rc. Its last lines:"
      tail -n 5 "$out" | sed 's/^/  /'
      exit 2 ;;
  esac
fi

case $mode in
  new|again)
    mkdir -p build/check-bug && cp "$out" "$saved" ||
      echo "check-bug: could not save the output to $saved; /fix needs it" 
    if [ -n "$found" ]; then
      echo "reproduced: $found"
    else
      echo "NOT REPRODUCED: the command exited $rc and never printed: $want"
      echo "  Its last lines:"
      tail -n 5 "$out" | sed 's/^/  /'
      problems=$((problems + 1))
    fi ;;
  fixed)
    if [ -n "$found" ]; then
      echo "STILL FAILS: $found"
      problems=$((problems + 1))
    else
      echo "gone: the command exited $rc and no longer prints: $want"
      echo "  Its last line: $(tail -n 1 "$out")"
    fi
    word=${want%% *}
    case $word in
      *[!A-Z]*|"") echo "check-bug: new failure lines not checked: the quoted line does not start with a word in capitals" ;;
      *)
        new=$(awk -v word="$word" -v saved="$saved" '
          function norm(s) { gsub(/[ \t]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s); gsub(/[0-9]+/, "#", s); return s }
          BEGIN { while ((getline l < saved) > 0) if (l ~ "^[ \t]*" word "[ \t]") seen[norm(l)] = 1 }
          $0 ~ "^[ \t]*" word "[ \t]" && !(norm($0) in seen) { print }
        ' "$out")
        if [ -n "$new" ]; then
          echo "$new" | while IFS= read -r l; do echo "NEW FAIL: $l"; done
          problems=$((problems + $(echo "$new" | wc -l)))
        else
          echo "no new $word lines since the saved output ($saved)"
        fi ;;
    esac ;;
esac

echo "check-bug: $problems problem$( [ "$problems" -eq 1 ] || echo s)"
[ "$problems" -eq 0 ] && exit 0
exit 1
