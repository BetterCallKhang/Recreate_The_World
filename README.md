# Recreate The World

Game **2D** phát triển bằng **Unity 6.3 (URP 2D Renderer)** — đồ án tốt nghiệp (capstone).

Repo chứa project Unity, tài liệu kiến trúc, tooling Git (commit/branch check) và CI. Web giới thiệu & tải game sẽ nằm ở `src/download-web/` (chưa triển khai).

| | |
|---|---|
| Unity Editor | `6000.3.29f1` (Unity 6.3) |
| Render Pipeline | Universal RP `17.3.0` — 2D Renderer |
| Input | Input System `1.20.1` |
| Ngôn ngữ | C# (game), TypeScript (web, dự kiến) |
| Test | Unity Test Framework `1.6.0` (NUnit, EditMode + PlayMode) |
| CI/CD | GitHub Actions |
| Repo | <https://github.com/BetterCallKhang/Recreate_The_World> |

---

## 1. Cấu trúc repo

Chỉ mô tả các cấp gần nhất. Mỗi thư mục lớn có README riêng đi sâu hơn.

```text
Recreate_The_World/
├── src/
│   └── Recreate_The_World/      # Project Unity → đọc README trong thư mục này
├── docs/                        # Tài liệu dự án
│   ├── tech-stack.md            # Phiên bản Unity, package, công cụ
│   ├── architecture.md          # Kiến trúc asmdef, luồng dữ liệu, web
│   ├── coding-conventions.md    # Quy ước code, asset, nhánh, commit, PR
│   ├── review.md                # Hướng dẫn review code (SOLID, YAGNI, ...)
│   └── performance-benchmarks/  # Báo cáo hiệu năng theo mốc
├── .github/
│   ├── workflows/               # CI: ci.yml (commit, branch, format, Unity)
│   └── pull_request_template.md # Template PR
├── scripts/                     # Script dùng chung local + CI
├── .config/                     # Pin dotnet tool (CSharpier)
├── .csharpierrc.json            # Cấu hình format C#
├── .ai/                         # Cấu hình AI agent (đọc AGENTS.md)
├── .husky/                      # Git hook: commit-msg, pre-push
├── AGENTS.md                    # Luật bắt buộc cho AI agent
├── .editorconfig                # Format code (UTF-8, LF, 4 space)
├── .gitattributes               # Git LFS cho asset binary
├── package.json                 # husky + commitlint (Node tooling)
└── README.md
```

Chi tiết bên trong project Unity (thư mục `Assets/`, asmdef, scene, cách build): xem [`src/Recreate_The_World/README.md`](src/Recreate_The_World/README.md).

---

## 2. Yêu cầu môi trường

| Thành phần | Yêu cầu | Ghi chú |
|---|---|---|
| Git | `>= 2.30` | |
| Git LFS | Bắt buộc | Asset `.png`, `.psd`, `.wav`, `.ttf`... lưu qua LFS |
| Unity Hub | Bản mới nhất | |
| Unity Editor | `6000.3.29f1` | **Đúng version**, không tự nâng |
| Node.js | `>= 18` | Chạy husky + commitlint |
| npm | Đi kèm Node.js | Cài devDependencies ở root |
| IDE | Rider hoặc Visual Studio | Hỗ trợ qua package có sẵn |

---

## 3. Setup lần đầu

### 3.1. Clone repo (có Git LFS)

```bash
git lfs install          # 1 lần cho mỗi máy
git clone git@github.com:BetterCallKhang/Recreate_The_World.git
cd Recreate_The_World
git lfs pull             # nếu clone trước khi cài LFS
```

Kiểm tra LFS hoạt động:

```bash
git lfs ls-files | head
```

### 3.2. Cài Node tooling (git hook + commitlint)

```bash
npm ci        # cài đúng version trong package-lock.json
```

`npm ci` chạy `prepare` → husky cài hook vào `.husky/`. Không có bước này, commit sai format sẽ **không bị chặn ở local** (CI vẫn bắt).

Kiểm tra:

```bash
npm run check:branch        # tên nhánh hiện tại
echo "feat: test" | npx commitlint
```

### 3.3. Mở project Unity

1. Mở **Unity Hub** → **Installs** → cài editor `6000.3.29f1`
2. **Add project from disk** → chọn `src/Recreate_The_World`
3. Mở project, chờ import package lần đầu (có thể vài phút)
4. Mở `Assets/_Project/Scenes/SampleScene.unity` → bấm **Play**

### 3.4. Chạy test

**Window ▸ General ▸ Test Runner**

- **EditMode**: test logic `Game.Core`, chạy nhanh
- **PlayMode**: test va chạm, scene, luồng gameplay

Hiện chưa có test case — chỉ mới có asmdef và khung thư mục.

### 3.5. Kiểm tra setup thành công

- [ ] Unity mở project không lỗi compile trong **Console**
- [ ] Scene `SampleScene` chạy được
- [ ] `npm run check:branch` chạy được
- [ ] Commit thử sai format bị hook chặn
- [ ] `git status` không thấy `Library/`, `Temp/`, `Logs/`, `UserSettings/`

---

## 4. Lệnh thường dùng

| Lệnh | Việc |
|---|---|
| `npm run check:branch` | Kiểm tra tên nhánh hiện tại |
| `sh scripts/check-branch-name.sh <ten-nhanh>` | Kiểm tra một tên nhánh bất kỳ |
| `npm run check:format` | Kiểm tra format + cú pháp JSON/YAML toàn repo |
| `npm run check:unity` | Kiểm tra `.meta`, asmdef, `Game.Core` thuần C# |
| `npm run check:csharp` | Kiểm tra format C# bằng CSharpier |
| `npm run format:csharp` | Format C# (tự sửa file) |
| `echo "feat: mo ta" \| npx commitlint` | Kiểm tra commit message |
| `npx commitlint --last` | Kiểm tra commit gần nhất |
| `git lfs ls-files` | Xem file đang quản lý bởi LFS |

Quy trình đóng góp: [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

## 5. Tài liệu

| File | Nội dung |
|---|---|
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Quy trình đóng góp, kiểm tra biên dịch để pass CI |
| [`docs/tech-stack.md`](docs/tech-stack.md) | Phiên bản Unity/package, công cụ, CI |
| [`docs/architecture.md`](docs/architecture.md) | Kiến trúc asmdef, luồng dữ liệu, kế hoạch web |
| [`docs/coding-conventions.md`](docs/coding-conventions.md) | Code C#, asset, nhánh, commit, PR |
| [`docs/review.md`](docs/review.md) | Checklist review code: SOLID, YAGNI, KISS, không magic value/variable |
| [`docs/performance-benchmarks/baseline-report.md`](docs/performance-benchmarks/baseline-report.md) | Baseline FPS, frame time, GC Alloc, RAM |
| [`src/Recreate_The_World/README.md`](src/Recreate_The_World/README.md) | Mở project, cấu trúc `Assets/`, asmdef, build |

---

## 6. Dành cho AI agent

Đọc [`AGENTS.md`](AGENTS.md) trước khi làm bất cứ thay đổi nào. Cấu hình hành vi nằm ở [`.ai/config.json`](.ai/config.json):

| Key | Mặc định | Ý nghĩa |
|---|---|---|
| `autoCommit` | `false` | `false`: agent không tự commit; `true`: agent được tự commit sau khi pass kiểm tra |
| `writeTests` | `true` | `true`: logic mới phải kèm test; `false`: không bắt buộc viết test mới |

`CLAUDE.md`, `.github/copilot-instructions.md`, `.cursor/rules/project.mdc` chỉ là con trỏ tới `AGENTS.md`.
