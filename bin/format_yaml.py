#!/usr/bin/env python3
"""Format YAML files using ruamel.yaml preserving comments.

Usage:
  format_yaml.py [--check] [--apply] [paths...]

Default: if no paths provided, will search repo for .yml/.yaml files.
--check: don't write files, just report which files would change and exit 1 if any
--apply: write changes in-place (backing up to <file>.bak)
"""
from pathlib import Path
import sys
import argparse
import shutil

try:
    from ruamel.yaml import YAML
except Exception:
    print("ruamel.yaml is required. Install with: python3 -m pip install --user ruamel.yaml")
    sys.exit(2)


def collect_files(paths):
    files = []
    if paths:
        for p in paths:
            pp = Path(p)
            if pp.is_dir():
                files.extend([f for f in pp.rglob('*.yml')])
                files.extend([f for f in pp.rglob('*.yaml')])
            else:
                files.append(pp)
    else:
        files = list(Path('.').rglob('*.yml')) + list(Path('.').rglob('*.yaml'))
    # filter out .git
    files = [f for f in files if '.git' not in f.parts]
    # dedupe and sort
    files = sorted(set(files))
    return files


def normalize_text(txt: str) -> str:
    # Strip trailing whitespace on lines, ensure trailing newline
    lines = [line.rstrip() for line in txt.splitlines()]
    return '\n'.join(lines) + '\n'


def format_file(p: Path, yaml, apply_changes=False):
    try:
        original = p.read_text()
    except Exception as e:
        return False, f'read error: {e}'

    # If file is comments or blank only, skip it (preserve comments)
    def is_comment_or_blank(text: str) -> bool:
        for line in text.splitlines():
            s = line.strip()
            if not s:
                continue
            if s.startswith('#'):
                continue
            return False
        return True

    if is_comment_or_blank(original):
        return False, 'comments/blank - skipped'

    # Load preserving comments
    try:
        data = yaml.load(original)
    except Exception as e:
        return False, f'parse error: {e}'

    # Dump to string
    from io import StringIO
    buf = StringIO()
    yaml.dump(data, buf)
    new_txt = buf.getvalue()

    if normalize_text(original) == normalize_text(new_txt):
        return False, 'no change'

    if apply_changes:
        bak = p.with_suffix(p.suffix + '.bak')
        shutil.copy2(p, bak)
        p.write_text(new_txt)
        return True, 'applied'
    else:
        return True, 'would change'


def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true', help='Do not write files; exit 1 if changes required')
    parser.add_argument('--apply', action='store_true', help='Write changes in-place')
    parser.add_argument('paths', nargs='*')
    args = parser.parse_args(argv[1:])

    yaml = YAML()
    yaml.indent(mapping=2, sequence=4, offset=2)
    yaml.preserve_quotes = True
    yaml.width = 4096

    files = collect_files(args.paths)
    if not files:
        print('No YAML files found')
        return 0

    changed_any = False
    errors = []
    for f in files:
        ok, msg = format_file(f, yaml, apply_changes=args.apply)
        # treat comments/blank as informational
        if msg == 'comments/blank - skipped':
            print(f'{f}: {msg}')
            continue

        if ok:
            changed_any = True
            print(f'{f}: {msg}')
        else:
            if msg not in ('no change',):
                errors.append((f, msg))
            print(f'{f}: {msg}')

    if errors:
        print('\nErrors:')
        for f, m in errors:
            print(f'  {f}: {m}')
        return 2

    if args.check and changed_any:
        print('\nFormatting check failed; files would be changed')
        return 1

    if args.apply and changed_any:
        print('\nFormatting applied')
    elif not changed_any:
        print('\nAll files already formatted')

    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
