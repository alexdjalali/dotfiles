# RTK

`rtk` (token-saving proxy) is installed, but no hook rewrites commands any more (ADR-0002): the rewrite ran before the guards and hid the real command. Run commands normally; prefix `rtk <cmd>` yourself only for a command with very large output — the guards judge the wrapped command. `rtk gain` shows savings; if it fails, the wrong `rtk` (Rust Type Kit) may be installed.
