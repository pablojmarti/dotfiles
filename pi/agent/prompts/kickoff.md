---
description: Start a new project from an idea
argument-hint: "<idea in a few words>"
---
We are starting a new project: $@

1. Ask me up to five questions, one at a time: what it is, who it is for, and what the smallest useful version does.
2. Write docs/PROJECT.md: what it is, the MVP as 3 to 5 features, and what is out of scope. One page at most. Wait for my OK.
3. Write docs/FEATURES.md: the MVP features as an unticked checklist, then later ideas.
4. Build a walking skeleton, and nothing more: a program that starts and prints one line, plus one test that checks that line, plus a .gitignore for build output and caches. Do not build any MVP feature yet. Use tools already installed here; install nothing, and if a tool is missing, tell me.
   If the program draws with SDL, the skeleton opens a window and keeps showing frames until it is closed, and the play check becomes one of its tests. In CMakeLists.txt, after enable_testing():
   `add_test(NAME play_check COMMAND sh ${CMAKE_SOURCE_DIR}/scripts/play-check.sh)`
   `set_tests_properties(play_check PROPERTIES SKIP_RETURN_CODE 2 TIMEOUT 120)`
   Keep scripts/play-keys.txt; if it is missing, create it with comment lines only. Never edit scripts/play-check.sh or scripts/sdl-probe.c. Run the tests in the VM and quote the play_check line: it must pass there. On the Mac it shows as skipped.
   Add a CMake option SANITIZE, off by default, before the tests are added. When it is on, it first runs check_linker_flag (CMake's CheckLinkerFlag module) on `-fsanitize=address,undefined` and stops with message(FATAL_ERROR) "SANITIZE=ON: this compiler cannot link AddressSanitizer. Use clang." if that fails. Otherwise it adds the compile options `-fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer -g` and the link option `-fsanitize=address,undefined`. In the VM only clang links them; gcc has no sanitizer libraries there. Run the Sanitize command in the VM and quote its summary line: it must pass.
5. Fill in the Build, Play, Run, Test and Sanitize commands in AGENTS.md. Play is the command that starts the game built in build/, with nothing in front of it, for example `./build/game`. Test ends with `--timeout 60`. Sanitize is `cmake -B build/san -DSANITIZE=ON -DCMAKE_C_COMPILER=clang && cmake --build build/san && ctest --test-dir build/san --output-on-failure --timeout 60`.
6. Save a walkthrough of the skeleton to docs/walkthroughs/000-skeleton.md. Write docs/NEXT.md naming the first unticked feature in docs/FEATURES.md.
Then stop. Do not start a feature.
