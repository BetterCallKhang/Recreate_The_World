# Hướng dẫn Review Code

Tài liệu này là **nguồn duy nhất** hướng dẫn review code cho cả team (AI agent và developer). Mục tiêu: review nhanh, nhất quán, không lan man.

## Kiểm tra bắt buộc trước merge

- [ ] Job `CI` toàn bộ pass: commitlint, branch, format, compile + test.
- [ ] Khi có thay đổi Unity: job `unity_compile` pass (biên dịch + EditMode test) — xem [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Quy trình review

1. **Author tự review** trước khi mở PR: chạy checklist bên dưới, sửa trước khi mở PR.
2. **Reviewer review** PR bằng checklist cùng; comment rõ ràng, yêu cầu thay đổi đúng phạm vi task.
3. **Không approve** khi còn lỗi lint/format/CI/test fail hoặc TODO/code debug.
4. Sau approve: **rebase** lên `dev` mới nhất rồi **rebase and merge** (giữ lịch sử, không merge commit).

## Checklist review

### Kiến trúc & SOLID

- [ ] **S** — Mỗi class/method có **một** lý do đóng góp rõ ràng.
- [ ] **O** — Mở rộng bằng interface/abstract; không sửa code cũ đang dùng.
- [ ] **L** — Thay thế subclass không làm thay đổi hành vi caller.
- [ ] **I** — Client chỉ depend vào interface mà nó cần (Interface Segregation).
- [ ] **D** — Dependency qua interface/inject; không hard-code phụ thuộc cụ thể.

### Thiết kế & quy tắc basic

- [ ] **YAGNI** — Không thêm tính năng/API/chức năng chưa dùng.
- [ ] **KISS** — Giải pháp đơn giản nhất cho bước hiện tại.
- [ ] **Không magic number / magic string** — đưa vào hằng số (`PascalCase`) hoặc ScriptableObject.
- [ ] **Không magic variable** — tên biến/cột/cờ/callback phải nói rõ ý nghĩa.
- [ ] **Không hardcode** cấu hình gameplay — đưa vào ScriptableObject.

### Kiểm thử & chất lượng code

- [ ] Không còn code debug (`Debug.Log`, test tạm, `TODO`).
- [ ] Comment giải thích **vì sao**, không giải thích **cái gì**.
- [ ] Method dài trên ~50 dòng → tách nhỏ.
- [ ] Không thêm dependency ngược (`Game.Core` không ref `Game.Scripts`, prod không ref test).

### Kiểm tra môi trường game

- [ ] `Game.Core` **không** dùng `UnityEngine`/`UnityEditor` (chỉ C# thuần hoặc `System.*`).
- [ ] Asset mới có `.meta` đúng cặp; đặt đúng `Assets/_Project/<Loại>/<Module>/`.

## Quy tắc phát sinh khi review

- Review chỉ yêu cầu sửa **đúng phạm vi task** — không refactor lan man.
- Nếu reviewer thấy lỗi kiến trúc lớn, comment trong PR và tách task riêng.

## Liên quan

- Quy tắc code nền tảng: [`docs/coding-conventions.md`](coding-conventions.md)
- CI chạy các check hỗ trợ review: [`docs/tech-stack.md`](tech-stack.md)
