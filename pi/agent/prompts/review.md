---
description: Review a finished feature before I commit it. Run it in a new session.
argument-hint: "[feature]"
---
Review the uncommitted change for this feature: $@
If no feature is named, review the one docs/NEXT.md says was just built.

Another session wrote this change. Judge it only by the code, the tests and the docs.
Change no files except the review file. Never edit, format, stage, commit, reset, checkout, stash or clean.
If git is not installed, stop and tell me: /review needs git.
If git status shows an older uncommitted file in docs/reviews/ about this same change, this is a re-review, after a /fix. Start your review file with each Must fix from the newest of those files, marked fixed or not fixed, with the evidence. Older review files are records of what was seen then: read them, never raise a finding about what one says.

1. Read git status, git diff, every new untracked file, docs/NEXT.md, the feature's entry in docs/FEATURES.md, its plan in docs/plans/ if it has one, and the newest walkthrough. Only features that came from /plan have a plan; a missing plan is not a finding.
2. Run the build, the full test suite and the Sanitize command from AGENTS.md. Quote both summary lines. A sanitizer report is a Must fix; quote its SUMMARY line.
   Every failing test is a Must fix, also when it failed before this change: there is no "pre-existing" failure, and a failing test is never out of scope. If any test fails and scripts/check-red.sh exists, run `sh scripts/check-red.sh` and quote every RED and ASK line. For an ASK line, do not say whether the code or the test is wrong: the finding is "ask the person", and the verdict is Ask me.
3. If scripts/check-refs.sh exists, run it on the newest walkthrough, and on the bug file if the change fixes one. Do not run it on docs/NEXT.md or on review files: they name things the change deleted, and check-refs reports those as NOT FOUND. If scripts/check-docs.sh exists, run `sh scripts/check-docs.sh` and quote every FAIL and WARN line and its last line. Every FAIL is a Must fix: a finished feature belongs in docs/DONE.md as one line, not in docs/FEATURES.md, and docs/NEXT.md is rewritten, not added to.
4. Check each item in "Done means" in AGENTS.md: pass or fail, with the evidence.
5. Read every changed line. Look for:
   - Does it do what the feature says, and nothing more?
   - Bugs: array indexes, NULL, values out of range, memory that is never freed.
   - Library calls: does each one exist in the headers in vendor/, with those arguments?
   - If the change fixes a bug file (docs/NEXT.md, a "Fixed" section in the walkthrough, or a new or changed file in docs/bugs/ names it): read the bug file's Fix section and compare it with git diff, item by item. A changed code or test file that the Fix does not name, a change to something the Fix says to leave alone, or a Fix item with no change in the diff: Must fix. Quote the Fix line and the diff line. A fix that makes the tests pass a different way than the bug file says is not the fix, even with every test passing.
   - Tests: for each new test, name the line of code that makes it fail if that line is wrong. A test with no such line is a finding.
   - For each existing test whose assertions changed: say what it checked before and what it checks now. A test that now checks less (an assertion removed, a search for a value in place of a fixed position, a looser comparison) is a finding; say what it would no longer catch. If a string in an assertion changed, check the new string against the code that prints it, letter by letter.
   - Wired test ("Done means" 7): name the test that enters through the function the game loop calls each frame, and quote the line in the game loop that calls the same function, with file:line. Follow the calls from that loop line to the code this feature adds. No wired test, or a test that calls a function the loop never reaches: Must fix. A test that draws through a function whose name ends in `_mocked`, or through any other test-only copy of what the loop calls, is not wired, even if a comment says it wraps the real function: if it is the only wired test, that is a Must fix. Open the function the test calls and check that it is the one the loop line names. A test that reads data in a different way than the game reads it (its own copy of the state, a helper the game does not call): a finding.
   - If scripts/mutate-check.sh exists, run `sh scripts/mutate-check.sh` with no arguments; it finds and checks every changed comparison in src/ by itself. It rebuilds and reruns the tests for each one: give it a time limit of at least 900 seconds. A run that was cut off did not run. Quote each RESULT line. Every NOT CAUGHT is a Must fix: no test checks that line, whatever the tests look like.
   - If scripts/play-check.sh exists, run `sh scripts/play-check.sh` as AGENTS.md gives it. It plays the game with no window. Quote every FAIL and WARN line and its last line. Every FAIL is a Must fix, also when its cause is older than this feature. For every WARN, say how the feature explains it, or make it a finding. Then read its "What was drawn" list and name the line where the thing this feature adds shows up. If it is not on the list, or not where the feature says, that is a Must fix.
   - Docs that say something the code does not do. Compare docs with the code as it is now in the working tree, not with the last commit: nothing is committed until the review says Ready to commit.
   - If `scripts/pre-commit` exists, run `sh scripts/pre-commit` on source code file that changed as part of the review. Flag issues in report.
   If a check script errors or cannot run, say so and quote the error. The verdict cannot be Ready to commit until it runs.
6. Write docs/reviews/NNN-feature-name.md, where NNN is the newest walkthrough's number. The path starts with docs/, in the folder that holds AGENTS.md; never with workspace/ or /workspace/. After writing, run `ls docs/reviews/` and check the file is listed:
   - Verdict: Ready to commit, Fix first, or Ask me. Never Ready to commit while any test fails or the test summary line is not 100% passed. Fix first only when there is at least one Must fix. With no Must fix the verdict is Ready to commit, and I decide about the rest. Ask me when you cannot tell whether a finding is a Must fix.
   - Done means: each check, pass or fail.
   - Findings, most serious first, each marked Must fix, Should fix or Minor, with file:line, what is wrong, why it matters and how to fix it.
     Must fix is only one of these: a "Done means" item that is missing, a failing test, a FAIL or NOT CAUGHT line from a script, a sanitizer report, a change that departs from the bug file's Fix, or a bug you can show with a line of code. Wording in a doc or a comment, and the wording of docs/NEXT.md, is Should fix or Minor.
   - What is good: up to three specific things.
   - Set aside: anything you noticed outside this feature, one line each.
7. Tell me, in five lines or fewer: the verdict, each Must fix, and what to do next: commit if Ready to commit; if Fix first, give me this exact line to paste into a new session: /fix docs/reviews/<the review file name>. Every finding must point at a line you read in this session; drop any you cannot point at.
