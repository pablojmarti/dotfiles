#!/bin/sh
# Usage: sh scripts/check-refs.sh FILE...
# Checks a plan, review or walkthrough against the code. Run it from the
# project root. Prints one line per problem; exits 1 if there are any.
#
# 1. Every `backticked` name must exist:
#    - paths (src/ecs.h, SDL3/SDL_events.h) must exist; file:LINE must be in range
#    - names (ecs_get_component, SDLK_A) must appear as a whole word in the
#      folders in REF_DIRS, or be an installed command (ctest)
#    - a name followed by (new), like `src/admin_panel.c` (new), is one the
#      change will create: it must NOT exist yet
#      (only the exact text (new) counts; "(new test: ...)" does not)
#    - anything else (expressions, commands with spaces) is "not checked"
# 2. In a plan, each "## Feature" section may name at most MAX_FILES code
#    files. Tests and docs do not count.
# 3. A line number must point at the code quoted next to it (WRONG LINE):
#    - `src/court.c:145` `ball_x + (float)court_ball_width >= paddle_x`
#      (path:N, then right after it a backticked snippet), or
#    - `src/court.c`, line 145 (or lines 145-150), then a ``` code block
#      before the next heading: its first code line is the snippet.
#    The snippet must be in lines N to N+2 of the file (spaces squeezed).

REF_DIRS=${REF_DIRS:-"src tests scripts CMakeLists.txt vendor/sdl/include vendor/sdl3_ttf/include vendor/unity/src"}
MAX_FILES=${MAX_FILES:-3}

if [ $# -eq 0 ]; then
  echo "usage: sh $0 FILE..." >&2
  exit 2
fi

dirs=""
for d in $REF_DIRS; do [ -e "$d" ] && dirs="$dirs $d"; done

# Print "section<TAB>name<TAB>is_new" for every backticked name in a file.
names() {
  awk '
    /^#+ / { sec = $0 }
    {
      line = $0
      while (match(line, /`[^`]*`/)) {
        tok = substr(line, RSTART + 1, RLENGTH - 2)
        line = substr(line, RSTART + RLENGTH)
        isnew = (line ~ /^[ ]*\(new\)/)   # exactly (new); "(new declarations: ...)" is prose
        if (tok ~ / \(new\)$/) { sub(/ \(new\)$/, "", tok); isnew = 1 }
        print sec "\t" tok "\t" isnew
      }
    }' "$1"
}

# Print "path<TAB>N<TAB>snippet" for every line number quoted with code.
quoted_lines() {
  awk '
    function squeeze(x) { gsub(/[ \t]+/, " ", x); sub(/^ /, "", x); sub(/ $/, "", x); return x }
    /^[ ]*```/ {
      if (!fence) { fence = 1; want = (pend != "") } else { fence = 0; want = 0; pend = "" }
      next
    }
    fence {
      if (want && $0 ~ /[^ \t]/) { print pend "\t" squeeze($0); want = 0; pend = "" }
      next
    }
    /^#+ / { pend = "" }
    {
      line = $0
      while (match(line, /`[^`]*`/)) {
        tok = substr(line, RSTART + 1, RLENGTH - 2)
        line = substr(line, RSTART + RLENGTH)
        if (tok ~ /^[^ ]+:[0-9]+(-[0-9]+)?$/) {
          # the snippet must come right after it: `path:N` `code`
          if (match(line, /^[^`A-Za-z0-9,()]*`[^`]*`/) && match(line, /`[^`]*`/)) {
            n = tok; sub(/^.*:/, "", n); sub(/-.*$/, "", n)
            path = tok; sub(/:[0-9]+(-[0-9]+)?$/, "", path)
            snip = squeeze(substr(line, RSTART + 1, RLENGTH - 2))
            if (snip != "" && snip !~ /^[^ ]+:[0-9]/) print path "\t" n "\t" snip
          }
        } else if (tok !~ / / && tok ~ /\/|\.(c|h)$/) {
          pre = line; sub(/`.*$/, "", pre)
          if (match(pre, /[Ll]ines? [0-9]+/)) {
            n = substr(pre, RSTART, RLENGTH); sub(/^[^0-9]*/, "", n)
            pend = tok "\t" n
          }
        }
      }
    }' "$1"
}

# resolve NAME: print the file NAME points at (as exists() finds it).
resolve() {
  [ -e "$1" ] && { echo "$1"; return; }
  for d in $dirs; do [ -e "$d/$1" ] && { echo "$d/$1"; return; }; done
  find src tests scripts docs -name "$1" 2>/dev/null | head -n 1
}

is_path() {
  case $1 in */*|*.c|*.h|*.md|*.txt|*.sh|*.cmake) return 0 ;; esac
  return 1
}

# exists NAME: 0 if NAME (path, path:LINE or identifier) is in the code,
# 1 if not, 2 if it cannot be checked. Sets $why on failure.
exists() {
  name=${1%()}; line=""; why=""
  case $name in *" "*|*"*"*|"") return 2 ;; esac   # commands, globs
  case $name in
    *:[0-9]*) line=${name##*:}; line=${line%%-*}; name=${name%:*} ;;
  esac
  if is_path "$name"; then
    path=$name
    if [ ! -e "$path" ]; then           # try include folders, then by name
      for d in $dirs; do [ -e "$d/$name" ] && path="$d/$name" && break; done
    fi
    [ -e "$path" ] || path=$(find src tests scripts docs -name "$name" 2>/dev/null | head -n 1)
    if [ -z "$path" ] || [ ! -e "$path" ]; then why="no such file"; return 1; fi
    if [ -n "$line" ] && [ "$line" -gt "$(wc -l < "$path")" ]; then
      why="$path has only $(wc -l < "$path" | tr -d ' ') lines"; return 1
    fi
    return 0
  fi
  printf '%s' "$name" | grep -Eq '^[A-Za-z_][A-Za-z0-9_]*$' || return 2
  # SDL_oldnames.h lists SDL2 names only to make them fail; skip it.
  # (No --exclude: BusyBox grep in the VM does not have it.)
  # shellcheck disable=SC2086
  if grep -rlw -- "$name" $dirs 2>/dev/null | grep -qv 'SDL_oldnames\.h$' \
     || command -v "$name" >/dev/null 2>&1; then
    return 0
  fi
  why="not in the code"; return 1
}

found=0; missing=0; skipped=0
tab=$(printf '\t')
newline='
'
for file in "$@"; do
  refs=$(names "$file" | awk -F'\t' '{ print $3 "\t" $2 }' | sort -u)
  IFS=$newline
  for row in $refs; do
    IFS=' '
    is_new=${row%%"$tab"*}; ref=${row#*"$tab"}
    exists "$ref"; rc=$?
    if [ "$is_new" = 1 ]; then
      if [ $rc -eq 0 ]; then
        echo "NOT NEW    $ref  (marked (new) but it already exists; in $file)"
        missing=$((missing + 1))
      else
        skipped=$((skipped + 1))
      fi
    elif [ $rc -eq 0 ]; then
      found=$((found + 1))
    elif [ $rc -eq 1 ]; then
      echo "NOT FOUND  $ref  ($why; in $file)"; missing=$((missing + 1))
    else
      skipped=$((skipped + 1))
    fi
  done
  IFS=' '

  # Line numbers next to quoted code must point at that code.
  quoted=$(quoted_lines "$file" | sort -u)
  IFS=$newline
  for row in $quoted; do
    IFS=' '
    qpath=${row%%"$tab"*}; rest=${row#*"$tab"}
    qline=${rest%%"$tab"*}; snip=${rest#*"$tab"}
    qfile=$(resolve "$qpath")
    [ -n "$qfile" ] && [ -f "$qfile" ] || continue   # NOT FOUND covers it
    at=$(SNIP="$snip" awk -v n="$qline" '
      function squeeze(x) { gsub(/[ \t]+/, " ", x); sub(/^ /, "", x); sub(/ $/, "", x); return x }
      BEGIN { s = squeeze(ENVIRON["SNIP"]) }
      index(squeeze($0), s) {
        if (NR >= n && NR <= n + 2) { ok = 1; exit }
        if (!first) first = NR
      }
      END { if (!ok) print first + 0 }' "$qfile")
    [ -z "$at" ] && continue
    if [ "$at" -gt 0 ]; then where="it is at line $at"; else where="it is not in $qfile"; fi
    echo "WRONG LINE $qpath:$qline  (\`$snip\` is not in lines $qline to $((qline + 2)); $where; in $file)"
    missing=$((missing + 1))
  done
  IFS=' '

  # Plans: count the code files each feature names.
  big=$(names "$file" | awk -F'\t' -v max="$MAX_FILES" '
    $1 ~ /^##+ .*[Ff]eature/ {
      f = $2; sub(/:[0-9].*$/, "", f); n = split(f, p, "/"); base = p[n]
      if (f !~ /\/|\.(c|h|cmake|txt)$/) next
      if (f ~ /^tests\// || base ~ /^test_/ || f ~ /^docs\// || base ~ /\.md$/) next
      if (!seen[$1 SUBSEP base]++) { count[$1]++; list[$1] = list[$1] " " base }
    }
    END { for (s in count) if (count[s] > max) print s "\t" count[s] "\t" list[s] }')
  IFS=$newline
  for row in $big; do
    IFS=$tab
    # shellcheck disable=SC2086
    set -- $row
    echo "TOO BIG    $1: $2 code files (max $MAX_FILES):$3. Split it."
    missing=$((missing + 1))
  done
  IFS=' '
done

echo "check-refs: $found found, $missing problems, $skipped not checked"
[ "$missing" -eq 0 ]
