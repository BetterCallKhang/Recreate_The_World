# Performance Baseline Report

Báo cáo đo hiệu năng theo từng mốc (baseline → tối ưu). Dùng để so sánh FPS, frame time, GC Alloc, RAM trước và sau khi tối ưu.

File này là template; điền số liệu sau build đầu tiên.

## 1. Môi trường đo

Ghi lại chính xác để kết quả có thể so sánh:

| Thông tin | Giá trị |
|---|---|
| Ngày đo | TBD |
| Unity version | `6000.3.29f1` |
| Build target | TBD (Windows / Linux / WebGL) |
| Build configuration | Development / Release |
| CPU | TBD |
| GPU | TBD |
| RAM | TBD |
| OS | TBD |
| Độ phân giải | TBD |
| Quality level | TBD |

## 2. Cách đo

| Chỉ số | Công cụ | Cách lấy |
|---|---|---|
| FPS trung bình | Unity Profiler | `Profiler ▸ CPU`, trung bình 60s gameplay |
| FPS 1% low | Unity Profiler | Frame time percentile thấp nhất |
| Frame time (ms) | Unity Profiler | `CPU Usage` trung bình |
| GC Alloc / frame | Unity Profiler | `GC Alloc` trong `CPU Usage` |
| RAM | Memory Profiler | `Memory Profiler` snapshot |
| Draw calls / Batches | Frame Debugger / Rendering Profiler | `Rendering` module |
| Build size | Build report | Kích thước thư mục build |

Quy trình:

1. Build **Release** (không Development) cho số liệu cuối.
2. Chạy cùng một scene, cùng một đoạn gameplay (ghi lại thời lượng, ví dụ 60 giây).
3. Đo 3 lần, lấy trung vị.
4. Lưu ảnh capture vào `docs/performance-benchmarks/captures/`.

## 3. Kết quả baseline

> Điền sau build đầu tiên.

| Chỉ số | Baseline | Mục tiêu | Ghi chú |
|---|---|---|---|
| FPS trung bình | TBD | ≥ 60 | |
| FPS 1% low | TBD | ≥ 45 | |
| Frame time (ms) | TBD | ≤ 16.6 | |
| GC Alloc / frame | TBD | 0 B trong gameplay | |
| RAM (peak) | TBD | TBD | |
| Draw calls | TBD | TBD | |
| Build size | TBD | TBD | |

## 4. Lịch sử so sánh

Mỗi lần tối ưu, thêm một mốc mới và giữ nguyên mốc cũ để so sánh.

| Mốc | Ngày | Thay đổi chính | FPS avg | Frame time | GC Alloc | RAM | Build size |
|---|---|---|---|---|---|---|---|
| Baseline | TBD | — | TBD | TBD | TBD | TBD | TBD |
| Optimize #1 | — | — | — | — | — | — | — |

## 5. Quy ước file capture

Đặt trong `captures/`, tên theo mẫu:

```
captures/
├── baseline-profile-YYYYMMDD.png
├── baseline-memory-YYYYMMDD.snapshot
└── baseline-buildreport-YYYYMMDD.json
```

- Chỉ commit file capture **nhẹ** (ảnh, json nhỏ).
- File snapshot lớn hoặc build report nặng: nén và cân nhắc không commit, chỉ ghi link ngoài.
- Không commit build binary vào `captures/`.
