#!/usr/bin/env bash
# Helper dùng chung cho script CI: báo lỗi dạng GitHub annotation + step summary.
# Script gọi phải chạy bằng bash và source file này:
#   source "$(dirname "$0")/ci-report.sh"
#   ci_begin "Tên kiểm tra"
#   ci_error "path/file.cs" 12 "Mô tả lỗi"
#   ci_done

CI_ERRORS=0
CI_WARNINGS=0
CI_CHECKED=0
CI_TITLE="Kiểm tra"
CI_ROWS=()

# GitHub annotation cần escape %, xuống dòng và ký tự phân tách property.
_ci_escape_data() {
    local s="$1"
    s="${s//'%'/'%25'}"
    s="${s//$'\r'/'%0D'}"
    s="${s//$'\n'/'%0A'}"
    printf '%s' "$s"
}

_ci_escape_prop() {
    local s
    s="$(_ci_escape_data "$1")"
    s="${s//','/'%2C'}"
    s="${s//':'/'%3A'}"
    printf '%s' "$s"
}

# Escape ký tự | để không phá bảng markdown.
_ci_md() {
    local s="$1"
    s="${s//'|'/'\\|'}"
    printf '%s' "$s"
}

ci_begin() {
    CI_TITLE="$1"
    CI_ERRORS=0
    CI_WARNINGS=0
    CI_CHECKED=0
    CI_ROWS=()
}

_ci_record() {
    local level="$1" file="$2" line="$3" msg="$4"
    CI_ROWS+=("$level|$file|$line|$msg")
    if [ "${GITHUB_ACTIONS:-}" != "true" ]; then
        return 0
    fi

    local props="title=$(_ci_escape_data "$CI_TITLE")"
    if [ -n "$file" ]; then
        props="file=$(_ci_escape_prop "$file"),$props"
        if [ -n "$line" ] && [ "$line" != "0" ]; then
            props="line=$line,$props"
        fi
    fi

    local label="error"
    [ "$level" = "warning" ] && label="warning"
    printf '::%s %s::%s\n' "$label" "$props" "$(_ci_escape_data "$msg")"
}

# ci_error <file> <line> <message>  (file/line có thể rỗng hoặc 0)
ci_error() {
    local file="$1" line="${2:-0}" msg="$3"
    CI_ERRORS=$((CI_ERRORS + 1))
    _ci_record "error" "$file" "$line" "$msg"
}

# ci_warning <file> <line> <message>
ci_warning() {
    local file="$1" line="${2:-0}" msg="$3"
    CI_WARNINGS=$((CI_WARNINGS + 1))
    _ci_record "warning" "$file" "$line" "$msg"
}

# ci_notice <message>  (in ra log, không tính là lỗi)
ci_notice() {
    printf '  %s\n' "$1"
}

ci_set_checked() {
    CI_CHECKED="$1"
}

# Ghi summary + exit code. Trả về 1 nếu có lỗi.
ci_done() {
    local exit_code=0
    [ "$CI_ERRORS" -gt 0 ] && exit_code=1

    if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
        {
            printf '### %s\n\n' "$CI_TITLE"
            printf -- '- Đã kiểm tra: %s mục\n' "$CI_CHECKED"
            printf -- '- Lỗi: %s\n' "$CI_ERRORS"
            printf -- '- Cảnh báo: %s\n' "$CI_WARNINGS"
            if [ "${#CI_ROWS[@]}" -gt 0 ]; then
                printf '\n| Mức | File | Dòng | Nội dung |\n|---|---|---|---|\n'
                local row level file line msg count=0
                for row in "${CI_ROWS[@]}"; do
                    count=$((count + 1))
                    if [ "$count" -gt 200 ]; then
                        printf '| ... | ... | ... | Còn %s mục khác trong log |\n' "$(( ${#CI_ROWS[@]} - 200 ))"
                        break
                    fi
                    IFS='|' read -r level file line msg <<< "$row"
                    [ -n "$line" ] || line="-"
                    printf '| %s | `%s` | %s | %s |\n' \
                        "$level" "$(_ci_md "$file")" "$line" "$(_ci_md "$msg")"
                done
            fi
            printf '\n'
        } >> "$GITHUB_STEP_SUMMARY"
    fi

    if [ "$CI_ERRORS" -gt 0 ]; then
        printf '%s: %s lỗi, %s cảnh báo.\n' "$CI_TITLE" "$CI_ERRORS" "$CI_WARNINGS"
    else
        printf '%s: OK (%s mục, %s cảnh báo).\n' "$CI_TITLE" "$CI_CHECKED" "$CI_WARNINGS"
    fi

    return "$exit_code"
}
