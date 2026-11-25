# Tech Stack

Tài liệu ghi lại phiên bản và lựa chọn công nghệ của dự án. Khi nâng cấp, cập nhật file này cùng lúc với `Packages/manifest.json`.

## 1. Game (Unity)

| Thành phần | Phiên bản | Ghi chú |
|---|---|---|
| Unity Editor | `6000.3.29f1` (Unity 6.3) | Ghim theo `ProjectSettings/ProjectVersion.txt` |
| Universal RP | `17.3.0` | Dùng **2D Renderer** (`Assets/Settings/Renderer2D.asset`) |
| Input System | `1.20.1` | Action map: `Assets/Settings/InputSystem_Actions.inputactions` |
| uGUI | `2.0.0` | UI runtime |
| 2D Animation | `13.0.6` | Skeletal / sprite animation |
| Aseprite Importer | `3.0.2` | Import file `.aseprite` |
| PSD Importer | `12.0.2` | Import file `.psd` nhiều layer |
| 2D SpriteShape | `13.0.0` | Địa hình dạng spline |
| 2D Tilemap | `1.0.0` + Extras `6.0.3` | Tilemap, rule tile, brush |
| Test Framework | `1.6.0` | NUnit, EditMode + PlayMode |
| Timeline | `1.8.13` | Cutscene / sequence |
| Visual Scripting | `1.9.13` | Chỉ dùng khi thật cần, ưu tiên C# |
| Collab Proxy | `2.14.0` | Mặc định của template, không dùng cho workflow nhóm |
| IDE | Rider `3.1.0`, Visual Studio `2.0.26` | |

Danh sách đầy đủ: `src/Recreate_The_World/Packages/manifest.json`.

### Quy tắc nâng cấp

- Không nâng Unity version tùy ý. Nâng phải có PR riêng, cả nhóm thống nhất và chạy lại test.
- Package thêm mới phải commit **cả** `manifest.json` và `packages-lock.json`.
- Không chỉnh sửa trực tiếp trong `Library/PackageCache` — mọi tùy biến package phải nằm trong `Assets/` hoặc package nhúng.

## 2. Ngôn ngữ & kiến trúc code

| Hạng mục | Lựa chọn |
|---|---|
| Ngôn ngữ | C# (game), TypeScript (web — dự kiến) |
| Kiến trúc assembly | `Game.Core` → `Game.Scripts` → test assemblies |
| Logic thuần | `Game.Core` không phụ thuộc `UnityEngine` |
| Dữ liệu cấu hình | ScriptableObject trong `Assets/_Project/ScriptableObjects` |
| Định dạng format | `.editorconfig` ở root |
| Test | NUnit qua Unity Test Framework |

## 3. Web tải game (`src/download-web`)

Các mục dưới là lựa chọn dự kiến, sẽ chốt khi bắt đầu làm.

| Thành phần | Dự kiến |
|---|---|
| Framework | TBD (Next.js / Vite + React) |
| Ngôn ngữ | TypeScript |
| Package manager | npm hoặc pnpm |
| Test | Vitest / Playwright |
| Đóng gói | Docker multi-stage (Node build → static serve) |
| Hosting | TBD |

## 4. CI/CD

| Pipeline | Mục đích |
|---|---|
| `ci.yml` | Gate chung, chia job nhỏ: commit message, tên nhánh + luồng PR, phát hiện thay đổi Unity, format text, quy tắc project Unity, format C#, compile + EditMode test. Các job Unity chỉ chạy khi commit/branch đã pass và có thay đổi trong `src/Recreate_The_World` |
| `unity-build-playmode.yml` | (dự kiến) PlayMode test + build thử game |
| `web-ci.yml` | (dự kiến) Lint, unit test, build thử web |
| `web-cd.yml` | (dự kiến) Build Docker image & deploy khi push `main`/`release` |

## 5. Môi trường phát triển

| Thành phần | Yêu cầu |
|---|---|
| Unity Hub | Bản mới nhất |
| Unity Editor | `6000.3.29f1` |
| Git | `>= 2.30` |
| Git LFS | Bắt buộc (`git lfs install`) |
| Node.js | `>= 18` (dùng cho husky + commitlint) |
| npm | Đi kèm Node.js |
| .NET SDK | `8.0` (chạy CSharpier kiểm tra format C#) |
| OS | Linux (hiện tại), Windows/macOS |

## 6. Công cụ repo

| Công cụ | Phiên bản | Vai trò |
|---|---|---|
| Node.js | `>= 18` | Runtime cho git hook và CI |
| npm | đi kèm Node.js | Cài devDependencies ở root |
| husky | `9.1.7` | Cài git hook `commit-msg` |
| @commitlint/cli | `21.2.4` | Kiểm tra commit message |
| @commitlint/config-conventional | `21.2.4` | Bộ luật Conventional Commits |
| CSharpier | `0.30.6` | Format C# (khai báo trong `.config/dotnet-tools.json`) |

Cấu hình commit: `.commitlintrc.cjs` · Hook: `.husky/commit-msg` · CI: `.github/workflows/ci.yml` (job `commitlint`)

Kiểm tra tên nhánh: `scripts/check-branch-name.sh` · Hook: `.husky/pre-push` · CI: `.github/workflows/ci.yml` (job `branch_name`)

Kiểm tra format text: `scripts/check-format.sh` · CI: job `format_check`

Kiểm tra project Unity: `scripts/check-unity-project.sh` (`.meta`, asmdef, `Game.Core` thuần C#) · CI: job `unity_project`

Kiểm tra format C#: `scripts/check-csharp-format.sh` · Cấu hình: `.csharpierrc.json`, `.csharpierignore` · CI: job `csharp_format`
