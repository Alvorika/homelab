#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <template-file> <output-file>" >&2
    exit 2
fi

if ! command -v envsubst >/dev/null 2>&1; then
    echo "envsubst is required. Install gettext or gettext-base." >&2
    exit 127
fi

template_file="$1"
output_file="$2"

if [ ! -f "$template_file" ]; then
    echo "Template not found: $template_file" >&2
    exit 1
fi

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

if [ -f "$root_dir/.env" ]; then
    set -a
    # shellcheck disable=SC1091
    . "$root_dir/.env"
    set +a
fi

mkdir -p "$(dirname "$output_file")"

var_names="$(grep -o '\${[A-Za-z_][A-Za-z0-9_]*}' "$template_file" | sed 's/[${}]//g' | sort -u)"
for var_name in $var_names; do
    eval "var_value=\${$var_name:-}"
    if [ -z "$var_value" ]; then
        echo "Required template variable is empty: $var_name" >&2
        exit 1
    fi
done

env_format="$(printf '%s\n' "$var_names" | sed 's/^/$/' | tr '\n' ' ')"
envsubst "$env_format" < "$template_file" > "$output_file"

if grep -n '\${[A-Za-z_][A-Za-z0-9_]*}' "$output_file" >/dev/null 2>&1; then
    echo "Warning: unresolved placeholders remain in $output_file:" >&2
    grep -n '\${[A-Za-z_][A-Za-z0-9_]*}' "$output_file" >&2
fi

echo "Rendered $output_file"
