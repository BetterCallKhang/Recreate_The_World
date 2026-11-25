#!/usr/bin/env bash
# Kiểm tra format C# bằng CSharpier (không cần .csproj/.sln).
# Dùng local: bash scripts/check-csharp-format.sh [thu-muc]
# Trên CI: tự phát annotation file và ghi step summary.
# Exit 0: đạt; 1: có file chưa format hoặc CSharpier lỗi.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/ci-report.sh
source "$SCRIPT_DIR/ci-report.sh"

ROOT="${1:-src/Recreate_The_World/Assets}"

ci_begin "C# format (CSharpier)"

if [ ! -d "$ROOT" ]; then
    ci_warning "" 0 "Không tìm thấy $ROOT, bỏ qua kiểm tra C#"
    ci_done
    exit $?
fi

mapfile -t cs_files < <(find "$ROOT" -name '*.cs' -type f | sort)

if [ "${#cs_files[@]}" -eq 0 ]; then
    ci_notice "Không có file .cs nào trong $ROOT"
    ci_done
    exit $?
fi

ci_set_checked "${#cs_files[@]}"

if ! command -v dotnet >/dev/null 2>&1; then
    if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
        ci_error "" 0 "Không có dotnet trên runner, không thể chạy CSharpier"
    else
        ci_warning "" 0 "Không có dotnet, bỏ qua CSharpier (cài .NET SDK 8 để kiểm tra local)"
    fi
    ci_done
    exit $?
fi

if [ -f ".config/dotnet-tools.json" ]; then
    if ! restore_log="$(dotnet tool restore 2>&1)"; then
        ci_error "" 0 "dotnet tool restore thất bại"
        printf '%s\n' "$restore_log"
        ci_done
        exit $?
    fi
fi

set -o pipefail
check_log="$(dotnet csharpier --check "$ROOT" --no-cache 2>&1)"
check_status=$?

if [ -n "$check_log" ]; then
    printf '%s\n' "$check_log"
fi

if [ "$check_status" -ne 0 ]; then
    matched=0
    while IFS= read -r line; do
        if [[ "$line" =~ ([^[:space:]]+\.cs) ]]; then
            file="${BASH_REMATCH[1]}"
            file="${file#./}"
            if [ -f "$file" ]; then
                matched=$((matched + 1))
                ci_error "$file" 0 "Chưa format theo CSharpier — chạy: npm run format:csharp"
            fi
        fi
    done <<< "$check_log"

    if [ "$matched" -eq 0 ]; then
        ci_error "" 0 "CSharpier trả mã lỗi $check_status, xem log phía trên"
    fi
fi

ci_done
