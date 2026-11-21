# Rally: a two-paddle ball game in C with SDL3

The full picture is in docs/PROJECT.md.

## Build, run, test
- Build: (filled in by /kickoff)
- Play: (filled in by /kickoff)
- Run: (filled in by /kickoff)
- Test: (filled in by /kickoff)
- Sanitize: (filled in by /kickoff)
Keep these five commands true. This is the only part of this file you may edit.

## How we work
- C11 and CMake. Build in build/ only. Never build in the project root. Never touch build-mac/; it belongs to the Mac.
- SDL 3 (release-3.4.20) is in vendor/sdl and Unity is in vendor/unity. Build SDL from vendor/sdl with add_subdirectory and link SDL3::SDL3. Never use find_package(SDL3) or a system copy of SDL.
- SDL3 and Unity are the only libraries. Never install, fetch or upgrade a library. If a feature needs another one, stop and tell me what it is for; it needs my OK first.
- Tests use Unity and SDL's dummy video driver. The VM has no display: "the app runs" means the test suite passes in the VM, including play_check; a person looks at the pictures in build/play/.
- All text on screen (score, messages) uses SDL's built-in debug text: `SDL_RenderDebugText`, made larger with `SDL_SetRenderScale`. No font library, and no hand-made letter or digit shapes.
- Check every array index that comes from a parameter, and every allocation.
- The test play_check runs `sh scripts/play-check.sh`: it plays the game in the VM with no window, using the Play command, and reports what moved and what was drawn. Quote its FAIL and WARN lines and its last line. A FAIL means the feature is not done. When a feature adds a key or a click, add it to scripts/play-keys.txt.
- Never edit `scripts/play-check.sh`, `scripts/sdl-probe.c` or `scripts/play-accept.txt`.
- A command that never ends stops your whole session. The Test command above must have a time limit (`--timeout 60` for ctest). In the VM, run the app only with `timeout 5` in front. Every test must finish on its own, with no display and no key press.
- One feature at a time, from docs/FEATURES.md. Add a feature there only when I ask; anything out of scope in docs/PROJECT.md needs my OK.
- Before writing code, say in plain words what you will change, which files, and how I will see it work. Wait for my OK.
- A feature is a small change for Superpowers: the plain-words plan is its design. Only /plan writes plan files.
- Before you name a function, type, macro, constant, file or command, find where it is defined, in src/ or in the headers in vendor/sdl/include and vendor/unity/src. If you cannot find it, say so. Never guess a name.
- A C library function (one that is not in src/ or vendor/, such as `kill` or `fork`) needs its own header. Find the header with `grep -rn 'name *(' /usr/include`, and include it in every file that calls the function. The Mac's compiler stops on a missing header even when the VM's does not.
- Bugs: use systematic-debugging. Find the cause before changing code.
- Do not commit, branch or create worktrees. I review and commit.
- No ADRs or reports unless I ask. A doc may only say what a command can show.
- This machine has no network. Never install anything; tell me what is missing.

## Feature or plan?
A feature passes all three questions:
1. Can you say what it does in one sentence, without "and"?
2. Can you say exactly what changes on screen, or in a test, when it is done?
3. Does it change three code files or fewer (tests and docs do not count), and use at most one library function the code has never used before?
If any answer is no, it is an idea. Ideas go under "Ideas" in docs/FEATURES.md, and /plan breaks them into features.

## Done means
1. A test that failed before the change now passes.
2. The full test suite passes, and so does the Sanitize command. Quote both summary lines. A sanitizer report names a file and line: that is a bug in this change until shown otherwise.
3. The app builds and runs. Say what you ran and what you saw.
4. Docs the change touches are updated: README, docs/FEATURES.md, the commands above.
5. A walkthrough is saved to docs/walkthroughs/NNN-feature-name.md, where NNN is one more than the highest number already there.
6. docs/NEXT.md says where we stopped and names the first unticked feature in docs/FEATURES.md.
7. At least one test is wired: it enters through the function the game loop calls each frame for input or update, and the one it calls to draw, with no mock of our own code. Name it in the walkthrough, with the loop line that calls the same function.

## Walkthrough format
Write for someone who codes rarely, and explain each term the first time you use it.
1. What changed, file by file, in plain words.
2. The key code, quoted, with one line on what each part does.
3. How it connects to the code that was already there.
4. One thing worth learning from this change.
5. Questions I might ask, answered.
