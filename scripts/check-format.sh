#!/usr/bin/env bash
# Kiểm tra format text theo .editorconfig + cú pháp JSON/YAML/asmdef.
# Dùng local: bash scripts/check-format.sh
# Trên CI: tự phát annotation file:line và ghi step summary.
# Exit 0: đạt; 1: có lỗi.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/ci-report.sh
source "$SCRIPT_DIR/ci-report.sh"

tab=$'\t'

ci_begin "Format và cú pháp"

# Chỉ kiểm tra file text trong repo, bỏ qua Library/, node_modules/, file ignore.
# --cached: file đã track; --others: file mới chưa add (bắt lỗi trước khi commit).
mapfile -t files < <(git ls-files -z --cached --others --exclude-standard -- \
    '*.cs' '*.asmdef' '*.json' '*.yml' '*.yaml' \
    '*.md' '*.sh' '*.cjs' '*.mjs' '*.js' '*.ts' '*.tsx' \
    | tr '\0' '\n')

for f in "${files[@]}"; do
    [ -f "$f" ] || continue
    ci_set_checked "$((CI_CHECKED + 1))"

    # 1. Kết thúc bằng newline
    if [ -n "$(tail -c 1 "$f" 2>/dev/null)" ]; then
        ci_error "$f" 0 "Thiếu newline ở cuối file"
    fi

    # 2. Chỉ LF, không CRLF
    if grep -q "$(printf '\r')" "$f" 2>/dev/null; then
        line=$(grep -n "$(printf '\r')" "$f" | head -n 1 | cut -d: -f1)
        ci_error "$f" "$line" "Chứa CRLF, cần chuyển sang LF"
    fi

    # 3. UTF-8 hợp lệ
    if ! iconv -f UTF-8 -t UTF-8 "$f" >/dev/null 2>&1; then
        ci_error "$f" 0 "Không phải UTF-8 hợp lệ"
    fi

    # 4. Khoảng trắng cuối dòng (trừ .md vì cho phép)
    case "$f" in
        *.md) ;;
        *)
            if grep -n '[[:blank:]]$' "$f" >/dev/null 2>&1; then
                while IFS=: read -r line _; do
                    ci_error "$f" "$line" "Có khoảng trắng ở cuối dòng"
                done < <(grep -n '[[:blank:]]$' "$f")
            fi
            ;;
    esac

    # 5. Không dùng tab để thụt lề
    if grep -n "^ *$tab" "$f" >/dev/null 2>&1; then
        while IFS=: read -r line _; do
            ci_error "$f" "$line" "Dùng tab để thụt lề (cần space)"
        done < <(grep -n "^ *$tab" "$f")
    fi
done

# 6. JSON / asmdef hợp lệ
if command -v node >/dev/null 2>&1; then
    mapfile -t json_files < <(git ls-files -z --cached --others --exclude-standard -- '*.json' '*.asmdef' | tr '\0' '\n')
    for f in "${json_files[@]}"; do
        [ -f "$f" ] || continue
        if ! node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$f" >/dev/null 2>&1; then
            ci_error "$f" 0 "JSON/asmdef không hợp lệ (không parse được)"
        fi
    done
else
    ci_warning "" 0 "Không có node, bỏ qua kiểm tra JSON/asmdef"
fi

# 7. YAML hợp lệ (ruby có sẵn trên runner GitHub Actions)
if command -v ruby >/dev/null 2>&1 && ruby -ryaml -e 'exit 0' >/dev/null 2>&1; then
    mapfile -t yaml_files < <(git ls-files -z --cached --others --exclude-standard -- '*.yml' '*.yaml' | tr '\0' '\n')
    for f in "${yaml_files[@]}"; do
        [ -f "$f" ] || continue
        if ! ruby -ryaml -e 'YAML.load_file(ARGV[0])' "$f" >/dev/null 2>&1; then
            ci_error "$f" 0 "YAML không hợp lệ (không parse được)"
        fi
    done
else
    ci_warning "" 0 "Không có ruby, bỏ qua kiểm tra YAML"
fi

ci_done
