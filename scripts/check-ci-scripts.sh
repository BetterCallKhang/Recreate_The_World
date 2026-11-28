#!/usr/bin/env bash
# Kiểm tra CI, shell script và tooling: cú pháp bash, ShellCheck, cú pháp JS,
# parse YAML workflow. Dùng local: bash scripts/check-ci-scripts.sh
# Trên CI: tự phát annotation file và ghi step summary.
# Exit 0: đạt; 1: có lỗi.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/ci-report.sh
source "$SCRIPT_DIR/ci-report.sh"

ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT" || exit 1

ci_begin "CI và script"

# ---------------------------------------------------------------------------
# 1. Cú pháp shell (bash -n)
# ---------------------------------------------------------------------------
sh_files=()
for f in scripts/*.sh .husky/commit-msg .husky/pre-push .husky/pre-commit; do
    [ -f "$f" ] && sh_files+=("$f")
done

for f in "${sh_files[@]}"; do
    ci_set_checked "$((CI_CHECKED + 1))"
    if ! out="$(bash -n "$f" 2>&1)"; then
        ci_error "$f" 0 "Cú pháp bash không hợp lệ: ${out:-không rõ lỗi}"
    fi
done

# ---------------------------------------------------------------------------
# 2. ShellCheck (runner GitHub có sẵn; local có thể không có)
# ---------------------------------------------------------------------------
if command -v shellcheck >/dev/null 2>&1; then
    for f in "${sh_files[@]}"; do
        ci_set_checked "$((CI_CHECKED + 1))"
        args=(-f gcc --severity=error)
        case "$f" in
            .husky/*) args+=(-s sh) ;;
        esac

        if ! out="$(shellcheck "${args[@]}" "$f" 2>&1)"; then
            while IFS= read -r line; do
                [ -n "$line" ] || continue
                case "$line" in
                    *": error: "*)
                        file="${line%%:*}"
                        rest="${line#*:}"
                        line_no="${rest%%:*}"
                        ci_error "$file" "${line_no:-0}" "ShellCheck: ${line#*: error: }"
                        ;;
                    *)
                        ci_error "$f" 0 "ShellCheck: $line"
                        ;;
                esac
            done <<< "$out"
        fi
    done
else
    ci_warning "" 0 "Không có shellcheck, bỏ qua (runner GitHub đã cài sẵn)"
fi

# ---------------------------------------------------------------------------
# 3. Cú pháp JavaScript / Node config
# ---------------------------------------------------------------------------
if command -v node >/dev/null 2>&1; then
    while IFS= read -r f; do
        [ -f "$f" ] || continue
        ci_set_checked "$((CI_CHECKED + 1))"
        if ! out="$(node --check "$f" 2>&1)"; then
            ci_error "$f" 0 "Cú pháp JS không hợp lệ: $out"
        fi
    done < <(git ls-files '*.js' '*.cjs' '*.mjs' 2>/dev/null)
else
    ci_warning "" 0 "Không có node, bỏ qua kiểm tra cú pháp JS"
fi

# ---------------------------------------------------------------------------
# 4. YAML workflow
# ---------------------------------------------------------------------------
if command -v ruby >/dev/null 2>&1 && ruby -ryaml -e 'exit 0' >/dev/null 2>&1; then
    while IFS= read -r f; do
        [ -f "$f" ] || continue
        ci_set_checked "$((CI_CHECKED + 1))"
        if ! out="$(ruby -ryaml -e 'YAML.load_file(ARGV[0])' "$f" 2>&1)"; then
            ci_error "$f" 0 "YAML không hợp lệ: $out"
        fi
    done < <(git ls-files '.github/workflows/*.yml' '.github/workflows/*.yaml' 2>/dev/null)
else
    ci_warning "" 0 "Không có ruby, bỏ qua kiểm tra YAML"
fi

ci_done
