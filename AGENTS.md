# AGENTS.md

Hướng dẫn bắt buộc cho mọi AI agent làm việc trong repo này (OpenCode, Codex, Claude Code, Copilot, Cursor...).

> **Đọc file này trước khi làm bất cứ thay đổi nào.** Nếu có mâu thuẫn, yêu cầu trực tiếp của người dùng được ưu tiên, nhưng các ràng buộc kỹ thuật bên dưới vẫn phải tuân thủ.

---

## 1. Bắt buộc đọc trước khi làm

Theo thứ tự:

1. `.ai/config.json` — cấu hình hành vi agent (đặc biệt `autoCommit`, `writeTests`)
2. `docs/tech-stack.md` — phiên bản Unity/package, công cụ
3. `docs/architecture.md` — kiến trúc asmdef, luồng dữ liệu, cấu trúc scene
4. `docs/coding-conventions.md` — quy ước code, asset, Git, PR
5. `src/Recreate_The_World/README.md` — cách mở/chạy Unity project
6. Code/asset liên quan trực tiếp đến task, trước khi sửa

Không được tự suy đoán kiến trúc khi đã có tài liệu. Nếu tài liệu thiếu hoặc mâu thuẫn với code, **báo lại** thay vì tự chọn.

## 2. Bất biến của dự án (không được vi phạm)

- **Không xóa/tạo lại file `.meta`.** `.meta` giữ GUID; mất GUID là mất tham chiếu scene/prefab.
- **Không commit** `Library/`, `Temp/`, `Obj/`, `Logs/`, `UserSettings/`, `Builds/`, `*.csproj`, `*.sln`, `*.slnx`, file build.
- **`Game.Core` không được dùng `UnityEngine`** (kể cả `Vector2`, `Debug`, `Random`). Dùng C# thuần hoặc `System.*`.
- **Dependency một chiều:** `Game.Core` → `Game.Scripts` → test assemblies. Không tham chiếu ngược.
- **Asset đặt đúng cấu trúc** `Assets/_Project/<Loại>/<Module>/`; file binary đi qua Git LFS.
- **Không sửa** `Assets/Settings/` (URP template) trừ khi task yêu cầu rõ.
- **Không commit secret**: `.env`, khóa, token, đường dẫn tuyệt đối của máy cá nhân.
- **Format C# bằng CSharpier** (`.csharpierrc.json`); không tự đổi style hoặc reformat file ngoài phạm vi task.
- **Không push trực tiếp `main` hoặc `dev`.** Mọi thay đổi đi qua nhánh + PR; `main` chỉ nhận PR từ `dev`.

## 3. Quy trình làm việc

1. **Đọc** mục 1 và code liên quan.
2. **Lập kế hoạch ngắn** cho task; nếu yêu cầu mơ hồ hoặc ảnh hưởng nhiều module, hỏi lại trước khi sửa.
3. **Sửa tối thiểu**, đúng phạm vi task. Không refactor lan man, không đổi định dạng file ngoài phạm vi.
4. **Kiểm tra** theo mục 6.
5. **Báo cáo**: đã làm gì, file nào thay đổi, cách test, phần nào chưa làm được và vì sao.

Quy tắc an toàn:

- Không xóa file untracked của người dùng nếu chưa xác nhận đó là file rác.
- Không `git reset --hard`, `git clean`, rewrite history trừ khi được yêu cầu rõ.
- Không sửa file ngoài repo hoặc chạy lệnh phá hủy dữ liệu.
- **Ngoại lệ duy nhất cho force push:** được `git push --force-with-lease` **nhánh cá nhân của chính mình** sau khi rebase. Không bao giờ force push `main`, `release/*` hay nhánh người khác, không dùng `--force`.

## 4. Git: nhánh và commit

**Nhánh** phải khớp:

```text
^(main|dev|release/\d+\.\d+\.\d+|(feat|fix|refactor|perf|test|docs|chore|build|ci|revert)/[a-z0-9][a-z0-9._-]*|(dependabot|renovate)/.*)$
```

Kiểm tra: `npm run check:branch`

**Luồng nhánh:**

- `<type>/*` → PR vào `dev`
- `dev` → PR vào `main` (promotion)
- `release/x.y.z` (tùy chọn) → PR vào `dev`
- Không PR trực tiếp từ nhánh cá nhân vào `main`; không PR ngược `main` → `dev`.

**Commit** theo Conventional Commits, type lowercase:

```text
<type>(<scope>): <mô tả ngắn>
```

- Type hợp lệ: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`, `build`, `ci`, `revert`.
- Scope tùy chọn, lowercase (`player`, `enemy`, `ui`, `assets`, `docs`, `ci`...).
- Header ≤ 100 ký tự.
- Kiểm tra: `npm run commitlint -- --last` hoặc `echo "feat(x): mo ta" | npx commitlint`

**Rebase, không merge:**

- Dự án dùng **rebase** để đồng bộ nhánh và **"Rebase and merge"** trên GitHub. Không tạo merge commit, không squash.
- Đồng bộ: `git fetch origin && git rebase origin/dev`.
- Không `git merge dev` vào nhánh feature.
- Sau rebase: `git push --force-with-lease` (chỉ nhánh cá nhân).
- Conflict: sửa file → `git add <file>` → `git rebase --continue`; bỏ cuộc: `git rebase --abort`.

## 5. Biến điều khiển hành vi agent

Đọc `.ai/config.json`:

```json
{ "autoCommit": false, "writeTests": true }
```

### 5.1 `autoCommit`

| `autoCommit` | Hành vi của agent |
|---|---|
| `false` (mặc định) | **Không** chạy `git add` / `git commit` / `git push` / tạo PR. Chỉ sửa file và liệt kê thay đổi để người dùng tự commit. |
| `true` | Được phép **tự commit** sau khi hoàn thành task và pass kiểm tra ở mục 6. Vẫn **không tự push** hoặc tạo PR trừ khi được yêu cầu rõ. |

Quy tắc bổ sung:

- File `.ai/config.local.json` (nếu có) override `.ai/config.json` cho máy cá nhân; file này bị gitignore.
- Nếu không đọc được config hoặc thiếu key → mặc định coi là `false`.
- Khi `autoCommit = true`, mỗi commit phải:
  - Chỉ chứa thay đổi thuộc task hiện tại
  - Không chứa file rác, secret, `Library/`, build
  - Message đúng Conventional Commits và pass `npx commitlint`
  - Không commit lên `main`/`dev` nếu đang ở nhánh sai
- Người dùng yêu cầu trực tiếp ("commit giúp tôi") luôn được ưu tiên, kể cả khi flag là `false`, nhưng agent phải nêu rõ sẽ commit những gì.
- **Push/PR luôn cần người dùng xác nhận**, bất kể flag.

### 5.2 `writeTests`

| `writeTests` | Hành vi của agent |
|---|---|
| `true` (mặc định) | Logic mới hoặc thay đổi hành vi **phải kèm test**: unit test cho `Game.Core` (`Game.EditModeTests`), integration test cho scene/runtime khi cần (`Game.PlayModeTests`). Nếu chưa có test assembly, tạo đúng chỗ theo `docs/architecture.md`. |
| `false` | Không bắt buộc viết test mới. Vẫn phải **chạy test hiện có** và không được làm hỏng test đang pass. |

Quy tắc áp dụng cho cả hai giá trị:

- Không được nói "đã test" khi chưa chạy. Nếu môi trường không có Unity Editor, nêu rõ và đưa lệnh để người dùng tự chạy.
- Test phải kiểm tra **hành vi**, không phải implementation detail; không viết test chỉ để tăng số lượng.
- Không sửa/xóa test đang pass để che lỗi, trừ khi test đó sai so với yêu cầu — khi đó phải giải thích trong báo cáo.
- Thiếu key `writeTests` → mặc định `true`.
- Người dùng yêu cầu rõ ("không cần test lần này") được ưu tiên cho task hiện tại.

## 6. Kiểm tra trước khi báo hoàn thành

Tùy phạm vi thay đổi:

| Thay đổi | Bắt buộc kiểm tra |
|---|---|
| Code C# | `npm run check:csharp` + `npm run check:unity`; compile trong Unity Console không lỗi. `writeTests = true`: test mới pass. Luôn chạy lại test hiện có |
| ScriptableObject / prefab / scene | Mở scene chạy thử; không có `Missing` reference |
| Asset mới | Có `.meta`; đúng folder/prefix; file lớn nằm trong LFS |
| Workflow / script | `ruby -ryaml -e 'YAML.load_file(...)'` hoặc kiểm tra cú pháp; chạy thử script local |
| Tài liệu | Link đúng, nội dung khớp code hiện tại |
| Git | `git status` sạch ngoài phạm vi; không có file bị ignore lọt vào |

Nếu không thể chạy (ví dụ không có Unity Editor trong môi trường), **nói rõ chưa kiểm tra được** và đưa lệnh để người dùng tự chạy. Không được nói "đã test" khi chưa test.

## 7. Tài liệu

- Thay đổi kiến trúc, tech stack, quy ước → cập nhật `docs/` **trong cùng thay đổi**.
- README Unity project: `src/Recreate_The_World/README.md`.
- Không tạo tài liệu trùng lặp; sửa file đã có thay vì thêm file mới.
- **Skill cá nhân** đặt trong `.opencode/skills/`, `.claude/skills/` hoặc `.agents/skills/` và **không commit** (xem `.ai/README.md`). Skill chung của dự án phải nằm trong thư mục được commit và được review như code.

## 8. Giao tiếp

- Trả lời bằng **tiếng Việt**, ngắn gọn, rõ ràng.
- Nêu file đã sửa, lệnh đã chạy, kết quả kiểm tra.
- Nêu rõ phần chưa làm / chưa kiểm chứng được.
- Không tự commit khi `autoCommit = false`.
- Không giả vờ đã chạy lệnh hoặc đã đọc file nếu chưa.

**Không lạm dụng icon/emoji:**

- Không dùng emoji trong câu trả lời, tài liệu, comment code, commit message, tên file/thư mục, heading — trừ khi người dùng yêu cầu rõ.
- Không trang trí bằng icon để thay cho nội dung; dùng chữ hoặc bảng.
- Ngoại lệ: `✅`/`❌` trong GitHub Actions step summary/annotation để đánh dấu pass/fail. Không dùng trong tài liệu dự án hay giao tiếp thường ngày.
- Không dùng icon trong code C# (kể cả comment) vì có thể lỗi encoding trên một số công cụ.

## 9. Definition of Done

- [ ] Đúng phạm vi yêu cầu, không sửa lan man
- [ ] Tuân thủ kiến trúc asmdef và quy ước đặt tên
- [ ] `.meta` đầy đủ, không commit file bị ignore
- [ ] Test: `writeTests = true` → có test cho logic mới/đổi hành vi; test hiện có vẫn pass
- [ ] Tài liệu liên quan đã cập nhật
- [ ] Báo cáo đầy đủ: thay đổi, file, cách test
- [ ] Commit chỉ khi `autoCommit = true` hoặc người dùng yêu cầu trực tiếp
