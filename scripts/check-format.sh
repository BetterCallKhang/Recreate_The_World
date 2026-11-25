#!/usr/bin/env bash
# Kiểm tra format cơ bản theo .editorconfig + cú pháp JSON/YAML.
# Dùng: bash scripts/check-format.sh
# Exit 0: đạt; 1: có lỗi.

set -uo pipefail

errors=0
checked=0
tab=$'\t'

report() {
    printf '  - %s\n' "$1"
    errors=$((errors + 1))
}

# Chỉ kiểm tra file text trong repo, bỏ qua Library/, node_modules/, file ignore.
# --cached: file đã track; --others: file mới chưa add (bắt lỗi trước khi commit).
mapfile -t files < <(git ls-files -z --cached --others --exclude-standard -- \
    '*.cs' '*.asmdef' '*.json' '*.yml' '*.yaml' \
    '*.md' '*.sh' '*.cjs' '*.mjs' '*.js' '*.ts' '*.tsx' \
    | tr '\0' '\n')

for f in "${files[@]}"; do
    [ -f "$f" ] || continue
    checked=$((checked + 1))

    # 1. Kết thúc bằng newline
    if [ -n "$(tail -c 1 "$f" 2>/dev/null)" ]; then
        report "$f: thiếu newline ở cuối file"
    fi

    # 2. Chỉ LF, không CRLF
    if grep -q "$(printf '\r')" "$f" 2>/dev/null; then
        report "$f: chứa CRLF, cần chuyển sang LF"
    fi

    # 3. UTF-8 hợp lệ
    if ! iconv -f UTF-8 -t UTF-8 "$f" >/dev/null 2>&1; then
        report "$f: không phải UTF-8 hợp lệ"
    fi

    # 4. Khoảng trắng cuối dòng (trừ .md vì cho phép)
    case "$f" in
        *.md) ;;
        *)
            if grep -n '[[:blank:]]$' "$f" >/dev/null 2>&1; then
                line=$(grep -n '[[:blank:]]$' "$f" | head -n 1 | cut -d: -f1)
                report "$f:$line: có khoảng trắng ở cuối dòng"
            fi
            ;;
    esac

    # 5. Không dùng tab để thụt lề
    if grep -n "^ *$tab" "$f" >/dev/null 2>&1; then
        line=$(grep -n "^ *$tab" "$f" | head -n 1 | cut -d: -f1)
        report "$f:$line: dùng tab để thụt lề (cần space)"
    fi
done

# 6. JSON / asmdef hợp lệ
if command -v node >/dev/null 2>&1; then
    mapfile -t json_files < <(git ls-files -z --cached --others --exclude-standard -- '*.json' '*.asmdef' | tr '\0' '\n')
    for f in "${json_files[@]}"; do
        [ -f "$f" ] || continue
        if ! node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$f" 2>/dev/null; then
            report "$f: JSON không hợp lệ"
        fi
    done
else
    echo "  (bỏ qua JSON: không có node)"
fi

# 7. YAML hợp lệ (ruby có sẵn trên runner GitHub Actions)
if command -v ruby >/dev/null 2>&1 && ruby -ryaml -e 'exit 0' >/dev/null 2>&1; then
    mapfile -t yaml_files < <(git ls-files -z --cached --others --exclude-standard -- '*.yml' '*.yaml' | tr '\0' '\n')
    for f in "${yaml_files[@]}"; do
        [ -f "$f" ] || continue
        if ! ruby -ryaml -e 'YAML.load_file(ARGV[0])' "$f" >/dev/null 2>&1; then
            report "$f: YAML không hợp lệ"
        fi
    done
else
    echo "  (bỏ qua YAML: không có ruby)"
fi

echo ""
if [ "$errors" -gt 0 ]; then
    echo "Format: $errors lỗi trong $checked file."
    exit 1
fi

echo "Format: OK ($checked file)."
