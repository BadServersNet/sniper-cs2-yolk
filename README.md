# Pterodactyl CS2 Egg

https://gitlab.steamos.cloud/steamrt/sniper/platform

## Memory tracking

Import `egg-cs2-memtracker.json` to run
[cs2-memtracker](https://github.com/zer0k-z/cs2-memtracker/releases). The
regular `egg-cs2.json` and its images remain unchanged. The memory-tracking egg
uses its own image and injects the tracker while preserving the normal
`game/cs2.sh` launcher and mod environment.

Use the server console or RCON to inspect memory:

```text
memtracker help
memtracker report 30
memtracker mark
memtracker leaks 30
memtracker reset
```

The tracker can also write a report to `/tmp/memtracker-<pid>.txt` when the CS2
process receives `SIGUSR1`. Its upstream configuration variables include
`MEMTRACK_SAMPLE`, `MEMTRACK_CAPACITY`, `MEMTRACK_DUMP`, `MEMTRACK_FIFO`, and
`MEMTRACK_CMD`. When `MEMTRACK_DUMP` is set, the entrypoint creates a daily
directory and uses the server start time for the filename. For example,
`/home/container/.memtracker/memtracker-logs.txt` becomes
`/home/container/.memtracker/logs/2026-08-22/memtracker-10-30-00.txt`.
