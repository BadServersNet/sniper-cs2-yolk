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
