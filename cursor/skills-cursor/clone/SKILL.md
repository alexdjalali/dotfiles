---
name: clone
description: >-
  Use for "/clone", "cursorfs-clone", or "clone skill". CoW-clones the current
  repo via cursorfs-clone-orchestrate; in Glass, also moves the agent workbench
  to the clone via cursor-app-control. Outside Glass, just prints the
  destination.
disable-model-invocation: true
metadata:
  disabledEnvironments:
    - cloud
---

