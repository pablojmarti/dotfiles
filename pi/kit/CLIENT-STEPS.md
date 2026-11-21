# Client steps: bring depression.c up to the new kit

Things to paste or run, in this order. Each stage ends with a commit, so you can stop between stages.
Commands marked "Mac" run in a terminal on the Mac, from the project folder. Lines starting with `/` go into Pi.

## 0. Before you start

Run `git status`. Commit or set aside your own work first, so each stage's commit holds only that stage.
If your uncommitted work in `src/console.c` already fixes the console crash, stage 4 will show PASS at once: then skip its `/bug` and `/fix`.

## 1. Copy the kit scripts (Mac, 1 min)

```sh
KIT=~/workspace/projects/rally-test/brief/seed
cd ~/workspace/projects/depression
cp "$KIT/play-check.sh" "$KIT/sdl-probe.c" "$KIT/play.sh" "$KIT/check-refs.sh" "$KIT/check-bug.sh" "$KIT/mutate-check.sh" scripts/
[ -f scripts/play-keys.txt ] || cp "$KIT/play-keys.txt" scripts/
git status --short scripts/
```

What you should see: ` M` for `check-refs.sh`, `mutate-check.sh`, `play-check.sh` and `sdl-probe.c` (the new versions replace the old ones; the `fflush` line you added to `sdl-probe.c` is already in the new one), and `??` for `check-bug.sh`, `play.sh` and `play-keys.txt`.
Do not copy the kit's `AGENTS.md`, `gitignore` or `rerun-play-accept.txt`: they are Rally's.

What each script is for:
- `play-check.sh` and `sdl-probe.c`: play the game in the VM with no window, report what moved, and save pictures in `build/play/`.
- `play.sh`: the one command for you. It builds and plays in the VM and prints only the FAIL, WARN and last lines.
- `check-refs.sh`: checks that names and line numbers in a bug file, review or walkthrough match the code.
- `check-bug.sh`: reruns a bug file's Reproduce command. `/bug` and `/fix` use it.
- `mutate-check.sh`: flips each changed comparison and checks that a test notices. `/fix` uses it.

## 2. AGENTS.md: the play check and the wired test (2 min)

Edit `AGENTS.md` by hand. Four changes, then a check.

**a.** Under "## Build, run, test", add this line just before the line that starts with `- Run:`:
```
- Play: `./build/depression`
```

**b.** Under "## How we work", replace this line:
```
- `sh scripts/play-check.sh ./build/depression` plays the game in the VM with no window and reports what moved and what was drawn. For every feature that changes what is on screen, run it after the tests and quote its FAIL and WARN lines and its last line. A FAIL means the feature is not done. When a feature adds a key, add the key to scripts/play-keys.txt.
```
with these two lines:
```
- The test play_check runs `sh scripts/play-check.sh`: it plays the game in the VM with no window, using the Play command, and reports what moved and what was drawn. Quote its FAIL and WARN lines and its last line. A FAIL means the feature is not done. When a feature adds a key or a click, add it to scripts/play-keys.txt.
- Never edit `scripts/play-check.sh`, `scripts/sdl-probe.c` or `scripts/play-accept.txt`.
```

**c.** Replace this line:
```
- Tests use SDL's dummy driver. In the VM, "the app runs" means the test suite passes; a person checks the window on the Mac.
```
with:
```
- Tests use SDL's dummy driver. In the VM, "the app runs" means the test suite passes, including play_check; a person looks at the pictures in build/play/.
```

**d.** Under "## Done means", after item 6, add:
```
7. At least one test is wired: it enters through the function the game loop calls each frame for input or update, and the one it calls to draw, with no mock of our own code. Name it in the walkthrough, with the loop line that calls the same function.
```
`/feature` and `/review` refer to this item as "Done means" 7. Keep it number 7.

**e.** Run `git diff AGENTS.md` and check that it shows these four changes and nothing else.

## 3. Register the play check as a test (one feature, about 30 min)

In Pi:
```
/feature Register the play check as a test. In tests/CMakeLists.txt add `add_test(NAME play_check COMMAND sh ${CMAKE_SOURCE_DIR}/scripts/play-check.sh)` and `set_tests_properties(play_check PROPERTIES SKIP_RETURN_CODE 2 TIMEOUT 120)`. Do not edit scripts/play-check.sh or scripts/sdl-probe.c. "Done means" 7 does not apply to registering a test: say so in the walkthrough. Done when ctest in the VM lists play_check and quotes its last line, and on the Mac it shows as skipped.
```
Then, as usual: look at the pictures in `build/play/`, `/review` in a new session, and commit together with stages 1 and 2.

## 4. Fix the console crash (two sessions, about 1 hour)

**a.** Add one line at the end of `scripts/play-keys.txt`. It presses the backquote key at frame 60, one second in:
```
`:60
```

**b.** Mac:
```sh
sh scripts/play.sh
```
What you should see (from Claude's run on a copy of the project at `fefcc3a`):
```
FAIL  the game crashed or was killed after frame 60 (exit status 139). See build/play/game-output.txt.
```
If it prints PASS instead, the crash is already fixed: skip to e.

**c.** Start Pi and paste `/bug`, then the FAIL line exactly as `play.sh` printed it, then one sentence on what you wanted:
```
/bug FAIL  the game crashed or was killed after frame 60 (exit status 139). See build/play/game-output.txt. The key at frame 60 is backquote, from scripts/play-keys.txt: it should open the dev console, show ">" and what I type, and the game should keep running.
```
`/bug` changes no code. Read the cause it writes in `docs/bugs/`. Check that it quotes a `check-refs:` line with 0 problems and a `check-bug:` line with 0 problems.

**d.** If the cause makes sense, quit Pi, start it again, and paste the line `/bug` gave you, such as:
```
/fix docs/bugs/2026-11-21-console-crash.md
```
Say OK to its list. It adds a test that opens the console with a real key event and draws a real frame, shows it failing first, then fixes the code.

**e.** Mac: `sh scripts/play.sh` again. The last line must be a PASS. Open the picture after frame 60 in `build/play/` (around `frame-00062.bmp`): it should show the open console.

**f.** `/review` in a new session. It should name the wired console test. Commit.

## 5. Tests with sanitizers (one feature, about 30 min)

Sanitizers stop a test on a read past an array, a use after free or an integer overflow, and print the file and line. They run in the VM, with clang.

**a.** AGENTS.md, under "## Build, run, test". Replace the Test line:
```
- Test (VM): `ctest --test-dir build --output-on-failure`
```
with these two lines:
```
- Test (VM): `ctest --test-dir build --output-on-failure --timeout 60`
- Sanitize (VM): `cmake -B build/san -DSANITIZE=ON -DCMAKE_C_COMPILER=clang && cmake --build build/san && ctest --test-dir build/san --output-on-failure --timeout 60`
```

**b.** Replace the Format line:
```
- Format: `make format` (runs clang-format on all source files). The pre-commit hook also formats and runs the full test suite (via `ctest --test-dir build-mac`), failing the commit on any error.
```
with:
```
- Format: `make format` (runs clang-format on all source files). The pre-commit hook checks formatting and fails the commit on unformatted files. It also runs depression_tests and e2e_tests, but a failure there only warns.
```
(The old line was wrong: the hook in `scripts/pre-commit` does not run `ctest --test-dir build-mac`. `make format` is wrong too, since there is no Makefile; that is a later fix.)

**c.** Under "## Done means", replace item 2:
```
2. The full test suite passes. Quote its summary line.
```
with:
```
2. The full test suite passes, and so does the Sanitize command. Quote both summary lines. A sanitizer report names a file and line: that is a bug in this change until shown otherwise.
```

**d.** In Pi:
```
/feature Build the tests with sanitizers when SANITIZE is on. In CMakeLists.txt, just before add_subdirectory(tests), add option(SANITIZE "Build the tests with AddressSanitizer and UndefinedBehaviorSanitizer" OFF). When it is on: include(CheckLinkerFlag), run check_linker_flag(C "-fsanitize=address,undefined" HAVE_SANITIZERS), and if that fails stop with message(FATAL_ERROR "SANITIZE=ON: this compiler cannot link AddressSanitizer. Use clang."). Otherwise add_compile_options(-fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer -g) and add_link_options(-fsanitize=address,undefined). The game target is not changed. For "Done means" 1, add a scratch test that reads one past a malloc of 4 ints: run the Sanitize command, quote the SUMMARY line naming the scratch test's file and line, then delete the scratch test. "Done means" 7 does not apply to a build option: say so in the walkthrough. Done when the Test command and the Sanitize command both pass in the VM; quote both summary lines.
```
What to expect, from Claude's run of the same change on a copy at `fefcc3a`: the scratch test gives `SUMMARY: AddressSanitizer: heap-buffer-overflow ... in read_at`, and the existing tests give `100% tests passed, 0 tests failed out of 10`. Your count will be higher by one, for play_check, and by the console test from stage 4.

**e.** `/review` in a new session. Commit.

## 6. The loop from now on

1. `/next`
2. `/feature "<one feature>"`, OK its plan, let it build.
3. Mac: `sh scripts/play.sh`. Read its FAIL and WARN lines and its last line.
4. Open the pictures in `build/play/`. Tests can't see the screen; you can.
5. `/review` in a new session. On Fix first, `/fix <the review file>` in a new session, then `/review` again.
6. Commit.

On any FAIL line, crash or sanitizer `SUMMARY:` line: `/bug <the line>`, then `/fix <the bug file>` in a new session.
When a feature adds a key or a click, its line goes in `scripts/play-keys.txt`, so the play check presses it every time.
