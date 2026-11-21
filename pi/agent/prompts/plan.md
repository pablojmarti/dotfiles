---
description: Break a big idea into small features that /feature can build
argument-hint: "<idea>"
---
Idea: $@

Break this idea into small features. Running /plan is asking for a plan file.
Change no source or test files. Do not use the brainstorming or writing-plans skills; this command replaces them.

1. Ask me up to three questions, one per message, about what the idea should do and what the smallest useful version is. Skip any that docs/PROJECT.md already answers.
2. Read the code the idea touches. For every file, function, type, macro, constant and command you will name, find where it is defined and note file:line. Library names come from the headers in vendor/. Write (new) right after the name of anything a feature will create, like `src/admin.c` (new). Only for names that do not exist yet. If you cannot find something that should already exist, write UNVERIFIED: in front of it. Never invent a name.
3. Split the idea into features by what I can see change, one step at a time, not by file or by layer. Order them so each builds on the one before. The first is the smallest change I can see, in a test or on screen. A feature does not have to be useful on its own; the last one makes the idea useful. Each feature, on its own, leaves the app building and every test passing: never remove something that a later feature still has to replace.
   A split that often works: first the data or rule, proved by a test; then showing it on screen; then the key or click that opens it; then the key or click that changes it. Never put a new key, new text on screen and a new rule in one feature.
4. Check every feature against "Feature or plan?" in AGENTS.md. Count its code files (tests and docs do not count) and the library functions it uses that the code has never used. If a feature fails a question, split it again. A library function the code has never used gets a feature of its own.
5. Run `date +%F` for today's date. Write docs/plans/<date>-<idea-name>.md. Give each feature a heading, `## Feature N: <name>`, where the name is one sentence without "and". Under it:
   - Why it is its own feature: one line.
   - Where: the files and functions it changes, each with file:line, in backticks, one per line.
   - Done when: at most three checks I can see, in a test or on screen.
   - Size: S (under an hour) or M (one to two hours).
   Then list everything marked UNVERIFIED and how I can check it.
   No code, no commit steps, no subagents.
   If scripts/check-refs.sh exists, you must run it on the plan file: `sh scripts/check-refs.sh <plan file>`. Fix each name it reports, or mark it (new) or UNVERIFIED. If it says TOO BIG, split that feature. Run it again until it reports no problems.
6. Check the features together against my words: list each thing I asked for and the feature that delivers it. If something I asked for has no feature, or a feature does something I did not ask for, fix the plan first. Then show me the features in plain words, with that list and why the idea was split this way. Wait for my OK.
7. After my OK: add the features to docs/FEATURES.md as unticked items, in the style of the ones already there, each naming the plan file. Remove the idea from the Ideas section if it is there. Update docs/NEXT.md to name the first one.
End with the command to run next. Then stop. Do not build any feature, even the first: that is /feature, in its own session.
