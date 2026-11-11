---
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash, Edit, Write]
---

`word_count("hello  world")` in textutil.py returns 3, and `word_count("  hi ")` returns 4. Both should be the number of words. Fix it. Run the tests with `python3 -m unittest discover -s tests -t .` when you're done.
