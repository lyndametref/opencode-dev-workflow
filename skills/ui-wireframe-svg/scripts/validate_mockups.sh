#!/bin/sh
# Validate mockup bookkeeping in a mockups directory.
# Usage: validate_mockups.sh [mockups-dir]
# Checks: unique MOCK-XXXX ids, registry rows present for each file, no orphan registry rows.
set -eu
dir=${1:-docs/specifications/ui/mockups}
registry="$dir/README.md"
[ -d "$dir" ] || { echo "error: mockups directory not found: $dir" >&2; exit 1; }
[ -f "$registry" ] || { echo "error: registry not found: $registry" >&2; exit 1; }

# Collect file ids
file_ids=$(for f in "$dir"/MOCK-*.*; do
  [ -e "$f" ] || continue
  b=${f##*/}
  case "$b" in MOCK-[0-9][0-9][0-9][0-9]-*) ;;
    *) echo "warn: non-conforming filename $b" >&2; continue ;;
  esac
  printf '%s\n' "${b#MOCK-}" | cut -c1-4
done | sort)

# duplicate full filenames are not expected (same file twice) - skip; IDs may repeat across svg/html artifacts.

# registry ids (first column after MOCK- in table rows)
reg_ids=$(sed -n 's/^| *MOCK-\([0-9][0-9][0-9][0-9]\) .*/\1/p' "$registry" | sort)

# every file id must appear in registry
missing_reg=""
for id in $file_ids; do
  if ! printf '%s\n' "$reg_ids" | grep -qx "$id"; then
    missing_reg="$missing_reg MOCK-$id"
  fi
done
[ -z "$missing_reg" ] || { echo "error: mockups missing registry rows:$missing_reg" >&2; exit 1; }

# every registry id should have at least one file
orphan_reg=""
for id in $reg_ids; do
  if ! printf '%s\n' "$file_ids" | grep -qx "$id"; then
    orphan_reg="$orphan_reg MOCK-$id"
  fi
done
[ -z "$orphan_reg" ] || { echo "warning: registry rows without mockup files:$orphan_reg" >&2; }

echo "mockup bookkeeping OK: $(printf '%s\n' "$file_ids" | grep -c .) mockup(s), $(printf '%s\n' "$reg_ids" | grep -c .) registry row(s)"