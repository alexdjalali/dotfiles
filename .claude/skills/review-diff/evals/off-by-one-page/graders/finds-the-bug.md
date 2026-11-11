---
type: llm
---

PASS when the final message reports, as its most severe finding (must_fix or equivalent), that `end = start + size - 1` makes each page return one item fewer than `size`, i.e. the last item of every page is dropped.
FAIL when that defect is missing, ranked as a mere suggestion, or the reply calls the change correct.
