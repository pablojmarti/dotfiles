---
description: Fix what a review or a bug file found. Run it in a new session.
argument-hint: "[review file or bug file]"
---
Fix what this file found: $@
If no file is named, use the newest file in docs/reviews/ or docs/bugs/.

Follow AGENTS.md, including "Done means". This fixes code that is already built; it is not a new feature. Do not commit.

1. Read the file, git status and git diff. For a review file, also read the feature's entry in docs/FEATURES.md and its walkthrough. For a bug file, also read the code its Cause names, and run `sh scripts/check-bug.sh --again <the bug file>` (in the VM, where the play check runs): it reruns the Reproduce command. Quote its "reproduced:" line. If it prints NOT REPRODUCED, the bug no longer shows: stop and tell me. If it exits 2, stop and tell me what it printed.
2. List what you will fix. For a review file: every Must fix item, and every Should fix item in the same files. For a bug file: its Fix. For each, say in plain words what you will change. If you think a finding or a cause is wrong, say why, with file:line, and do not fix it. If the fixes need more than three code files, stop and tell me to run /checkpoint.

Then stop and wait for my OK. Change no files before it.

After my OK:
3. Fix only what the list names. If you cannot make a fix the way you listed it, stop and tell me why. Never switch to a different fix without my OK.
   For each test you add or change: write it first, run it against the code before your fix, and quote the failure line. A test that passes before the fix does not test the fix. For a bug file, at least one test calls the same function the game loop calls, with no mock of our own code, and needs no display.
   If scripts/mutate-check.sh exists, run `sh scripts/mutate-check.sh` with no arguments after your fixes and quote its last line. Every line must be CAUGHT. If you cannot get there without changing more than the list names, stop and tell me why.
4. Run the full test suite, the Sanitize command from AGENTS.md and the app. Quote both summary lines. For a bug file, run `sh scripts/check-bug.sh --fixed <the bug file>` and quote its last two lines. The bug is fixed only when it exits 0. If it prints STILL FAILS, the fix did not work: stop and tell me. If it prints NEW FAIL, the fix broke something else: stop and tell me. If it exits 2, the check could not run, which is not a pass: stop and tell me what it printed.
5. Add a short "Fixed" section to the existing walkthrough of the feature that has the problem: what was wrong, the cause, and the test's name. Write the cause as one line in this form, both parts in backticks: `src/game.c:42` `if (score > best) {` (the line as it is now, after your fix). Do not write a new walkthrough.
   Then run `sh scripts/check-refs.sh <the walkthrough>`. Correct your "Fixed" section until the check reports no problem in it. If it reports a problem in an older part of the walkthrough, leave that part alone and tell me. Quote the last line. Rewrite docs/NEXT.md, 30 lines or fewer; do not add to it. Do not tick, move or add features, and do not edit the review or bug file. Then run `sh scripts/check-docs.sh` and quote its last line. It must say OK.
6. For a review file: list the findings you left, and ask me which to add under "Ideas" in docs/FEATURES.md.
7. End with what changed, the test summary, the check-refs last line from step 5, and for a bug file the check-bug last line from step 4. Then tell me to start a new session and run /review. Then stop. Do not commit.
