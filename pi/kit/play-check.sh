#!/bin/sh
# Usage: sh scripts/play-check.sh [GAME COMMAND]
#
# Plays the game with no window and no person, then says what moved, what
# was drawn and what looks wrong. It runs in the VM (Linux only), from any
# folder: it moves to the project root (the folder above scripts/) first.
# It changes no project file; everything goes to build/play/.
# CTest runs it as one of the project's tests; on the Mac it exits 2, which
# CTest shows as skipped.
#
# How: scripts/sdl-probe.c is built as a small library and loaded into the
# game when it starts. It records every rectangle, image and text the game
# draws, gives the game a fake clock (60 frames per second, no waiting) and
# the keys below, and stops the game after PLAY_FRAMES frames.
#
# GAME COMMAND defaults to the "- Play:" line in AGENTS.md, for example
#   - Play: `./build/depression`
# and, if there is none, to the "- Run:" line.
#
# Settings (environment variables):
#   PLAY_FRAMES     frames to play                         (3600 = 60 seconds)
#   PLAY_KEYS       the input plan, entries separated by spaces:
#                     W:10-120          hold W from frame 10 to frame 120
#                     R:500             tap R at frame 500
#                     click:400,300:90  left click at window pixel (400,300)
#                                       at frame 90
#                     type:help:200     type "help" from frame 200, one key
#                                       every two frames
#                   Default: the lines of scripts/play-keys.txt, if it exists.
#                   A picture is saved two frames after each entry starts.
#   PLAY_MAX_SPEED  fastest any object may go, in pixels per second (no limit)
#   PLAY_TIMEOUT    real seconds before the game is stopped as hung     (60)
#   PLAY_EXPECT_EXIT=1  the key plan quits the game; ending early is fine
#
# FAIL lines (exit 1):
#   - an object jumps further in one frame than it could travel
#   - something is drawn outside the window
#   - the game ends by itself, crashes, or stops showing frames
#   - an object goes faster than PLAY_MAX_SPEED
# WARN lines (exit 0): things to explain, like an object that crosses the
# window in a perfectly straight line.
# ACCEPTED lines: FAIL lines the client has accepted for now. They are listed
# in scripts/play-accept.txt, one per line: a piece of the FAIL line, then
# " # " and the reason. Only the client edits that file. An accepted line
# does not fail the check.
# Exit 2: the check could not run.

OUT=${PLAY_OUT:-build/play}
FRAMES=${PLAY_FRAMES:-3600}
FPS=${PLAY_FPS:-60}
LIMIT=${PLAY_TIMEOUT:-60}
here=$(cd "$(dirname "$0")" && pwd)

stop() { echo "play-check: could not run: $1"; exit 2; }

cd "$here/.." || stop "cannot enter the project root."

[ "$(uname -s)" = "Linux" ] || stop "it needs Linux; run it in the VM. On the Mac, look at the real window."
[ -f "$here/sdl-probe.c" ] || stop "scripts/sdl-probe.c is missing."

if [ $# -gt 0 ]; then
  GAME="$*"
else
  GAME=$(sed -n 's/^- Play: *`\([^`]*\)`.*/\1/p' AGENTS.md 2>/dev/null | head -1)
  [ -n "$GAME" ] || GAME=$(sed -n 's/^- Run: *`\([^`]*\)`.*/\1/p' AGENTS.md 2>/dev/null | head -1)
  GAME=$(printf '%s' "$GAME" | sed 's/^timeout [0-9][0-9]* //')
fi
[ -n "$GAME" ] || stop "no game command. Give one, or add a Play: line to AGENTS.md."

sdl_h=$(find vendor -type f -path '*/include/SDL3/SDL.h' 2>/dev/null | head -1)
if [ -n "$sdl_h" ]; then
  inc="-I${sdl_h%/SDL3/SDL.h}"
else
  inc=$(pkg-config --cflags sdl3 2>/dev/null) || stop "cannot find SDL3/SDL.h under vendor/."
fi

mkdir -p "$OUT" || stop "cannot create $OUT."
rm -f "$OUT"/trace.tsv "$OUT"/frame-*.png "$OUT"/frame-*.bmp "$OUT"/game-output.txt

# shellcheck disable=SC2086
if ! ${CC:-cc} -shared -fPIC -O1 -w $inc "$here/sdl-probe.c" -o "$OUT/sdl-probe.so" >"$OUT/probe-build.txt" 2>&1; then
  tail -5 "$OUT/probe-build.txt"
  stop "the probe did not compile (see $OUT/probe-build.txt)."
fi

if [ -z "${PLAY_KEYS+x}" ] && [ -f scripts/play-keys.txt ]; then
  PLAY_KEYS=$(grep -v '^ *#' scripts/play-keys.txt | tr '\n' ' ')
fi
PLAY_KEYS=${PLAY_KEYS:-}
SHOTS=${PLAY_SHOTS:-"1 $((FRAMES / 2)) $((FRAMES - 1))"}

case "$OUT" in /*) abs_out=$OUT ;; *) abs_out=$PWD/$OUT ;; esac

# DISPLAY is set because some games look for it before they start SDL.
# SDL itself uses its "dummy" video driver here and never opens a display.
DISPLAY="${DISPLAY:-:play-check}" SDL_VIDEO_DRIVER=dummy SDL_VIDEODRIVER=dummy SDL_AUDIO_DRIVER=dummy SDL_AUDIODRIVER=dummy \
SDL_RENDER_DRIVER=software \
PLAY_OUT="$abs_out" PLAY_FRAMES="$FRAMES" PLAY_FPS="$FPS" PLAY_KEYS="$PLAY_KEYS" PLAY_SHOTS="$SHOTS" \
LD_PRELOAD="$abs_out/sdl-probe.so" \
  timeout "$LIMIT" sh -c "$GAME" >"$OUT/game-output.txt" 2>&1
status=$?

[ -f "$OUT/trace.tsv" ] || : >"$OUT/trace.tsv"

awk -F '\t' -v frames="$FRAMES" -v fps="$FPS" -v status="$status" -v limit="$LIMIT" \
    -v game="$GAME" -v keys="$PLAY_KEYS" -v maxspeed="${PLAY_MAX_SPEED:-0}" \
    -v expect_exit="${PLAY_EXPECT_EXIT:-0}" -v out="$OUT" -v acceptfile="${PLAY_ACCEPT:-scripts/play-accept.txt}" '
function abs(v) { return v < 0 ? -v : v }
function num(v) { return sprintf("%.0f", v) }
function range(a, b) { return (num(a) == num(b)) ? num(a) : num(a) " to " num(b) }
function kind(k) { return k == "R" ? "rectangle" : (k == "T" ? "image" : "text") }
function fail(s) { fails[++nf] = s }
function warn(s) { warns[++nw] = s }

# Look at one object in the frame that just ended.
function look(id, f,    x, y, w, h, cls, dx, dy, step, home, thr) {
  x = cx[id]; y = cy[id]; w = cw[id]; h = ch[id]; cls = ccls[id]
  if (!(id in fx)) {
    ids[++ni] = id; fx[id] = x; fy[id] = y; ow[id] = w; oh[id] = h; ocls[id] = cls
    mnx[id] = x; mxx[id] = x; mny[id] = y; mxy[id] = y
  }
  if (x < mnx[id]) mnx[id] = x; if (x > mxx[id]) mxx[id] = x
  if (y < mny[id]) mny[id] = y; if (y > mxy[id]) mxy[id] = y
  seen[id]++
  # An empty rectangle (a bar at zero, say) shows nothing, so it cannot be off screen.
  if (W > 0 && w > 0 && h > 0 && (x + w <= 0 || x >= W || y + h <= 0 || y >= H)) {
    offrun[id]++; offtot[id]++
    if (offrun[id] == 1) { ofirst[id] = f; ofx[id] = x; ofy[id] = y }
    if (offrun[id] == 30 && !(id in offat)) { offat[id] = ofirst[id]; offx[id] = ofx[id]; offy[id] = ofy[id] }
  } else offrun[id] = 0
  if ((id in lf) && lf[id] == f - 1 && pcnt[cls] == cnt[cls]) {
    dx = x - lx[id]; dy = y - ly[id]; step = sqrt(dx * dx + dy * dy)
    if (step > 0.001) {
      mv[id] = 1
      thr = 3 * ps[id] + 30
      home = (abs(x - fx[id]) < 0.5 && abs(y - fy[id]) < 0.5)
      if (step > thr && !home) {
        nj[id]++
        if (nj[id] == 1) { jf[id] = f; jd[id] = step; jfrom[id] = "(" num(lx[id]) "," num(ly[id]) ")"; jto[id] = "(" num(x) "," num(y) ")" }
      } else if (step > thr) {
        nr[id]++
      } else {
        if (step > ms[id]) ms[id] = step
        ps[id] = step
      }
    } else ps[id] = 0
  }
  lx[id] = x; ly[id] = y; lf[id] = f
}

$1 == "W" { W = $2; H = $3; next }
$1 == "N" { notes[++nn] = $2; next }
$1 == "END" { endf = $2; endwhy = $3; next }
$1 == "P" {
  for (i = 1; i <= nfid; i++) look(fid[i], $2)
  split("", pcnt); for (c in cnt) pcnt[c] = cnt[c]
  split("", cnt); nfid = 0; shown++
  next
}
$1 == "R" || $1 == "T" || $1 == "X" {
  cls = ($1 == "X") ? "X" : $1 ":" num($5) "x" num($6)
  id = cls "#" (++cnt[cls])
  fid[++nfid] = id
  cx[id] = $3; cy[id] = $4; cw[id] = $5; ch[id] = $6; ccls[id] = cls
  if ($1 == "X") {
    cur_text[id] = $7
    if (!($7 in tfirst)) { tfirst[$7] = $2; tpos[$7] = "(" num($3) "," num($4) ")"; texts[++nt] = $7 }
  }
}

END {
  while ((getline line < acceptfile) > 0) {
    if (line ~ /^ *#/ || line ~ /^ *$/) continue
    cut = index(line, " # ")
    apat[++na] = (cut > 0) ? substr(line, 1, cut - 1) : line
    awhy[na] = (cut > 0) ? substr(line, cut + 3) : "no reason given"
  }
  secs = shown / fps
  printf "play-check: ran \"%s\" for %d frames (%.0f seconds of game time)", game, shown, secs
  if (W > 0) printf ", window %dx%d", W, H
  printf "\n"
  printf "Keys pressed: %s\n", (keys == "" ? "none" : keys)

  # ---- did the run finish? ----
  if (shown == 0) {
    if (status == 124 || status == 137 || status == 143)
      fail("the game showed no frame in " limit " real seconds and was stopped. See " out "/game-output.txt.")
    else
      fail("the game ended before it showed a frame (exit status " status "). See " out "/game-output.txt.")
  } else if (endwhy == "exit") {
    if (expect_exit != 1)
      fail("the game ended by itself at frame " endf " (after " sprintf("%.1f", endf / fps) " seconds of game time, exit status " status "). The run was meant to last " frames " frames.")
  } else if (endwhy != "limit") {
    if (status == 124 || status == 137 || status == 143)
      fail("the game stopped showing frames after frame " shown " and was stopped after " limit " real seconds (a hang).")
    else
      fail("the game crashed or was killed after frame " shown " (exit status " status "). See " out "/game-output.txt.")
  }

  # ---- what never moves ----
  for (i = 1; i <= ni; i++) {
    id = ids[i]; c = ocls[id]
    if (!(c in cseen)) { cseen[c] = 1; clist[++ncl] = c }
    if (!mv[id]) {
      still[c]++
      if ((id in offat) || (offtot[id] > 0 && offtot[id] == seen[id])) {
        offstill[c]++
        if (!(c in offex)) offex[c] = "(" num(ofx[id]) "," num(ofy[id]) ")"
      }
    }
  }
  print ""
  print "What was drawn:"
  for (j = 1; j <= ncl; j++) {
    c = clist[j]
    if (c == "X" || !still[c]) continue
    printf "  %d %s%s of %s that never move%s\n", still[c], kind(substr(c, 1, 1)), (still[c] > 1 ? "s" : ""), substr(c, 3), (still[c] > 1 ? "" : "s")
    if (offstill[c])
      fail(offstill[c] " " kind(substr(c, 1, 1)) (offstill[c] > 1 ? "s" : "") " of " substr(c, 3) " " (offstill[c] > 1 ? "are" : "is") " drawn outside the " W "x" H " window (one is at " offex[c] ").")
  }

  # ---- what moves ----
  label = 0; anymove = 0
  for (i = 1; i <= ni; i++) {
    id = ids[i]; c = ocls[id]
    if (!mv[id] || c == "X") continue
    anymove = 1
    name = sprintf("%c", 65 + (label++ % 26))
    what = "object " name " (" kind(substr(c, 1, 1)) " " num(ow[id]) "x" num(oh[id]) ")"
    speed = ms[id] * fps
    printf "  %s  %s %sx%s  x %s  y %s  top speed %s px/s", name, kind(substr(c, 1, 1)), num(ow[id]), num(oh[id]), range(mnx[id], mxx[id]), range(mny[id], mxy[id]), num(speed)
    if (nr[id]) printf "  (went back to its start position %d time%s)", nr[id], (nr[id] > 1 ? "s" : "")
    printf "\n"
    if (nj[id])
      fail(what " jumped " num(jd[id]) " pixels in one frame, from " jfrom[id] " to " jto[id] " at frame " jf[id] ". It jumped " nj[id] " time" (nj[id] > 1 ? "s" : "") " in this run.")
    if (id in offat)
      fail(what " is drawn outside the " W "x" H " window from frame " offat[id] ", at (" num(offx[id]) "," num(offy[id]) ").")
    if (maxspeed > 0 && speed > maxspeed + 0.5)
      fail(what " reached " num(speed) " pixels per second. The limit given is " maxspeed ".")
    if (W > 0 && num(mny[id]) == num(mxy[id]) && mxx[id] - mnx[id] >= W / 2)
      warn(what " crosses the window left to right but its y never changes (always " num(mny[id]) ").")
    if (H > 0 && num(mnx[id]) == num(mxx[id]) && mxy[id] - mny[id] >= H / 2)
      warn(what " crosses the window top to bottom but its x never changes (always " num(mnx[id]) ").")
  }
  if (shown > 0 && !anymove) warn("nothing on screen moved in " shown " frames.")

  # ---- text ----
  for (i = 1; i <= nt; i++)
    printf "  text \"%s\" first shown at frame %d at %s\n", texts[i], tfirst[texts[i]], tpos[texts[i]]
  for (i = 1; i <= ni; i++) {
    id = ids[i]
    if (ocls[id] != "X") continue
    if ((id in offat) || (offtot[id] > 0 && offtot[id] == seen[id]))
      fail("text \"" cur_text[id] "\" is drawn outside the " W "x" H " window, at (" num(ofx[id]) "," num(ofy[id]) "), from frame " ofirst[id] ".")
  }
  if (shown > 0 && nt == 0) print "  no text"

  for (i = 1; i <= nn; i++) warn("probe: " notes[i])

  print ""
  kept = 0
  for (i = 1; i <= nf; i++) {
    hit = 0
    for (j = 1; j <= na; j++) if (index(fails[i], apat[j]) > 0) { hit = j; break }
    if (hit) { nacc++; print "ACCEPTED  " fails[i] "  [accepted by the client in " acceptfile ": " awhy[hit] "]" }
    else fails[++kept] = fails[i]
  }
  nf = kept
  for (i = 1; i <= nf; i++) print "FAIL  " fails[i]
  for (i = 1; i <= nw; i++) print "WARN  " warns[i]
  if (nf + nw + nacc > 0) print ""
  print "Pictures and the full record are in " out "/ (frame-*.png, trace.tsv)."
  acc = (nacc > 0) ? sprintf(", %d accepted", nacc) : ""
  if (nf > 0) {
    printf "play-check: FAIL, %d problem%s%s, %d warning%s.\n", nf, (nf > 1 ? "s" : ""), acc, nw, (nw == 1 ? "" : "s")
    exit 1
  }
  printf "play-check: PASS%s, %d warning%s.\n", acc, nw, (nw == 1 ? "" : "s")
}' "$OUT/trace.tsv"
