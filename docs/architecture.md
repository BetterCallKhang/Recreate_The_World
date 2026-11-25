# Architecture

Tài liệu mô tả kiến trúc tổng thể: cấu trúc game, luồng dữ liệu, và kiến trúc web tải game (dự kiến).

## 1. Tổng quan hệ thống

```
┌──────────────────────────────┐
│         Unity Game           │
│  Input → Gameplay → UI       │
│  Game.Core (logic thuần)     │
└──────────────┬───────────────┘
               │ build
               ▼
┌──────────────────────────────┐
│        Build artifacts       │
│  Windows / Linux / WebGL     │
└──────────────┬───────────────┘
               │ upload / release
               ▼
┌──────────────────────────────┐
│   Web giới thiệu & tải game  │
│   (src/download-web)         │
└──────────────────────────────┘
```

## 2. Kiến trúc code Unity

### 2.1 Assembly Definition

```
Game.Core  ◄──  Game.Scripts  ◄──  Game.EditModeTests
                              ◄──  Game.PlayModeTests
```

| Assembly | Trách nhiệm | Được phép phụ thuộc |
|---|---|---|
| `Game.Core` | Công thức, state machine, inventory, dữ liệu thuần C# | Không gì (kể cả `UnityEngine`) |
| `Game.Scripts` | MonoBehaviour, controller, AI, spawner, UI binding | `Game.Core`, `Unity.InputSystem` |
| `Game.EditModeTests` | Unit test logic | `Game.Core`, `Game.Scripts`, TestRunner |
| `Game.PlayModeTests` | Integration test scene/runtime | `Game.Core`, `Game.Scripts`, TestRunner |

Nguyên tắc: **dependency một chiều**. `Game.Core` không được biết gì về Unity hay UI; mọi tương tác engine nằm ở `Game.Scripts`.

### 2.2 Phân lớp trong `Game.Scripts`

```
Input (Input System)
        │
        ▼
Gameplay/Player, Gameplay/Enemies   ← MonoBehaviour, điều phối
        │
        ▼
Game.Core                            ← tính toán, trạng thái thuần
        │
        ▼
UI/                                  ← hiển thị, lắng nghe sự kiện
```

- `Gameplay/*`: nhận input, gọi logic `Game.Core`, cập nhật transform/animation.
- `Game.Core`: không tham chiếu scene, không `GameObject`; nhận dữ liệu vào, trả kết quả ra → dễ unit test.
- `UI/*`: chỉ đọc trạng thái và hiển thị; không chứa luật gameplay.

### 2.3 Dữ liệu cấu hình

Dùng **ScriptableObject** cho dữ liệu tĩnh, không hard-code:

```
ScriptableObjects/
├── Characters/     # chỉ số player, skill
├── Enemies/        # chỉ số, hành vi theo loại
├── Items/          # vật phẩm, trang bị
├── Waves/          # cấu hình đợt kẻ địch
└── Config/         # hằng số cân bằng chung
```

## 3. Cấu trúc scene (kế hoạch)

| Scene | Vai trò |
|---|---|
| `Boot` | Khởi tạo service, load scene tiếp theo |
| `MainMenu` | Menu chính, setting |
| `Gameplay` | Scene chơi chính |
| `Environment` | Additive: tilemap, background |
| `UI` | Additive: HUD, pause |
| `Test` | Scene thử nghiệm, không đưa vào build |
| `SampleScene` | Scene mẫu kiểm tra pipeline |

Chiến lược: **additive scene** cho `Environment` và `UI` để tách dữ liệu nặng khỏi logic gameplay.

## 4. Luồng dữ liệu runtime (dự kiến)

```
InputSystem_Actions.inputactions
        │  (event)
        ▼
PlayerController (Game.Scripts/Gameplay/Player)
        │  (gọi hàm thuần)
        ▼
PlayerState / DamageCalculator (Game.Core)
        │  (kết quả)
        ├──► Animator / SpriteRenderer
        ├──► AudioSource (SFX)
        └──► HUD (UI)
```

Nguyên tắc:

- Input chỉ đọc ở tầng `Gameplay`, không đọc trong `Game.Core`.
- `Game.Core` trả về dữ liệu/kết quả, không tự gọi `Debug.Log`, `Instantiate`, `FindObjectOfType`.
- UI không gọi trực tiếp logic gameplay; đi qua event hoặc interface.

## 5. Web tải game (dự kiến)

```
src/download-web/
├── public/          # favicon, banner, file build
├── src/             # trang giới thiệu, changelog, hướng dẫn cài
├── tests/
├── Dockerfile       # multi-stage: build → serve static
└── package.json
```

Luồng deploy dự kiến:

```
PR vào dev → promotion dev → main
        │
        ▼
web-ci (lint + test + build)
        │
        ▼
web-cd (docker build → push image → deploy)
```

Build game được upload như release artifact và link tải hiển thị trên web.

## 6. Các quyết định kiến trúc (ADR ngắn)

| Quyết định | Lý do |
|---|---|
| Tách `Game.Core` khỏi Unity | Unit test nhanh, không cần scene |
| Asset tổ chức `loại → module` | Tìm theo loại nhanh, vẫn gọn theo module |
| `Assets/Settings` tách khỏi `_Project` | File URP do template sinh, không trộn với asset tác giả |
| Git LFS cho binary | Tránh phình repo, tránh conflict file nhị phân |
| `.meta` luôn commit | Giữ GUID, tránh mất tham chiếu |
