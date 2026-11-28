# Coding Conventions

Quy ước chung cho toàn repo. Mục tiêu: code nhất quán, review nhanh, diff sạch.

## 1. C# (Unity)

### 1.1 Format

Format C# bằng **CSharpier** (cấu hình `.csharpierrc.json`, bỏ qua `Assets/ThirdParty/`):

```bash
dotnet tool restore                              # cài đúng version trong .config/dotnet-tools.json
npm run format:csharp                            # format toàn bộ C# trong Assets
npm run check:csharp                             # chỉ kiểm tra, không sửa
```

Áp dụng thêm cho mọi file text bởi `.editorconfig` ở root:

- UTF-8, xuống dòng **LF**
- Indent **4 space**, không dùng tab
- Có dòng trống cuối file
- Không để trailing whitespace (trừ `.meta`)

CI chặn PR nếu `.cs` chưa format hoặc vi phạm `.editorconfig`. Lỗi được gắn đúng file:dòng trên PR.

### 1.2 Đặt tên

| Thành phần | Quy ước | Ví dụ |
|---|---|---|
| Class / struct / enum | `PascalCase` | `PlayerController`, `EnemyState` |
| Interface | `I` + `PascalCase` | `IDamageable`, `IPoolable` |
| Method | `PascalCase` | `TakeDamage()`, `SpawnWave()` |
| Property | `PascalCase` | `CurrentHealth` |
| Private field | `_camelCase` | `_moveSpeed`, `_animator` |
| Public field | **Hạn chế dùng**, ưu tiên property hoặc `[SerializeField] private` | `[SerializeField] private float _speed;` |
| Hằng số | `PascalCase` | `MaxHealth`, `DefaultGravity` |
| Event | `On` + `PascalCase` | `OnDeath`, `OnWaveCleared` |
| Namespace | `Game.<Module>` | `Game.Core.Combat`, `Game.Gameplay.Player` |
| File | Trùng tên class chính | `PlayerController.cs` |

### 1.3 Quy tắc code

- Mỗi file một class public chính.
- `Game.Core` **không** dùng `UnityEngine`; không `Debug.Log`, `FindObjectOfType`, `Instantiate`.
- Không dùng `public` field để expose Inspector; dùng `[SerializeField] private`.
- Cache component trong `Awake`, không `GetComponent` trong `Update`.
- Không hard-code chỉ số gameplay; đưa vào ScriptableObject trong `ScriptableObjects/`.
- Method dài quá ~50 dòng nên tách.
- Comment giải thích **vì sao**, không giải thích **cái gì**; code tự nói cái gì.
- Không commit code debug (`Debug.Log` dày đặc, test tạm, `TODO` không tên người).
- Review code theo checklist trong [`docs/review.md`](review.md) (SOLID, YAGNI, KISS, không magic value/variable).

### 1.4 Assembly

- Script mới phải nằm đúng module: `Scripts/Gameplay/<Module>`, `Scripts/UI`, `Scripts/Core`.
- Không thêm reference chéo tùy tiện; `Game.Core` không được tham chiếu `Game.Scripts`.
- Thêm package mới phải cập nhật `manifest.json` + `packages-lock.json`.

## 2. Asset

### 2.1 Đặt tên

| Loại | Prefix | Ví dụ |
|---|---|---|
| Sprite nhân vật | `CHR_` | `CHR_Player_Idle_01` |
| Sprite kẻ địch | `ENM_` | `ENM_Slime_Walk` |
| Môi trường | `ENV_` | `ENV_Forest_Tree_01` |
| UI | `UI_` | `UI_HUD_HealthBar` |
| Material | `MAT_` | `MAT_Player_Outline` |
| Animation clip | `ANIM_` | `ANIM_Player_Jump` |
| Animator Controller | `AC_` | `AC_Player` |
| Prefab | `PF_` | `PF_Player`, `PF_Slime` |
| ScriptableObject | `SO_` | `SO_SlimeConfig` |
| SFX | `SFX_` | `SFX_Player_Jump` |
| Nhạc nền | `BGM_` | `BGM_MainTheme` |
| Texture | `TEX_` | `TEX_UI_Panel` |

Quy tắc thêm:

- Không dấu tiếng Việt, không khoảng trắng trong tên file.
- Đánh số bằng `_01`, `_02` khi có biến thể.
- Tên folder dùng `PascalCase` cho module (`Player`, `Enemies`), theo cấu trúc `docs/architecture.md`.

### 2.2 `.meta` và Git LFS

- **Luôn commit `.meta`** đi cùng asset/folder. Không bao giờ xóa `.meta` để Unity tạo lại.
- Di chuyển asset bằng Unity hoặc `git mv` (kèm `.meta`).
- File binary (`.png`, `.psd`, `.aseprite`, `.wav`, `.ttf`, `.fbx`...) đi qua Git LFS theo `.gitattributes`.
- Cài `git lfs install` trước khi clone/pull.

## 3. Git

### 3.1 Nhánh

| Nhánh | Mục đích |
|---|---|
| `main` | Production, luôn ổn định. **Chỉ nhận PR từ `dev`**. Cấm push trực tiếp |
| `dev` | Nhánh tích hợp. **Mọi PR tính năng/sửa lỗi nhắm vào đây**. Cấm push trực tiếp |
| `release/<x.y.z>` | Nhánh ổn định phát hành (tùy chọn), cắt từ `dev`, sau đó PR về `dev` |
| `feat/<ten-ngan>` | Tính năng mới |
| `fix/<ten-ngan>` | Sửa lỗi |
| `refactor/<ten-ngan>` | Tái cấu trúc |
| `perf/<ten-ngan>` | Tối ưu hiệu năng |
| `test/<ten-ngan>` | Test |
| `docs/<ten-ngan>` | Tài liệu |
| `chore/<ten-ngan>` | Cấu hình, tooling |
| `build/<ten-ngan>` | Build system |
| `ci/<ten-ngan>` | CI/CD |
| `revert/<ten-ngan>` | Revert |

Luồng hợp lệ:

```text
feat/*  fix/*  docs/*  chore/* ...  ──PR──►  dev  ──PR──►  main
                                             ▲              │
                                             └── không PR ngược ──┘
```

- Nhánh cá nhân **không bao giờ** PR trực tiếp vào `main`.
- `dev` → `main` chỉ khi `dev` đã pass CI và được review (promotion).
- `main` không merge ngược vào `dev`. Lỗi trên `main` được sửa bằng nhánh mới từ `dev` rồi đi lại luồng.

Quy tắc bắt buộc:

- `<ten-ngan>` dùng **chữ thường**, số, `-`, `.`, `_`; bắt đầu bằng chữ/số.
- Không dùng `feature/`, `hotfix/`, khoảng trắng, chữ hoa, hay `feat_...`.
- Regex kiểm tra:

```text
^(main|dev|release/\d+\.\d+\.\d+|(feat|fix|refactor|perf|test|docs|chore|build|ci|revert)/[a-z0-9][a-z0-9._-]*|(dependabot|renovate)/.*)$
```

Ràng buộc tự động:

- **Local:** hook `.husky/pre-push` gọi `scripts/check-branch-name.sh` — chặn push nếu tên nhánh sai.
- **CI:** `.github/workflows/ci.yml` (job `branch_name`) kiểm tra tên nhánh nguồn **và luồng PR** (chặn PR sai đích).
- **Thủ công:** `npm run check:branch` hoặc `sh scripts/check-branch-name.sh <ten-nhanh>`.

### 3.2 Commit

Theo [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <mô tả ngắn>

<phần thân nếu cần>
```

| Type | Dùng khi |
|---|---|
| `feat` | Thêm tính năng |
| `fix` | Sửa lỗi |
| `refactor` | Đổi cấu trúc, không đổi hành vi |
| `test` | Thêm/sửa test |
| `docs` | Tài liệu |
| `chore` | Cấu hình, CI, package |
| `perf` | Tối ưu hiệu năng |
| `build` | Thay đổi build system |
| `ci` | Thay đổi cấu hình CI |
| `revert` | Revert commit trước |

Ví dụ:

```
feat(player): them double jump
fix(enemy): sua loi slime ket trong tuong
chore(unity): cap nhat package input system
```

### 3.3 Kiểm tra commit tự động

Repo dùng **husky + commitlint** để chặn commit sai format ngay trên máy:

| Thành phần | Vị trí |
|---|---|
| Hook | `.husky/commit-msg` |
| Cấu hình | `.commitlintrc.cjs` |
| CI | `.github/workflows/ci.yml` (job `commitlint`) |

- Cài lần đầu: `npm install` — script `prepare` tự cài hook husky.
- Hook `commit-msg` chạy `commitlint --edit` và chặn commit nếu message sai.
- Kiểm tra thủ công: `echo "feat(player): them double jump" | npx commitlint`
- Bỏ qua hook chỉ khi thật cần: `git commit --no-verify`
- CI `ci.yml` (job `commitlint`) kiểm tra lại toàn bộ commit trên PR và push vào `dev`/`main`, đồng thời kiểm tra **PR title** để giữ format thống nhất trong danh sách PR / release note.

### 3.4 Pull Request

**Mọi thay đổi vào `dev` và `main` phải qua Pull Request.** Không push trực tiếp; không merge nhánh ở local rồi push; **không dùng merge commit**.

Mô hình 2 tầng:

| Loại PR | Từ → đến | Khi nào |
|---|---|---|
| Feature PR | `<type>/*` → `dev` | Mọi tính năng, sửa lỗi, tài liệu, CI... |
| Promotion PR | `dev` → `main` | Khi `dev` đã ổn định, sẵn sàng phát hành |
| Release PR (tùy chọn) | `release/x.y.z` → `dev` | Sau khi ổn định nhánh release |

**Feature PR:**

1. Cập nhật `dev`, tạo nhánh: `git switch dev && git pull && git switch -c feat/<ten-ngan>`
2. Commit theo Conventional Commits, push nhánh lên `origin`
3. Rebase lên `dev` mới nhất trước khi mở/cập nhật PR (xem mục 3.5)
4. Mở PR vào `dev`, dùng template `.github/pull_request_template.md`
5. Chờ CI xanh và được review
6. **Rebase and merge** trên GitHub — giữ từng commit, lịch sử thẳng
7. Xóa nhánh sau khi merge

**Promotion PR (`dev` → `main`):**

1. `dev` phải xanh toàn bộ CI và đã được review
2. Mở PR `dev` → `main`, title dạng `chore(release): promote dev to main`
3. **Rebase and merge** — `dev` đang đi trước `main` nên `main` chỉ fast-forward, không tạo commit mới
4. Tag phiên bản trên `main` nếu phát hành

Lưu ý: `main` **không** merge ngược vào `dev`. Nếu phát hiện lỗi trên `main`, sửa bằng nhánh mới từ `dev` rồi đi lại luồng `feature → dev → main`.

Checklist trước khi mở PR:

- [ ] Tên nhánh đúng quy ước (mục 3.1), CI xanh
- [ ] PR nhắm đúng đích: `<type>/*` → `dev`, `dev` → `main`
- [ ] Commit message đúng Conventional Commits, CI `commitlint` xanh
- [ ] Đã rebase lên `dev` mới nhất, không có merge commit
- [ ] Project mở được, không lỗi compile trong Console
- [ ] Chạy Test Runner (EditMode, PlayMode nếu có)
- [ ] Không commit `Library/`, `Temp/`, `Logs/`, `UserSettings/`, `Builds/`
- [ ] Asset mới có `.meta` và đặt đúng folder/prefix
- [ ] Không có file debug, code chết
- [ ] Cập nhật `docs/` nếu thay đổi kiến trúc hoặc tech stack

Required checks trên PR:

| Check | Job trong `ci.yml` | Kiểm tra gì |
|---|---|---|
| Commit message | `commitlint` | Toàn bộ commit trong PR/push + **PR title** (format thống nhất) |
| Branch + luồng PR | `branch_name` | Tên nhánh nguồn và đích PR (`dev`/`main`) |
| Phát hiện thay đổi | `changes` | Phân diff thành 2 nhóm: `unity` (Assets/ProjectSettings/Packages) và `ci` (workflow, script, tooling) |
| Format text | `format_check` | `.editorconfig` cho mọi file text + parse JSON/asmdef/YAML; luôn chạy |
| Quy tắc project Unity | `unity_project` | `.meta` đủ cặp, asmdef hợp lệ và đúng hướng, `Game.Core` không dùng UnityEngine |
| Format C# | `csharp_format` | CSharpier trên `src/Recreate_The_World/Assets` |
| CI và script | `ci_checks` | `bash -n`, ShellCheck, `node --check`, parse YAML workflow |
| Unity compile/test | `unity_compile` | Compile + EditMode test qua GameCI |
| Gate | `ci_result` | Tổng hợp kết quả, dùng làm required check duy nhất |

Các job kiểm tra chỉ chạy khi:

- `commitlint` pass, và `branch_name` pass (hoặc skip khi push trực tiếp lên `dev`/`main`), và
- đúng loại thay đổi:
  - `format_check`: luôn chạy.
  - `unity_project`, `csharp_format`, `unity_compile`: diff có file trong `src/Recreate_The_World/{Assets,ProjectSettings,Packages}`.
  - `ci_checks`: diff có file trong `.github/workflows`, `scripts/`, `.husky/`, `.config/`, `package*.json` hoặc config format/lint.

Chỉ sửa tài liệu (`.md`, `.txt`, `docs/`, `README`) thì chỉ `format_check` chạy; `CI` vẫn xanh nếu format đạt. Nếu có thay đổi Unity thì 3 job Unity không được skip; nếu có thay đổi CI/script thì `ci_checks` không được skip.

Required check trên GitHub: chỉ cần bật **`CI`** (job `ci_result`).

Cấu hình GitHub (làm 1 lần bởi owner):

- **Settings ▸ General ▸ Default branch**: giữ `main` — đây là nhánh ổn định để clone/release. Khi mở PR, **đổi base sang `dev`** (GitHub mặc định chọn `main`). Nếu dùng bot, cấu hình `target-branch: dev`.
- **Settings ▸ General ▸ Pull Requests**: chỉ bật **Allow rebase merging**; tắt **Allow merge commits** và **Allow squash merging**.
- **Settings ▸ Rules ▸ Rulesets** → target cả `main` và `dev`:
  - *Require a pull request before merging*
  - *Require status checks to pass* — chọn `CI`
  - *Require linear history*
  - *Block force pushes*
- Không cấp quyền push trực tiếp `main`/`dev` cho thành viên.

Quy ước review: PR nhỏ (< ~400 dòng), mô tả rõ **làm gì** và **cách test**. Checklist chi tiết cho reviewer: [`docs/review.md`](review.md).

### 3.5 Rebase và đồng bộ nhánh

Dự án dùng **rebase**, không merge `dev` vào nhánh feature. Mục tiêu: lịch sử thẳng, không merge commit.

```bash
git fetch origin
git rebase origin/dev
```

Khi có conflict:

```bash
# sửa file conflict
git add <file>
git rebase --continue
```

Sau khi rebase, nhánh đã bị viết lại → phải force push:

```bash
git push --force-with-lease
```

Quy tắc:

- Chỉ dùng `--force-with-lease`; **không** dùng `--force`.
- Chỉ force push **nhánh cá nhân của mình**. Tuyệt đối không force push `main`, `dev`, `release/*`, hoặc nhánh người khác.
- Không `git merge dev` vào nhánh feature.
- Hủy rebase khi cần: `git rebase --abort`.
- Nhánh có nhiều người cùng làm → không rebase; mỗi người tạo nhánh riêng.
- `dev` luôn đi trước `main`; không cần đồng bộ `dev` từ `main`.

## 4. Web (`src/download-web`)

> Chưa triển khai. Quy ước dự kiến:

- TypeScript, không dùng `any` trừ khi có lý do.
- Format bằng Prettier, lint bằng ESLint.
- Component đặt theo feature; asset tĩnh trong `public/`.
- Test bằng Vitest (unit) và Playwright (E2E) khi cần.
- Không commit `node_modules/`, `dist/`, `.env`.

## 5. Tài liệu

- Tài liệu chung đặt trong `docs/`.
- README của Unity project: `src/Recreate_The_World/README.md`.
- Thay đổi lớn về kiến trúc phải cập nhật `docs/architecture.md` trong cùng PR.
- **AI agent** phải đọc `AGENTS.md` và `.ai/config.json` trước khi làm việc. `AGENTS.md` là nguồn luật duy nhất; `CLAUDE.md`, `.github/copilot-instructions.md`, `.cursor/rules/project.mdc` chỉ là con trỏ tới nó.
- Không dùng emoji/icon trang trí trong docs, comment, commit message hay tên file (xem `AGENTS.md` mục 8).
