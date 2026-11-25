# Coding Conventions

Quy ước chung cho toàn repo. Mục tiêu: code nhất quán, review nhanh, diff sạch.

## 1. C# (Unity)

### 1.1 Format

Áp dụng tự động bởi `.editorconfig` ở root:

- UTF-8, xuống dòng **LF**
- Indent **4 space**, không dùng tab
- Có dòng trống cuối file
- Không để trailing whitespace (trừ `.meta`)

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
| `main` | Nhánh ổn định, luôn mở được project. **Cấm push trực tiếp** |
| `release/<x.y.z>` | Nhánh phát hành, ví dụ `release/1.0.0` |
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

Quy tắc bắt buộc:

- `<ten-ngan>` dùng **chữ thường**, số, `-`, `.`, `_`; bắt đầu bằng chữ/số.
- Không dùng `feature/`, `hotfix/`, khoảng trắng, chữ hoa, hay `feat_...`.
- Regex kiểm tra:

```text
^(main|release/\d+\.\d+\.\d+|(feat|fix|refactor|perf|test|docs|chore|build|ci|revert)/[a-z0-9][a-z0-9._-]*|(dependabot|renovate)/.*)$
```

Ràng buộc tự động:

- **Local:** hook `.husky/pre-push` gọi `scripts/check-branch-name.sh` — chặn push nếu tên nhánh sai.
- **CI:** `.github/workflows/branch-name.yml` kiểm tra tên nhánh nguồn của mọi PR.
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
| CI | `.github/workflows/commitlint.yml` |

- Cài lần đầu: `npm install` — script `prepare` tự cài hook husky.
- Hook `commit-msg` chạy `commitlint --edit` và chặn commit nếu message sai.
- Kiểm tra thủ công: `echo "feat(player): them double jump" | npx commitlint`
- Bỏ qua hook chỉ khi thật cần: `git commit --no-verify`
- CI `commitlint.yml` kiểm tra lại toàn bộ commit trên PR và push vào `main`, đồng thời kiểm tra **PR title** vì squash merge lấy title làm commit message.

### 3.4 Pull Request

**Mọi thay đổi vào `main` phải qua Pull Request.** Không push trực tiếp, không merge local rồi push.

Luồng làm việc:

1. Cập nhật `main`, tạo nhánh: `git switch main && git pull && git switch -c feat/<ten-ngan>`
2. Commit theo Conventional Commits, push nhánh lên `origin`
3. Mở PR vào `main`, dùng template `.github/pull_request_template.md`
4. Chờ CI xanh và được review
5. Squash merge, xóa nhánh sau khi merge

Checklist trước khi mở PR:

- [ ] Tên nhánh đúng quy ước (mục 3.1), CI `branch-name` xanh
- [ ] Commit message đúng Conventional Commits, CI `commitlint` xanh
- [ ] Project mở được, không lỗi compile trong Console
- [ ] Chạy Test Runner (EditMode, PlayMode nếu có)
- [ ] Không commit `Library/`, `Temp/`, `Logs/`, `UserSettings/`, `Builds/`
- [ ] Asset mới có `.meta` và đặt đúng folder/prefix
- [ ] Không có file debug, code chết
- [ ] Cập nhật `docs/` nếu thay đổi kiến trúc hoặc tech stack

Required checks trên PR:

| Check | Workflow | Kiểm tra gì |
|---|---|---|
| Commit message | `commitlint.yml` | Toàn bộ commit trong PR/push + **PR title** (dùng cho squash merge) |
| Branch name | `branch-name.yml` | Tên nhánh nguồn của PR |
| Unity compile/test | `unity-check.yml` (khi có) | Compile + EditMode test |

Bật bảo vệ nhánh trên GitHub (làm 1 lần bởi owner):

- **Settings ▸ Rules ▸ Rulesets** (hoặc **Branches**) → target `main`
- Bật: *Require a pull request before merging*, *Require status checks to pass*, *Block force pushes*
- Không cấp quyền push trực tiếp `main` cho thành viên

Quy ước review: PR nhỏ (< ~400 dòng), mô tả rõ **làm gì** và **cách test**.

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
