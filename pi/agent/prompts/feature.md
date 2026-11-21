---
description: Build one feature, all the way to done
argument-hint: "<feature>"
---
Feature: $@

Follow AGENTS.md, including "Done means".
1. Check the feature against "Feature or plan?" in AGENTS.md, reading the code it would touch. If any question fails, stop: name the question and why, and tell me to run /plan instead. Change nothing.
2. Plan in plain words, in ten lines or fewer: what you will change, which files, and how I will see it work. Wait for my OK.
3. Test first, then code. Write the wired test first ("Done means" 7): it calls the function the game loop calls each frame for input or update, and the one it calls to draw, with no mock of our own code. Find that loop line before you write the test. When the feature adds a key or a click, add it to scripts/play-keys.txt before you run the tests. Then run the full test suite and the app. The suite includes play_check, which plays the game: quote its FAIL and WARN lines and its last line.
4. Update the docs and save the walkthrough. Do not tick the feature: delete its line from docs/FEATURES.md and add one line at the end of docs/DONE.md, in the form `- <date from date +%F> <feature name> — <the walkthrough's path>`. Rewrite docs/NEXT.md from scratch, 30 lines or fewer: where we stopped, anything open, the first unticked feature. Then run `sh scripts/check-docs.sh` and quote its last line. It must say OK.
5. End with what now works, how I can see it, and the walkthrough's path. Then tell me to review it: start a new session and run /review.
