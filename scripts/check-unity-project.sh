#!/usr/bin/env bash
# Kiểm tra cấu trúc project Unity: .meta, asmdef, hướng phụ thuộc, Game.Core thuần C#.
# Dùng local: bash scripts/check-unity-project.sh [thu-muc-unity]
# Trên CI: tự phát annotation file:line và ghi step summary.
# Exit 0: đạt; 1: có lỗi.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/ci-report.sh
source "$SCRIPT_DIR/ci-report.sh"

UNITY_DIR="${1:-src/Recreate_The_World}"
ASSETS_DIR="$UNITY_DIR/Assets"
CORE_DIR="$ASSETS_DIR/_Project/Scripts/Core"

ci_begin "Unity project"

if [ ! -d "$ASSETS_DIR" ]; then
    ci_warning "" 0 "Không tìm thấy $ASSETS_DIR, bỏ qua kiểm tra project Unity"
    ci_done
    exit $?
fi

# ---------------------------------------------------------------------------
# 1. Mỗi file/folder trong Assets phải có .meta, và .meta phải có file gốc
# ---------------------------------------------------------------------------
while IFS= read -r -d '' p; do
    case "$(basename "$p")" in
        .DS_Store | Thumbs.db) continue ;;
    esac
    ci_set_checked "$((CI_CHECKED + 1))"
    if [ ! -e "$p.meta" ]; then
        ci_error "$p" 0 "Thiếu file .meta (Unity sẽ sinh GUID mới, mất tham chiếu)"
    fi
done < <(find "$ASSETS_DIR" -mindepth 1 ! -name '*.meta' ! -name '.*' -print0)

while IFS= read -r -d '' p; do
    ci_set_checked "$((CI_CHECKED + 1))"
    if [ ! -e "${p%.meta}" ]; then
        ci_error "$p" 0 "File .meta mồ côi: không còn file/folder gốc"
    fi
done < <(find "$ASSETS_DIR" -name '*.meta' -print0)

# ---------------------------------------------------------------------------
# 2. asmdef: reference phải resolve, Game.Core không tham chiếu assembly khác,
#    assembly production không tham chiếu test assembly
# ---------------------------------------------------------------------------
if command -v node >/dev/null 2>&1; then
    ASMDEF_FINDINGS="$(
        ASSETS_DIR="$ASSETS_DIR" node <<'JS'
const fs = require("fs");
const path = require("path");

const root = process.env.ASSETS_DIR;

function walk(dir, out = []) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const p = path.join(dir, entry.name);
        if (entry.isDirectory()) walk(p, out);
        else if (p.endsWith(".asmdef")) out.push(p);
    }
    return out;
}

const files = walk(root);
const byName = new Map();
const byGuid = new Map();

for (const f of files) {
    let json;
    try {
        json = JSON.parse(fs.readFileSync(f, "utf8"));
    } catch (e) {
        console.log(`ERR\t${f}\t0\tasmdef không parse được: ${e.message}`);
        continue;
    }
    byName.set(json.name, f);
    try {
        const meta = fs.readFileSync(`${f}.meta`, "utf8");
        const m = meta.match(/guid:\s*([0-9a-fA-F]{32})/);
        if (m) byGuid.set(m[1].toLowerCase(), f);
    } catch (_) {
        // thiếu .meta đã được báo ở phần trước
    }
}

function lineOf(file, needle) {
    const lines = fs.readFileSync(file, "utf8").split("\n");
    const index = lines.findIndex((l) => l.includes(needle));
    return index >= 0 ? index + 1 : 0;
}

for (const f of files) {
    let json;
    try {
        json = JSON.parse(fs.readFileSync(f, "utf8"));
    } catch (_) {
        continue;
    }

    const name = json.name || path.basename(f, ".asmdef");
    const refs = Array.isArray(json.references) ? json.references : [];
    const isTest = /Tests?$/i.test(name);
    const isCore = name === "Game.Core" || f.includes("/Scripts/Core/");

    for (const ref of refs) {
        if (typeof ref !== "string") continue;
        if (ref.startsWith("GUID:")) {
            const guid = ref.slice(5).toLowerCase();
            if (!byGuid.has(guid)) {
                console.log(`ERR\t${f}\t${lineOf(f, ref)}\tReference '${ref}' không trỏ tới asmdef nào trong project`);
            }
        } else if (/Tests?$/i.test(ref) && !isTest) {
            console.log(`ERR\t${f}\t${lineOf(f, ref)}\tAssembly production không được tham chiếu test assembly '${ref}'`);
        }
    }

    if (isCore) {
        if (refs.length > 0) {
            console.log(`ERR\t${f}\t${lineOf(f, '"references"')}\tGame.Core phải độc lập, không tham chiếu assembly khác (đang có ${refs.length})`);
        }
        if (json.noEngineReferences !== true) {
            console.log(`ERR\t${f}\t${lineOf(f, '"noEngineReferences"')}\tGame.Core phải đặt "noEngineReferences": true`);
        }
    }
}
JS
    )"

    if [ -n "$ASMDEF_FINDINGS" ]; then
        while IFS=$'\t' read -r level file line message; do
            [ -n "${level:-}" ] || continue
            ci_error "$file" "$line" "$message"
        done <<< "$ASMDEF_FINDINGS"
    fi
else
    ci_warning "" 0 "Không có node, bỏ qua kiểm tra asmdef"
fi

# ---------------------------------------------------------------------------
# 3. Game.Core không được dùng UnityEngine/UnityEditor
# ---------------------------------------------------------------------------
if [ -d "$CORE_DIR" ]; then
    while IFS= read -r -d '' f; do
        ci_set_checked "$((CI_CHECKED + 1))"
        while IFS=: read -r line _; do
            ci_error "$f" "$line" "Game.Core không được dùng UnityEngine/UnityEditor (chỉ C# thuần hoặc System.*)"
        done < <(grep -nE '(^|[^A-Za-z0-9_])(UnityEngine|UnityEditor)([.;[:space:](]|$)' "$f" || true)
    done < <(find "$CORE_DIR" -name '*.cs' -print0)
fi

# ---------------------------------------------------------------------------
# 4. Không track thư mục sinh tự động / file build
# ---------------------------------------------------------------------------
while IFS= read -r f; do
    [ -n "$f" ] || continue
    ci_set_checked "$((CI_CHECKED + 1))"
    ci_error "$f" 0 "Không được commit file/thư mục sinh tự động (Library, Temp, Logs, UserSettings, Builds, csproj, sln)"
done < <(
    git ls-files -- \
        "$UNITY_DIR/Library/*" "$UNITY_DIR/Temp/*" "$UNITY_DIR/Logs/*" \
        "$UNITY_DIR/UserSettings/*" "$UNITY_DIR/Builds/*" \
        '*.csproj' '*.sln' '*.slnx' 2>/dev/null || true
)

ci_done
