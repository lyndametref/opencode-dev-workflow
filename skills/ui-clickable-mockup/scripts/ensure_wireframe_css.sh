#!/bin/sh
# Ensure wireframe.css exists in the mockups directory.
# Usage: ensure_wireframe_css.sh [mockups-dir]
set -eu
dir=${1:-docs/specifications/ui/mockups}
script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
src="$script_dir/../assets/wireframe.css"
mkdir -p "$dir"
if [ ! -f "$dir/wireframe.css" ]; then
  cp "$src" "$dir/wireframe.css"
  echo "created $dir/wireframe.css"
else
  echo "exists $dir/wireframe.css"
fi
