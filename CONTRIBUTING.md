# Contributing

Quy trình đóng góp cho repo `Recreate_The_World`.

Tóm tắt; chi tiết trong [`docs/coding-conventions.md`](docs/coding-conventions.md).

## Quy trình đóng góp

1. Cập nhật `dev`, tạo nhánh đúng quy ước:

   ```bash
   git switch dev && git pull
   git switch -c feat/<ten-ngan>
   ```

2. Commit theo **Conventional Commits**:

   ```text
   <type>(<scope>): <mô tả ngắn>
   ```

   Type hợp lệ: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`, `build`, `ci`, `revert`.

3. Rebase lên `dev` mới nhất trước khi mở PR:

   ```bash
   git fetch origin
   git rebase origin/dev
   git push --force-with-lease
   ```

   Không merge `dev` vào nhánh feature, không tạo merge commit.

4. Push nhánh, mở **Pull Request** vào `dev`

5. Chờ CI xanh (`.github/workflows/ci.yml`) và review

6. **Rebase and merge** vào `dev`, xóa nhánh sau khi merge

7. Khi `dev` ổn định: mở **promotion PR** `dev` → `main`, title `chore(release): promote dev to main`, rebase-merge để `main` fast-forward

```text
feat/*  fix/*  docs/* ... ──PR──► dev ──PR──► main
```

Quy tắc cứng:

- **Không push trực tiếp `main` hoặc `dev`** — mọi thay đổi qua PR
- **Nhánh cá nhân chỉ PR vào `dev`**; chỉ `dev` được PR vào `main`
- **Không dùng merge commit hay squash merge** — chỉ rebase
- Force push chỉ với `--force-with-lease`, chỉ trên nhánh cá nhân
- Tên nhánh: `main`, `dev`, `release/x.y.z`, hoặc `<type>/<ten-ngan>` (chữ thường, `-`/`.`/`_`)
- **Luôn commit `.meta`** đi cùng asset; không xóa/tạo lại `.meta`
- Không commit `Library/`, `Temp/`, `Logs/`, `UserSettings/`, `Builds/`, `*.csproj`, `*.sln`

## Kiểm tra biên dịch để pass CI

Trước khi mở PR và trước khi merge, cần đảm bảo các job kiểm tra biên dịch/test pass để job `CI` xanh:

1. **Biên dịch Unity**: không lỗi compile trong Unity Editor (Console sạch). CI job `unity_compile` (GameCI) chạy tự động khi có thay đổi Unity + commit/branch pass.
2. **Local**: chạy các check hỗ trợ:

   ```bash
   npm run check:csharp      # format C# (CSharpier)
   npm run check:unity       # .meta, asmdef, Game.Core purity
   npm run check:format      # format text + JSON/YAML
   ```

3. **Test**: chạy Test Runner (EditMode) — CI chạy qua GameCI.
4. **Checklist review**: xem [`docs/review.md`](docs/review.md); review phải yêu cầu compile/test pass trước khi approve.

Nếu PR có thay đổi trong `src/Recreate_The_World/{Assets,ProjectSettings,Packages}`, CI sẽ chạy: `format_check`, `unity_project`, `csharp_format`, `unity_compile`. PR chỉ được merge khi job **`CI`** (gate `ci_result`) pass.

## Ghi chú

- Merge strategy: **rebase and merge** (giữ lịch sử, không merge commit/squash).
- Chi tiết quy tắc: [`docs/coding-conventions.md`](docs/coding-conventions.md).
