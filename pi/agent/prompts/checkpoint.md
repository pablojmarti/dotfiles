---
description: Decide whether to keep going, refactor or rethink
---
Run a checkpoint on this project. Change no code.
Read docs/PROJECT.md, docs/FEATURES.md, docs/NEXT.md, the last five walkthroughs, git log and the code. Check:
1. Did recent features take longer, or touch more files, than their size suggests?
2. Has the same kind of bug come back?
3. Does the next feature fit the current structure, or fight it?
4. Is any code untested? Does any doc say something the code does not do, or do docs/NEXT.md, docs/FEATURES.md and the scope in docs/PROJECT.md disagree?
5. Is the MVP still the right MVP?

Give one verdict, with reasons:
- Keep going: name the next feature, which must be in scope in docs/PROJECT.md.
- Refactor first: name the one piece, why, and the smallest change that fixes it, done as its own feature with tests that pin today's behavior first.
- Rethink: say what no longer fits, and what you would change in docs/PROJECT.md.
Never recommend starting over unless every smaller option fails; say why each one fails.
Save the result to docs/checkpoints/ with today's date in the file name.
