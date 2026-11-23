# Pterodactyl CS2 Egg

https://gitlab.steamos.cloud/steamrt/sniper/platform

## Startup arguments

The launcher splits `STARTUP` using shell-style quotes before replacing
`{{VARIABLE}}`, `${VARIABLE}`, or `$VARIABLE` references with environment values.
Each replacement stays inside its original argument, including empty strings,
spaces, quote characters, and wildcards. Undefined variables and malformed quotes
fail startup. Environment values are never evaluated as shell commands.

For example, `+sv_password {{PASSWORD}}` supplies exactly one password argument,
even when `PASSWORD` is empty. Quote literal multiword arguments such as
`+hostname "BadServers.net | FFA"`. Shell operators and command substitution are
not evaluated by the launcher; commands needing shell logic must explicitly
invoke a shell script.

## Gameinfo patching

`PATCH_GAMEINFO_METAMOD` and `PATCH_GAMEINFO_SWIFTLYS2` (default `0`) add
`Game csgo/addons/metamod` and `Game csgo/addons/swiftlys2` after the
`Game_LowViolence` line of `game/csgo/gameinfo.gi` on every startup, after the
SteamCMD update. Metamod is always placed before SwiftlyS2. They only patch
`gameinfo.gi`; they do not install Metamod or SwiftlyS2.

When either is enabled, the patch removes existing Metamod and SwiftlyS2 entries
and extra blank lines below the anchor before inserting the enabled entries, so
repeated startups leave the file unchanged. When both are disabled,
`gameinfo.gi` is not modified.

## Steam client libraries

Both runtime variants recreate `.steam/sdk32/steamclient.so` and
`.steam/sdk64/steamclient.so` as links to SteamCMD's corresponding libraries
before launching CS2. This runs after updates and also when `AUTO_UPDATE=0`,
so startup repairs missing SDK links after a server wipe and uses the current
SteamCMD libraries. Missing or empty SteamCMD libraries fail startup with their
source path rather than launching CS2 into a Steamworks initialization failure.

The installation script also copies these libraries, but runtime startup must
not depend on those copies surviving or on the installation script having
completed after the game files were downloaded.
