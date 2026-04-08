#!/usr/bin/env python3
# Remove --sysroot=<CONDA_BUILD_SYSROOT> from installed Perl Config files.
#
# Configure is run with -Dsysroot=$CONDA_BUILD_SYSROOT so Perl itself links against the
# conda sysroot, but that absolute path is copied into Config_heavy.pl / CORE/config.sh.
# Downstream XS / Makefile.PL builds merge those flags; the embedded path points at this
# perl package's build croot, not the consumer's. Consumer envs set sysroot via CFLAGS.
#
# With -Dinstallstyle=lib, Config lives under lib/<ver>/<arch>/CORE/, not only lib/perl5/.

import os
import sys
from pathlib import Path


def main():
    prefix = os.environ.get("PREFIX")
    if not prefix:
        print("PREFIX not set", file=sys.stderr)
        return 1

    sr = os.environ.get("CONDA_BUILD_SYSROOT", "")
    if not sr:
        return 0

    needle = "--sysroot=" + sr
    lib = Path(prefix) / "lib"
    if not lib.is_dir():
        return 0

    for path in lib.rglob("Config_heavy.pl"):
        _scrub_file(path, needle)

    for path in lib.rglob("config.sh"):
        if path.parent.name == "CORE":
            _scrub_file(path, needle)

    return 0


def _scrub_file(path: Path, needle: str) -> None:
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return

    if needle not in text:
        return

    path.write_text(text.replace(needle, ""), encoding="utf-8")


if __name__ == "__main__":
    raise SystemExit(main())
