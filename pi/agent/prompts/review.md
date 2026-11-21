---
description: Review a finished feature before I commit it. Run it in a new session.
argument-hint: "[feature]"
---
Review the uncommitted change for this feature: $@
If no feature is named, review the one docs/NEXT.md says was just built.

Another session wrote this change. Judge it only by the code, the tests and the docs.
Change no files except the review file. Never edit, format, stage, commit, reset, checkout, stash or clean.
If git is not installed, stop and tell me: /review needs git.

1. Read git status, git diff, every new untracked file, docs/NEXT.md, the feature's entry in docs/FEATURES.md, its plan in docs/plans/ if it has one, and the newest walkthrough. Only features that came from /plan have a plan; a missing plan is not a finding.
2. Run the build, the full test suite and the Sanitize command from AGENTS.md. Quote both summary lines. A sanitizer report is a Must fix; quote its SUMMARY line.
3. If scripts/check-refs.sh exists, run it on the newest walkthrough and on every doc the change touched.
4. Check each item in "Done means" in AGENTS.md: pass or fail, with the evidence.
5. Read every changed line. Look for:
   - Does it do what the feature says, and nothing more?
   - Bugs: array indexes, NULL, values out of range, memory that is never freed.
   - Library calls: does each one exist in the headers in vendor/, with those arguments?
   - Tests: for each new test, name the line of code that makes it fail if that line is wrong. A test with no such line is a finding.
   - Wired test ("Done means" 7): name the test that enters through the function the game loop calls each frame, and quote the line in the game loop that calls the same function, with file:line. Follow the calls from that loop line to the code this feature adds. No wired test, or a test that calls a function the loop never reaches: Must fix. A test that reads data in a different way than the game reads it (a mock of our own code, its own copy of the state, a helper the game does not call): a finding.
   - If scripts/mutate-check.sh exists, run `sh scripts/mutate-check.sh` with no arguments; it finds and checks every changed comparison in src/ by itself. Quote each RESULT line. Every NOT CAUGHT is a Must fix: no test checks that line, whatever the tests look like.
   - If scripts/play-check.sh exists, run `sh scripts/play-check.sh` as AGENTS.md gives it. It plays the game with no window. Quote every FAIL and WARN line and its last line. Every FAIL is a Must fix, also when its cause is older than this feature. For every WARN, say how the feature explains it, or make it a finding. Then read its "What was drawn" list and name the line where the thing this feature adds shows up. If it is not on the list, or not where the feature says, that is a Must fix.
   - Docs that say something the code does not do.
   - If `scripts/pre-commit` exists, run `sh scripts/pre-commit` on source code file that changed as part of the review. Flag issues in report.
   If a check script errors or cannot run, say so and quote the error. The verdict cannot be Ready to commit until it runs.
6. Write docs/reviews/NNN-feature-name.md, where NNN is the newest walkthrough's number:
   - Verdict: Ready to commit, Fix first, or Ask me.
   - Done means: each check, pass or fail.
   - Findings, most serious first, each marked Must fix, Should fix or Minor, with file:line, what is wrong, why it matters and how to fix it.
   - What is good: up to three specific things.
   - Set aside: anything you noticed outside this feature, one line each.
7. Tell me, in five lines or fewer: the verdict, each Must fix, and what to do next: commit if Ready to commit; if Fix first, give me this exact line to paste into a new session: /fix docs/reviews/<the review file name>. Every finding must point at a line you read in this session; drop any you cannot point at.
