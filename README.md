# Pterodactyl CS2 Egg

https://gitlab.steamos.cloud/steamrt/sniper/platform

## Memory profiling

The SDK image includes `heaptrack`, `smem`, `pidstat`, `gdb`, `strace`,
`pmap`, and ELF inspection tools. The platform image remains unchanged.

Import `egg-cs2-profiler.json` as a separate Pterodactyl egg for a bounded
profiling session. The normal `egg-cs2.json` continues to use `cs2.sh` and does
not expose profiling controls. Captures are saved under
`/home/container/heaptrack` and therefore remain in the server volume after the
process exits. Stop the server cleanly before downloading the `.zst` or `.gz`
capture.

The profiling egg uses the SDK image, bypasses `cs2.sh`, configures the required
Linux runtime environment directly, and starts Heaptrack against
`game/bin/linuxsteamrt64/cs2`.

Analyze a capture in the SDK container with:

```bash
heaptrack_print /home/container/heaptrack/<capture>
```

For a graphical report, download the capture and open it with
`heaptrack_gui` on a workstation. Profiling adds CPU, memory, and disk overhead,
and capture files can become large, so it should only be enabled during a
bounded debugging session.

Heaptrack reports allocations made through the heap allocator. Compare its
reported peak with these process-level views when resident memory is higher:

```bash
smem -tk
pmap -x <cs2-pid>
pidstat -r -p <cs2-pid> 1
cat /proc/<cs2-pid>/smaps_rollup
cat /sys/fs/cgroup/memory.current
cat /sys/fs/cgroup/memory.stat
```

The difference commonly comes from file mappings, thread stacks, shared pages,
allocator fragmentation, or memory retained by the allocator rather than a
currently live allocation. The cgroup files also separate anonymous memory from
the container's file cache on cgroup v2 nodes. Launch-time profiling does not
require `SYS_PTRACE`;
attaching `heaptrack`, `gdb`, or `strace` to an already running process may
require that capability and a compatible seccomp policy on the Pterodactyl
node.
