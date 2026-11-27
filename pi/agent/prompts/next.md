---
description: Pick up where the last session stopped
---
Read docs/NEXT.md, docs/FEATURES.md and git status.
In six lines or fewer, tell me: where we stopped, anything left uncommitted, and the next command to run.
If git status shows an uncommitted file in docs/bugs/, or the newest file in docs/reviews/ is uncommitted with the verdict Fix first, and docs/NEXT.md does not say it was fixed, the next command is /fix <that file>: say so, then wait. Otherwise:
The next item is the first unticked one in docs/FEATURES.md, outside the Ideas section. If none is left, it is the first idea.
If scripts/check-next.sh exists, run `sh scripts/check-next.sh` and quote its last line. If it says STALE, the plan of that item quotes code that is not there: quote the STALE lines, tell me to run /plan for the item again or to remove it from docs/FEATURES.md, and recommend no /feature. Then wait.
Check that item against "Feature or plan?" in AGENTS.md, reading the code it would touch:
- If it passes all three questions: tell me to run /feature <item>, with a time estimate.
- If any question fails: tell me to run /plan <item>, and name the question it fails and why.
If docs/NEXT.md suggests something else, say so.
Then wait. Change nothing.
