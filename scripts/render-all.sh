#!/bin/sh
set -eu

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
manifest="${1:-$root_dir/templates/render-manifest.tsv}"

if [ ! -f "$manifest" ]; then
    echo "Manifest not found: $manifest" >&2
    exit 1
fi

while IFS="$(printf '\t')" read -r template output; do
    case "${template:-}" in
        ""|\#*) continue ;;
    esac

    "$root_dir/scripts/render-template.sh" "$root_dir/$template" "$root_dir/$output"
done < "$manifest"

echo "Rendered templates from $manifest"
