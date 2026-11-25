# Hướng dẫn cho GitHub Copilot

File này là **con trỏ**, không phải nguồn luật. Nguồn luật duy nhất là `AGENTS.md`.

Trước khi gợi ý/sửa code trong repo này:

1. Đọc `AGENTS.md` ở root — ràng buộc dự án, quy trình, Definition of Done.
2. Đọc `.ai/config.json` — đặc biệt cờ `autoCommit`.
3. Đọc tài liệu liên quan: `docs/tech-stack.md`, `docs/architecture.md`, `docs/coding-conventions.md`, `src/Recreate_The_World/README.md`.

## Tóm tắt ràng buộc quan trọng

- `Game.Core` là C# thuần — **không** dùng `UnityEngine`, kể cả `Vector2`, `Debug`, `Random`.
- Dependency một chiều: `Game.Core` → `Game.Scripts` → test assemblies.
- Không xóa/tạo lại file `.meta`; không commit `Library/`, `Temp/`, `Logs/`, `UserSettings/`, `Builds/`, `*.csproj`, `*.sln`.
- Asset đặt đúng `Assets/_Project/<Loại>/<Module>/`; binary đi qua Git LFS.
- Không push trực tiếp `main`/`dev`; nhánh theo regex trong `docs/coding-conventions.md` mục 3.1.
- Luồng PR: `<type>/*` → `dev`; chỉ `dev` được PR vào `main`.
- Commit theo Conventional Commits: `<type>(<scope>): <mô tả>`.

## Auto-commit

`autoCommit = false` (mặc định): **không** commit, không push, không tạo PR — chỉ sửa file và liệt kê thay đổi.
`autoCommit = true`: được tự commit sau khi pass kiểm tra, nhưng push/PR vẫn cần người dùng xác nhận.
Thiếu key hoặc không đọc được `.ai/config.json` → coi là `false`.
