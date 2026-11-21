---
description: Find the cause of one bug and write it down. Fixes nothing. Run it in a new session.
argument-hint: "<what you saw, or a FAIL line>"
---
A bug: $@

Find the cause and write it in a bug file. Then stop. This command fixes nothing; /fix does that later, in a new session.
Change no files except the bug file. Never edit, format, stage, commit, reset, checkout, stash or clean.

1. Reproduce it. Build with the Build command, then run one command that shows the bug, and quote the line that fails. If the bug is a line from scripts/play-check.sh, run the play check as AGENTS.md says, with the keys from scripts/play-keys.txt. The command must run the game or a test. A command that only reads the source (grep, cat, sed) shows the code, not the bug, and does not count. If nothing you run shows the bug, stop: tell me what you ran and what it printed, and describe in one line the test that would show it.
2. Find the cause. Read the code the failing line points to. Name the cause as path:line and quote that line, copied exactly from the file. Show, step by step, how that line produces the exact numbers or words in the failing line. If your cause cannot produce those exact numbers, it is the wrong cause: look again.
3. Write docs/bugs/YYYY-MM-DD-short-name.md, with today's date, and these sections:
   - Symptom: what was seen, in one or two lines.
   - Reproduce: it opens with two lines, each wholly in backticks and on its own line: first the one command you ran, then the failing line it printed, copied exactly. Example:
     `sh scripts/play-check.sh`
     `FAIL  object C (rectangle 10x10) jumped 740 pixels in one frame, from (760,295) to (20,295) at frame 74. It jumped 5 times in this run.`
     Anything else (the build command, notes) goes after these two lines.
   - Cause: first, one line in this exact form, both parts in backticks: `src/game.c:42` `if (score > best) {` (the path and line number, then the code on that line, copied exactly). Then the steps from step 2.
   - Fix: in plain words, and which files it changes. If the cause is in code no test can call (inside main, or behind `#if !defined(TESTING)`), the fix moves that code into a function a test can call; say which. If it needs more than three code files, say so: I run /checkpoint, not /fix.
   - Test: in plain words, one test that fails now and passes after the fix. It calls the same function the game loop calls, with no mock of our own code.
4. Run `sh scripts/check-refs.sh docs/bugs/<the file name>`. If it prints WRONG LINE or NOT FOUND, correct the bug file (WRONG LINE says where the code really is) and run it again, until its last line says 0 problems. Quote that last line.
5. Run `sh scripts/check-bug.sh docs/bugs/<the file name>`. It runs your Reproduce command again and needs your quoted line in its output; it also checks today's date in the file name. Run it in the VM, where you are; the play check runs only there. If it prints WRONG DATE, rename the file. If it prints NOT REPRODUCED, your command does not show the bug: run the right command and correct the Reproduce section, then run check-bug again. Repeat until it exits 0, and quote its last two lines. If it exits 2 (could not run, or the script is missing), or you cannot make your command show the bug, stop and tell me what it printed. Never change the quoted line so that it matches something else.
6. Tell me, in five lines or fewer: the failing line, the cause with file:line, and the fix in plain words.
   Then give me this exact line to paste into a new session: /fix docs/bugs/<the file name>

Then stop. Change nothing else, even if the fix looks small.
