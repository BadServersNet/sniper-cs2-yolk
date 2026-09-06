import os
import re
import shlex
import sys


VARIABLE = re.compile(
    r"\{\{([A-Za-z_][A-Za-z0-9_]*)\}\}"
    r"|\$\{([A-Za-z_][A-Za-z0-9_]*)\}"
    r"|\$([A-Za-z_][A-Za-z0-9_]*)"
)


def expand_variable(match: re.Match[str]) -> str:
    name = next(group for group in match.groups() if group is not None)
    value = os.environ.get(name)
    if value is None:
        raise ValueError(f"Startup variable is not set: {name}")
    return value


def main() -> None:
    try:
        startup = os.environ["STARTUP"]
        tokens = shlex.split(startup)
        arguments = [VARIABLE.sub(expand_variable, token) for token in tokens]
        if not arguments:
            raise ValueError("Startup command is empty")
    except (KeyError, ValueError) as error:
        print(f"Invalid startup command: {error}", file=sys.stderr)
        sys.exit(1)

    print("container@pterodactyl~ Starting server.", flush=True)
    os.execvp("env", ["env", *arguments])


if __name__ == "__main__":
    main()
