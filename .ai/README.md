# .ai/

Cấu hình cho AI agent làm việc trong repo.

## Files

| File | Commit? | Mục đích |
|---|---|---|
| `config.json` | Có | Cấu hình chung của dự án |
| `config.local.json` | Không (gitignore) | Override riêng cho máy cá nhân |

## config.json

```json
{
  "autoCommit": false,
  "writeTests": true,
  "language": "vi",
  "commitConvention": "conventional-commits"
}
```

| Key | Giá trị | Ý nghĩa |
|---|---|---|
| `autoCommit` | `false` / `true` | `false`: agent không được commit, người dùng tự commit. `true`: agent được tự commit sau khi pass kiểm tra (xem `AGENTS.md` mục 5.1) |
| `writeTests` | `true` / `false` | `true`: logic mới/đổi hành vi phải kèm test. `false`: không bắt buộc viết test mới, nhưng vẫn phải chạy test hiện có (xem `AGENTS.md` mục 5.2) |
| `language` | `vi` | Ngôn ngữ trao đổi |
| `commitConvention` | `conventional-commits` | Chuẩn commit message |

## Đổi hành vi

Sửa `config.json` (áp dụng cho cả nhóm) hoặc tạo `config.local.json` (chỉ máy bạn):

```json
{ "autoCommit": true, "writeTests": false }
```

`config.local.json` được áp đè lên `config.json`; nếu không có thì dùng `config.json`; nếu cả hai đều thiếu key thì mặc định `autoCommit = false`, `writeTests = true`.

## Skills cá nhân (không commit)

Nếu muốn thêm skill riêng cho agent, đặt trong thư mục **được agent nhận diện**, không phải thư mục tự đặt tên:

| Agent | Đường dẫn |
|---|---|
| OpenCode | `.opencode/skills/<skill-id>/SKILL.md` |
| Claude Code | `.claude/skills/<skill-id>/SKILL.md` |
| Dùng chung (OpenCode + Claude) | `.agents/skills/<skill-id>/SKILL.md` |

Git **không commit được thư mục rỗng**. Cách đúng để vừa có thư mục vừa ignore nội dung cá nhân:

```gitignore
.opencode/skills/*
!.opencode/skills/README.md
```

Sau đó commit một `.opencode/skills/README.md` ngắn mô tả quy ước. Người khác clone về vẫn thấy thư mục, nhưng skill cá nhân của bạn không bị commit.

> Không dùng `.skill/` hay tên tự đặt: OpenCode và Claude Code không quét thư mục đó, và file/thư mục bắt đầu bằng `.` bị bỏ qua khi discovery.

## Lưu ý

- `autoCommit = true` **không** cho phép push hay tạo PR — việc đó luôn cần người dùng xác nhận.
- `writeTests = false` **không** cho phép làm hỏng test đang pass.
- Dù flag là gì, agent vẫn phải tuân thủ `AGENTS.md` và `docs/coding-conventions.md`.
- Khi bật `autoCommit = true`, kiểm tra lại `git status` trước khi commit để chắc chắn không có file ngoài phạm vi.
