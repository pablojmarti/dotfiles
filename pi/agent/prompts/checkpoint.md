---
description: Decide whether to keep going, refactor or rethink
---
Run a checkpoint on this project. Change no code.
First, if scripts/check-red.sh exists, run `sh scripts/check-red.sh` and quote every RED and ASK line and its last line. A failing test says the code and the test disagree; it does not say which one is wrong.
- For every ASK line: do not name a cause and do not propose a fix, for the code or for the test. The person may have changed the code on purpose because the screen was wrong. Read the commits the script names, then write the question for me: what the test expects, what the code does now, and which commit changed it.
- With any ASK line the verdict is Ask first (below), whatever else you find.
- With any RED line the verdict cannot be Keep going.
Next, if scripts/check-next.sh exists, run `sh scripts/check-next.sh` and quote its STALE lines and its last line. STALE means the plan of the next feature quotes code that is not there.
Then read docs/PROJECT.md, docs/FEATURES.md, docs/NEXT.md, the last five walkthroughs, git log and the code. Find the previous checkpoint in docs/checkpoints/ and list what came after it: run `git log --oneline` back to its date, and `ls docs/bugs/ docs/reviews/`. Check:
1. Did recent features take longer, or touch more files, than their size suggests?
2. Has the same kind of bug come back? Count from the lists above, not from the five walkthroughs alone: a function or a test named in two or more bug files, a feature with more than one review file or more than one fix commit. Name each one with its count.
3. Does the next feature fit the current structure, or fight it? Open the files its plan names and check that the plan describes them as they are.
4. Is any code untested? Does any doc say something the code does not do, or do docs/NEXT.md, docs/FEATURES.md and the scope in docs/PROJECT.md disagree? Run `sh scripts/check-docs.sh` and quote its FAIL lines and its last line. Finished features are listed in docs/DONE.md.
5. Is the MVP still the right MVP?

Give one verdict, with reasons:
- Ask first: only when check-red.sh printed an ASK line. List each question from above and what I should look at on screen to answer it. Recommend nothing else until I answer.
- Keep going: name the next feature, which must be in scope in docs/PROJECT.md. When check-next.sh said STALE, name no feature to build, not that one and not a later one (later features often need it). The next step is then to run /plan for the stale feature again, or to remove it from docs/FEATURES.md: say which of the two you would choose and why.
- Refactor first: name the one piece, why, and the smallest change that fixes it, done as its own feature with tests that pin today's behavior first.
- Rethink: say what no longer fits, and what you would change in docs/PROJECT.md.
Never recommend starting over unless every smaller option fails; say why each one fails.
Run `date +%F` for today's date; never write a date from memory. Save the result to docs/checkpoints/<that date>.md.
