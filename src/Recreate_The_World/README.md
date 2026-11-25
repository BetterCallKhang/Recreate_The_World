# Recreate The World — Unity Project

Project Unity của đồ án tốt nghiệp **Recreate The World** (game 2D, URP 2D).

> Trạng thái: mới khởi tạo cấu trúc. `Assets/_Project/Scenes/SampleScene.unity` là scene mẫu dùng để kiểm tra pipeline, chưa có gameplay.

---

## Phiên bản

| Thành phần | Phiên bản |
|---|---|
| Unity Editor | `6000.3.29f1` (Unity 6.3) — xem `ProjectSettings/ProjectVersion.txt` |
| Render Pipeline | Universal RP `17.3.0`, Renderer2D |
| Input System | `1.20.1` |
| UI | uGUI `2.0.0` |
| 2D | 2D Animation `13.0.6`, Aseprite Importer `3.0.2`, PSD Importer `12.0.2`, Tilemap Extras `6.0.3` |
| Test | Test Framework `1.6.0` |

Danh sách package đầy đủ: `Packages/manifest.json` và `Packages/packages-lock.json`.

---

## Mở project

1. Cài **Unity Hub** và editor **`6000.3.29f1`**
2. Unity Hub → `Add project from disk`
3. Chọn thư mục chứa file này (`src/Recreate_The_World`)
4. Mở project, chờ Unity import package lần đầu
5. Mở `Assets/_Project/Scenes/SampleScene.unity` → **Play**

> Không tự nâng version Unity. Nếu mở bằng version khác, Unity sẽ upgrade `ProjectSettings` và làm lệch cấu hình so với nhóm.

---

## Cấu trúc `Assets`

```
Assets/
├── _Project/                     # asset & code của đồ án
│   ├── Art/
│   │   ├── Characters/{Player, Enemies}
│   │   ├── Environment/{Tilesets, Props, Backgrounds}
│   │   ├── UI/
│   │   └── VFX/
│   ├── Animations/{Player, Enemies, Environment, UI}
│   ├── Audio/
│   │   ├── Music/, Ambience/
│   │   └── SFX/{Player, Enemies, UI, Environment}
│   ├── Materials/{Characters, Environment, VFX}
│   ├── Prefabs/{Player, Enemies, Environment, UI, Systems}
│   ├── Scenes/                   # SampleScene + Gameplay/, Test/
│   ├── ScriptableObjects/{Characters, Enemies, Items, Waves, Config}
│   └── Scripts/
│       ├── Core/                 # C# thuần, không dùng UnityEngine
│       ├── Gameplay/{Player, Enemies, Environment, Systems}
│       └── UI/
├── Settings/                     # cấu hình URP 2D (template-generated)
├── Tests/
│   ├── EditMode/
│   └── PlayMode/
├── ThirdParty/                   # plugin / asset bên ngoài
└── Resources/                    # chỉ asset load động bắt buộc
```

Quy ước: **loại asset ở cấp 1 → module ở cấp 2**. Không lồng quá 3–4 tầng, không tạo folder cho một file lẻ. Thư mục rỗng có `.gitkeep`.

---

## Assembly Definition

```
Game.Core  ◄──  Game.Scripts  ◄──  Game.EditModeTests
                              ◄──  Game.PlayModeTests
```

| Assembly | Vị trí | Vai trò | Phụ thuộc |
|---|---|---|---|
| `Game.Core` | `Scripts/Core/Game.Core.asmdef` | logic thuần C# | không có (kể cả `UnityEngine`) |
| `Game.Scripts` | `Scripts/Game.Scripts.asmdef` | MonoBehaviour, controller, AI, UI | `Game.Core`, `Unity.InputSystem` |
| `Game.EditModeTests` | `Tests/EditMode/` | unit test | `Game.Core`, `Game.Scripts`, TestRunner |
| `Game.PlayModeTests` | `Tests/PlayMode/` | integration test | `Game.Core`, `Game.Scripts`, TestRunner |

Quy tắc:

- `Game.Core` **không** dùng `UnityEngine` (`Vector2`, `Debug`, `Random`...). Nếu thực sự cần, đổi `noEngineReferences` thành `false` trong `Game.Core.asmdef` — nhưng nên giữ thuần để test nhanh.
- `Game.Core` không tham chiếu ngược `Game.Scripts`.
- Script mới đặt đúng module: `Scripts/Gameplay/Player`, `Scripts/Gameplay/Enemies`...

---

## Cấu hình project

| File / thư mục | Nội dung |
|---|---|
| `Assets/Settings/` | URP asset, Renderer2D, Volume Profile, Input Actions mặc định |
| `ProjectSettings/TagManager.asset` | Tags & Layers (thêm layer mới tại đây, commit thay đổi) |
| `ProjectSettings/Physics2DSettings.asset` | Layer collision matrix |
| `ProjectSettings/EditorBuildSettings.asset` | Danh sách scene trong build |
| `ProjectSettings/InputManager.asset` | Legacy Input (ưu tiên dùng Input System) |

Input dùng **Input System** (`Assets/Settings/InputSystem_Actions.inputactions`). Khi thêm action mới, sửa file này và commit.

---

## Thêm package

Sửa qua **Window ▸ Package Manager** hoặc `Packages/manifest.json`, sau đó **commit cả `manifest.json` và `packages-lock.json`** để cả nhóm dùng đúng version.

Package ngoài (Git URL) khai báo trong `manifest.json`; plugin/asset mua hoặc tải tay đặt trong `Assets/ThirdParty/<TenNhaCungCap>/`.

---

## Kiểm thử

**Window ▸ General ▸ Test Runner**

- `Tests/EditMode`: test logic `Game.Core`, chạy nhanh trong Editor
- `Tests/PlayMode`: test va chạm, scene, luồng gameplay

Hiện chưa có test case — chỉ mới có asmdef.

---

## Build

**File ▸ Build Profiles** (Unity 6) hoặc **File ▸ Build Settings**.

- Scene build lấy từ `ProjectSettings/EditorBuildSettings.asset`
- Build ra ngoài project (`Builds/`) và không commit
- `*.apk`, `*.aab`, `*.exe` được `.gitignore` bỏ qua

---

## Quy ước asset

| Loại | Prefix | Ví dụ |
|---|---|---|
| Sprite nhân vật | `CHR_` | `CHR_Player_Idle_01` |
| Sprite kẻ địch | `ENM_` | `ENM_Slime_Walk` |
| Môi trường | `ENV_` | `ENV_Forest_Tree_01` |
| UI | `UI_` | `UI_HUD_HealthBar` |
| Material | `MAT_` | `MAT_Player_Outline` |
| SFX | `SFX_` | `SFX_Player_Jump` |
| Nhạc nền | `BGM_` | `BGM_MainTheme` |

Bắt buộc:

- **Luôn commit file `.meta`** đi cùng asset. `Library/`, `Temp/`, `Logs/`, `UserSettings/`, `Builds/` không commit.
- **Không xóa `.meta`** để Unity tạo lại — GUID đổi sẽ làm mất toàn bộ tham chiếu trong scene/prefab.
- File binary (png, psd, aseprite, wav, ttf, fbx...) đi qua **Git LFS** theo `.gitattributes` ở root repo. Cài `git lfs install` trước khi clone.
- Code style theo `.editorconfig` ở root repo: UTF-8, LF, 4 space, `_camelCase` private field, `IPascalCase` interface.
